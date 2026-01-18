import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:openreads/core/constants/enums/enums.dart';

import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/main.dart';

class CSVImportBookwyrm {
  static importCSVLegacyStorage(BuildContext context) async {
    try {
      final csvPath = await BackupGeneral.openFilePicker(
        context,
        allowedExtensions: ['.csv'],
      );
      if (csvPath == null) return;

      final csvBytes = await File(csvPath).readAsBytes();

      // ignore: use_build_context_synchronously
      final books = await _parseCSV(context, csvBytes);
      final importedBooksIDs = await bookCubit.importAdditionalBooks(books);

      // ignore: use_build_context_synchronously
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

      // ignore: use_build_context_synchronously
      final books = await _parseCSV(context, csvBytes);
      final importedBooksIDs = await bookCubit.importAdditionalBooks(books);

      // ignore: use_build_context_synchronously
      BackupGeneral.showRestoreMissingCoversDialog(
        bookIDs: importedBooksIDs,
        context: context,
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future<List<Book>> _parseCSV(
    BuildContext context,
    Uint8List csvBytes,
  ) async {
    final books = List<Book>.empty(growable: true);

    final csvString = utf8.decode(csvBytes);
    final csv = const CsvToListConverter().convert(csvString, eol: '\r\n');

    for (var i = 0; i < csv.length; i++) {
      // Skip first row with headers
      if (i == 0) continue;

      // ignore: use_build_context_synchronously
      final book = _parseBook(
        context,
        i,
        csv,
      );

      if (book != null) {
        books.add(book);
      }
    }

    return books;
  }

  static Book? _parseBook(
    BuildContext context,
    int i,
    List<List> csv,
  ) {
    if (!context.mounted) return null;

    try {
      return Book(
        title: _getTitle(i, csv),
        author: _getAuthor(i, csv),
        isbn: _getISBN(i, csv),
        olid: _getOLID(i, csv),
        rating: _getRating(i, csv),
        myReview: _getMyReview(i, csv),
        status: _getStatus(i, csv),
        readings: _getReadings(i, csv),
        dateAdded: _getDateAdded(i, csv),
        dateModified: DateTime.now(),
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static String? _getISBN(int i, List<List<dynamic>> csv) {
    // Example isbn_10 fields:
    // 1848872275
    // 067088040X
    final isbn10 = csv[i][csv[0].indexOf('isbn_10')].toString();

    // Example isbn_13 fields:
    // 9780670880409
    final isbn13 = csv[i][csv[0].indexOf('isbn_13')].toString();

    if (isbn13.isNotEmpty) {
      return isbn13;
    } else if (isbn10.isNotEmpty) {
      return isbn10;
    } else {
      return null;
    }
  }

  static String? _getOLID(int i, List<List<dynamic>> csv) {
    // Example openlibrary_key fields:
    // OL32367826M
    final olid = csv[i][csv[0].indexOf('openlibrary_key')].toString();

    return olid.isNotEmpty ? olid : null;
  }

  static String _getAuthor(int i, List<List<dynamic>> csv) {
    String author = csv[i][csv[0].indexOf('author_text')].toString();

    return author;
  }

  static String _getTitle(int i, List<List<dynamic>> csv) {
    return csv[i][csv[0].indexOf('title')].toString();
  }

  static int? _getRating(int i, List<List<dynamic>> csv) {
    // Example rating fields:
    // 0
    // 5
    final rating = int.tryParse(
      csv[i][csv[0].indexOf('rating')].toString(),
    );

    return rating != null && rating != 0 ? rating * 10 : null;
  }

  static String? _getMyReview(int i, List<List<dynamic>> csv) {
    final myReview = csv[i][csv[0].indexOf('review_content')].toString();

    return myReview.isNotEmpty ? myReview : null;
  }

  static BookStatus _getStatus(int i, List<List<dynamic>> csv) {
    // Get status from shelf field or infer by reading/stopped dates

    // Default values of shelf field from bookwyrm export : read, reading, to-read, stopped-reading
    final shelf = csv[i][csv[0].indexOf('shelf')].toString();

    switch (shelf) {
      case 'read':
        return BookStatus.read;
      case 'reading':
        return BookStatus.inProgress;
      case 'to-read':
        return BookStatus.forLater;
      case 'stopped-reading':
        return BookStatus.unfinished;
      default:
        // Unknown/other/empty value -> Infer status by dates
        // In bookwyrm export, there is *either* a finish date or a stopped date
        final startDateIndex = csv[0].indexOf('start_date');
        final finishDateIndex = csv[0].indexOf('finish_date');
        final stoppedDateIndex = csv[0].indexOf('stopped_date');

        final hasStartDate = startDateIndex != -1 &&
            csv[i][startDateIndex].toString().isNotEmpty;
        final hasFinishDate = finishDateIndex != -1 &&
            csv[i][finishDateIndex].toString().isNotEmpty;
        final hasStoppedDate = stoppedDateIndex != -1 &&
            csv[i][stoppedDateIndex].toString().isNotEmpty;

        if (hasFinishDate) {
          return BookStatus.read;
        } else if (hasStoppedDate) {
          return BookStatus.unfinished;
        } else if (hasStartDate) {
          return BookStatus.inProgress;
        } else {
          return BookStatus.forLater;
        }
    }
  }

  static List<Reading> _getReadings(int i, List<List<dynamic>> csv) {
    List<Reading> readings = [];

    final startDateIndex = csv[0].indexOf('start_date');
    final finishDateIndex = csv[0].indexOf('finish_date');
    final stoppedDateIndex = csv[0].indexOf('stopped_date');

    DateTime? startDate;
    DateTime? finishDate;
    DateTime? stoppedDate;

    if (startDateIndex != -1) {
      final startDateString = csv[i][startDateIndex].toString();
      if (startDateString.isNotEmpty) {
        startDate = DateTime.parse(startDateString);
      }
    }

    if (finishDateIndex != -1) {
      final finishDateString = csv[i][finishDateIndex].toString();
      if (finishDateString.isNotEmpty) {
        finishDate = DateTime.parse(finishDateString);
      }
    }

    if (stoppedDateIndex != -1) {
      final stoppedDateString = csv[i][stoppedDateIndex].toString();
      if (stoppedDateString.isNotEmpty) {
        stoppedDate = DateTime.parse(stoppedDateString);
      }
    }

    if (startDate != null || finishDate != null || stoppedDate != null) {
      readings.add(Reading(
        startDate: startDate,
        finishDate: finishDate ?? stoppedDate,
      ));
    }

    return readings;
  }

  static DateTime _getDateAdded(int i, List<List<dynamic>> csv) {
    final dateAddedString = csv[i][csv[0].indexOf('shelf_date')].toString();

    if (dateAddedString.isNotEmpty) {
      return DateTime.parse(dateAddedString);
    } else {
      return DateTime.now();
    }
  }
}
