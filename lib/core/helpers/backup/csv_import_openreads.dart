import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/main.dart';

class CSVImportOpenreads {
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
      final book = _parseBook(context, i, csv);

      if (book != null) {
        books.add(book);
      }
    }

    return books;
  }

  static Book? _parseBook(BuildContext context, int i, List<List> csv) {
    if (!context.mounted) return null;

    try {
      return Book(
        title: _getField(i, csv, 'title'),
        subtitle: _getField(i, csv, 'subtitle'),
        author: _getField(i, csv, 'author'),
        description: _getField(i, csv, 'description'),
        status: _getStatus(i, csv),
        favourite: _getBoolField(i, csv, 'favourite'),
        deleted: _getBoolField(i, csv, 'deleted'),
        rating: _getRating(i, csv),
        pages: _getPages(i, csv),
        publicationYear: _getPublicationYear(i, csv),
        isbn: _getISBN(i, csv),
        olid: _getOLID(i, csv),
        tags: _getTags(i, csv),
        myReview: _getField(i, csv, 'my_review'),
        notes: _getField(i, csv, 'notes'),
        bookFormat: _getBookFormat(i, csv),
        readings: _getReadingDates(i, csv),
        dateAdded: _getDate(i, csv, 'date_added') ?? DateTime.now(),
        dateModified: _getDate(i, csv, 'date_modified') ?? DateTime.now(),
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static String? _getISBN(int i, List<List<dynamic>> csv) {
    final isbn = csv[i][csv[0].indexOf('isbn')].toString();

    if (isbn.isNotEmpty) {
      return isbn;
    } else {
      return null;
    }
  }

  static String? _getOLID(int i, List<List<dynamic>> csv) {
    final olid = csv[i][csv[0].indexOf('olid')].toString();

    if (olid.isNotEmpty) {
      return olid;
    } else {
      return null;
    }
  }

  static String _getField(int i, List<List<dynamic>> csv, String field) {
    return csv[i][csv[0].indexOf(field)].toString();
  }

  static bool _getBoolField(int i, List<List<dynamic>> csv, String field) {
    return csv[i][csv[0].indexOf(field)].toString() == 'true';
  }

  static List<Reading> _getReadingDates(
    int i,
    List<List<dynamic>> csv,
  ) {
    List<Reading> readingsList = List<Reading>.empty(growable: true);

    final index = csv[0].indexOf('readings');

    if (index == -1) {
      return readingsList;
    }

    final readingsListString = csv[i][index].toString();
    final List<String> readingStrings = readingsListString.split(';');

    if (readingStrings.isEmpty) {
      return readingsList;
    }

    readingsList = List<Reading>.from(
      readingStrings.map((e) {
        final reading = Reading.fromString(e);

        if (reading.startDate == null &&
            reading.finishDate == null &&
            reading.customReadingTime == null) {
          return null;
        } else {
          return reading;
        }
      }).where((reading) => reading != null),
    );

    return readingsList;
  }

  static int? _getRating(int i, List<List<dynamic>> csv) {
    final rating = double.tryParse(
      csv[i][csv[0].indexOf('rating')].toString(),
    );

    if (rating == null) {
      return null;
    } else {
      return (rating * 10).toInt();
    }
  }

  static int? _getPages(int i, List<List<dynamic>> csv) {
    final pagesField = csv[i][csv[0].indexOf('pages')].toString();
    return pagesField.isNotEmpty ? int.tryParse(pagesField) : null;
  }

  static int? _getPublicationYear(int i, List<List<dynamic>> csv) {
    final publicationYearField =
        csv[i][csv[0].indexOf('publication_year')].toString();

    return publicationYearField.isNotEmpty
        ? int.tryParse(publicationYearField)
        : null;
  }

  static BookStatus _getStatus(int i, List<List<dynamic>> csv) {
    final statusField = csv[i][csv[0].indexOf('status')].toString();
    return statusField == 'in_progress'
        ? BookStatus.inProgress
        : statusField == 'planned'
            ? BookStatus.forLater
            : statusField == 'abandoned'
                ? BookStatus.unfinished
                : BookStatus.read;
  }

  static String? _getTags(int i, List<List<dynamic>> csv) {
    final bookselvesField = csv[i][csv[0].indexOf('tags')].toString();

    if (bookselvesField.isNotEmpty) {
      return bookselvesField;
    } else {
      return null;
    }
  }

  static DateTime? _getDate(int i, List<List<dynamic>> csv, String field) {
    final dateReadField = csv[i][csv[0].indexOf(field)].toString();
    DateTime? dateRead;

    if (dateReadField.isNotEmpty) {
      try {
        dateRead = DateTime.parse(dateReadField);
      } catch (e) {
        dateRead = null;
      }
    }

    return dateRead;
  }

  static BookFormat _getBookFormat(int i, List<List<dynamic>> csv) {
    final bookFormat = csv[i][csv[0].indexOf('book_format')].toString();

    if (bookFormat == 'paperback') {
      return BookFormat.paperback;
    } else if (bookFormat == 'hardcover') {
      return BookFormat.hardcover;
    } else if (bookFormat == 'ebook') {
      return BookFormat.ebook;
    } else if (bookFormat == 'audiobook') {
      return BookFormat.audiobook;
    } else {
      return BookFormat.paperback;
    }
  }
}
