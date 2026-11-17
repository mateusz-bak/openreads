import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:html/parser.dart' as html;
import 'package:openreads/core/constants/enums/enums.dart';

import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/main.dart';

class CSVImportStoryGraph {
  static Future importCSVLegacyStorage(BuildContext context) async {
    try {
      final csvPath = await BackupGeneral.openFilePicker(
        context,
        allowedExtensions: ['.csv'],
      );
      if (csvPath == null) return;

      final csvBytes = await File(csvPath).readAsBytes();

      final books = _parseCSV(csvBytes);
      if (books == null) {
        BackupGeneral.showInfoSnackbar(LocaleKeys.csv_not_valid.tr());
        return;
      }

      final importedBooksIDs = await bookCubit.importAdditionalBooks(books);

      if (!context.mounted) return;
      BackupGeneral.showRestoreMissingCoversDialog(
        bookIDs: importedBooksIDs,
        context: context,
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future importCSV(BuildContext context) async {
    try {
      final csvBytes = await BackupGeneral.pickCSVFileAndGetContent();
      if (csvBytes == null) return;

      final books = _parseCSV(csvBytes);
      if (books == null) {
        BackupGeneral.showInfoSnackbar(LocaleKeys.csv_not_valid.tr());
        return;
      }

      final importedBooksIDs = await bookCubit.importAdditionalBooks(books);

      if (!context.mounted) return;
      BackupGeneral.showRestoreMissingCoversDialog(
        bookIDs: importedBooksIDs,
        context: context,
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static List<Book>? _parseCSV(Uint8List csvBytes) {
    return parseBooks(
      utf8.decode(csvBytes),
      onError: (e) => BackupGeneral.showInfoSnackbar(e.toString()),
    );
  }

  // separated from the context so the parsing can be tested,
  // returns null when the file is not a StoryGraph export
  @visibleForTesting
  static List<Book>? parseBooks(
    String csvString, {
    Function(Object error)? onError,
  }) {
    final books = List<Book>.empty(growable: true);

    // Excel's "CSV UTF-8" adds a BOM, which would hide the 'Title' column
    if (csvString.startsWith('\uFEFF')) csvString = csvString.substring(1);

    final csv = Csv(autoDetect: false).decode(csvString);
    if (csv.isEmpty ||
        !csv[0].contains('Title') ||
        !csv[0].contains('Read Status')) {
      return null;
    }

    for (var i = 0; i < csv.length; i++) {
      // Skip first row with headers
      if (i == 0) continue;

      // Skip empty lines
      if (_getTitle(i, csv).isEmpty) continue;

      try {
        books.add(_parseBook(i, csv));
      } catch (e) {
        onError?.call(e);
      }
    }

    return books;
  }

  static Book _parseBook(int i, List<List> csv) {
    return Book(
      title: _getTitle(i, csv),
      author: _getAuthor(i, csv),
      isbn: _getISBN(i, csv),
      rating: _getRating(i, csv),
      myReview: _getMyReview(i, csv),
      status: _getStatus(i, csv),
      tags: _getTags(i, csv),
      readings: _getReadings(i, csv),
      bookFormat: _getBookFormat(i, csv),
      dateAdded: _getDateAdded(i, csv),
      dateModified: DateTime.now(),
    );
  }

  static String _getField(int i, List<List<dynamic>> csv, String header) {
    final index = csv[0].indexOf(header);

    return index != -1 ? csv[i][index].toString().trim() : '';
  }

  // removes HTML tags and decodes entities like &amp;,
  // line breaks and paragraphs become new lines
  static String _cleanHtml(String text) {
    final withNewLines = text
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|div)>', caseSensitive: false), '\n');

    return html.parseFragment(withNewLines).text?.trim() ?? text;
  }

  static String _getTitle(int i, List<List<dynamic>> csv) {
    return _cleanHtml(_getField(i, csv, 'Title'));
  }

  static String _getAuthor(int i, List<List<dynamic>> csv) {
    // Example Authors fields:
    // Frank Herbert
    // Terry Pratchett, Neil Gaiman
    return _cleanHtml(_getField(i, csv, 'Authors'));
  }

  static String? _getISBN(int i, List<List<dynamic>> csv) {
    // Example ISBN/UID fields:
    // 9780450000898
    // 0060853980
    // B08FHBV4ZX (ASIN)
    // 38549081 (StoryGraph's own ID)
    final isbn = _getField(i, csv, 'ISBN/UID');
    final isISBN = RegExp(r'^(\d{9}[\dX]|\d{13})$').hasMatch(isbn);

    return isISBN ? isbn : null;
  }

  static int? _getRating(int i, List<List<dynamic>> csv) {
    // Example Star Rating fields:
    // 5
    // 4.0
    // 3.75
    final rating = double.tryParse(_getField(i, csv, 'Star Rating'));

    // the app supports only half stars
    return rating != null && rating != 0 ? (rating * 2).round() * 5 : null;
  }

  static String? _getMyReview(int i, List<List<dynamic>> csv) {
    // Example Review fields:
    // <div>Wonderful book.</div>
    // characters &amp; some descriptions
    final myReview = _cleanHtml(_getField(i, csv, 'Review'));

    return myReview.isNotEmpty ? myReview : null;
  }

  static BookStatus _getStatus(int i, List<List<dynamic>> csv) {
    switch (_getField(i, csv, 'Read Status')) {
      case 'currently-reading':
        return BookStatus.inProgress;
      case 'to-read':
        return BookStatus.forLater;
      case 'did-not-finish':
        return BookStatus.unfinished;
      default:
        return BookStatus.read;
    }
  }

  static String? _getTags(int i, List<List<dynamic>> csv) {
    // Example Tags fields:
    // fantasy
    // books-of-faith, my-comics
    final tags = _getField(i, csv, 'Tags')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return tags.isNotEmpty ? tags.join('|||||') : null;
  }

  static List<Reading> _getReadings(int i, List<List<dynamic>> csv) {
    // Example Dates Read fields:
    // 2024/03/20
    // 2026/10/02-
    // 2025/01/10-2025/02/10, 2019/06/01-2019/07/15
    final readings = List<Reading>.empty(growable: true);

    final datesRead = _getField(i, csv, 'Dates Read');
    if (datesRead.isEmpty) {
      final lastDateRead = _parseDate(_getField(i, csv, 'Last Date Read'));
      if (lastDateRead != null) {
        readings.add(Reading(finishDate: lastDateRead));
      }

      return readings;
    }

    for (final dates in datesRead.split(',')) {
      final splittedDates = dates.trim().split('-');

      // a single date is the finish date
      final startDate =
          splittedDates.length > 1 ? _parseDate(splittedDates[0]) : null;
      final finishDate = _parseDate(splittedDates.last);

      if (startDate != null || finishDate != null) {
        readings.add(Reading(startDate: startDate, finishDate: finishDate));
      }
    }

    return readings;
  }

  static DateTime _getDateAdded(int i, List<List<dynamic>> csv) {
    return _parseDate(_getField(i, csv, 'Date Added')) ?? DateTime.now();
  }

  // newer exports use 2026/09/21, older ones 21/09/2026
  static DateTime? _parseDate(String date) {
    final splittedDate = date.trim().split('/');
    if (splittedDate.length != 3) return null;

    final numbers = splittedDate.map(int.tryParse).toList();
    if (numbers.contains(null)) return null;

    final isYearFirst = splittedDate[0].length == 4;
    final year = isYearFirst ? numbers[0]! : numbers[2]!;
    final month = numbers[1]!;
    final day = isYearFirst ? numbers[2]! : numbers[0]!;

    // DateTime rolls invalid values over, e.g. a US date 08/27/2023
    final parsedDate = DateTime(year, month, day);
    if (parsedDate.month != month || parsedDate.day != day) return null;

    return parsedDate;
  }

  static BookFormat _getBookFormat(int i, List<List<dynamic>> csv) {
    // Example Format fields:
    // hardcover
    // paperback
    // digital
    // audio
    switch (_getField(i, csv, 'Format')) {
      case 'hardcover':
        return BookFormat.hardcover;
      case 'digital':
        return BookFormat.ebook;
      case 'audio':
        return BookFormat.audiobook;
      default:
        return BookFormat.paperback;
    }
  }
}
