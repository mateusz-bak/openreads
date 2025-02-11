import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/main.dart';

class CSVImportGoodreads {
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
    final csv = const CsvToListConverter().convert(csvString, eol: '\n');

    final headers = csv[0];

    // Get propositions for which exclusive shelf is "not finished"
    final notFinishedShelfPropositions = _getNotFinishedShelfPropositions(csv);
    String? notFinishedShelf;

    // If there is only one proposition for "not finished" shelf
    // and it is one of the most popular ones, then use it
    notFinishedShelf = _getDefaultNotFinishedShelf(
      notFinishedShelfPropositions,
    );

    // show dialog to choose which shelf is "not finished"
    if (notFinishedShelfPropositions.isNotEmpty && notFinishedShelf == null) {
      notFinishedShelf = await _askUserForNotFinshedShelf(
        context,
        notFinishedShelfPropositions,
      );
    }

    for (var i = 0; i < csv.length; i++) {
      // Skip first row with headers
      if (i == 0) continue;

      // ignore: use_build_context_synchronously
      final book = _parseBook(
        context,
        i,
        csv: csv,
        headers: headers,
        notFinishedShelf: notFinishedShelf,
      );

      if (book != null) {
        books.add(book);
      }
    }

    return books;
  }

  static List<String> _getNotFinishedShelfPropositions(
    List<List<dynamic>> csv,
  ) {
    final headers = csv[0];

    final notFinishedShelfPropositions = List<String>.empty(growable: true);
    for (var i = 0; i < csv.length; i++) {
      if (i == 0) continue;

      final exclusiveShelf = csv[i][headers.indexOf('Exclusive Shelf')];

      // If the exclusive shelf is one of the default ones, then skip
      if (exclusiveShelf == "read" ||
          exclusiveShelf == "currently-reading" ||
          exclusiveShelf == "to-read") {
        continue;
      }

      if (!notFinishedShelfPropositions.contains(exclusiveShelf)) {
        notFinishedShelfPropositions.add(exclusiveShelf);
      }
    }

    return notFinishedShelfPropositions;
  }

  static String? _getDefaultNotFinishedShelf(
    List<String> notFinishedShelfPropositions,
  ) {
    if (notFinishedShelfPropositions.length == 1) {
      if (notFinishedShelfPropositions[0] == 'abandoned') {
        return 'abandoned';
      } else if (notFinishedShelfPropositions[0] == 'did-not-finish') {
        return 'did-not-finish';
      }
    }

    return null;
  }

  static Future<String?> _askUserForNotFinshedShelf(
    BuildContext context,
    List<String> notFinishedShelfPropositions,
  ) async {
    if (!context.mounted) return null;

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Text(
            LocaleKeys.choose_not_finished_shelf.tr(),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: notFinishedShelfPropositions
                  .map(
                    (e) => Platform.isIOS
                        ? CupertinoDialogAction(
                            onPressed: () => Navigator.of(context).pop(e),
                            child: Text(e),
                          )
                        : ListTile(
                            title: Text(e),
                            onTap: () => Navigator.of(context).pop(e),
                          ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  static Book? _parseBook(
    BuildContext context,
    int i, {
    required List<List> csv,
    required List headers,
    required String? notFinishedShelf,
  }) {
    if (!context.mounted) return null;

    try {
      return Book(
        title: _getTitle(i, csv, headers),
        author: _getAuthor(i, csv, headers),
        isbn: _getISBN(i, csv, headers),
        rating: _getRating(i, csv, headers),
        pages: _getPages(i, csv, headers),
        publicationYear: _getPublicationYear(i, csv, headers),
        myReview: _getMyReview(i, csv, headers),
        status: _getStatus(i, csv, headers, notFinishedShelf: notFinishedShelf),
        tags: _getTags(i, csv, headers, notFinishedShelf: notFinishedShelf),
        readings: _getReadingDates(i, csv, headers),
        bookFormat: _getBookFormat(i, csv, headers),
        dateAdded: _getDateAdded(i, csv, headers),
        dateModified: DateTime.now(),
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static String? _getISBN(int i, List<List<dynamic>> csv, List headers) {
    // Example ISBN fields:
    // ="0300259360"
    // =""
    final isbn10 = csv[i][headers.indexOf('ISBN')]
        .toString()
        .replaceAll("\"", "")
        .replaceAll("=", "");

    // Example ISBN13 fields:
    // ="9780300259360"
    // =""
    final isbn13 = csv[i][headers.indexOf('ISBN13')]
        .toString()
        .replaceAll("\"", "")
        .replaceAll("=", "");

    if (isbn13.isNotEmpty) {
      return isbn13;
    } else if (isbn10.isNotEmpty) {
      return isbn10;
    } else {
      return null;
    }
  }

  static String _getAuthor(int i, List<List<dynamic>> csv, List headers) {
    String author = csv[i][headers.indexOf('Author')].toString();
    if (csv[i][headers.indexOf('Additional Authors')].toString().isNotEmpty) {
      author += ', ${csv[i][headers.indexOf('Additional Authors')]}';
    }

    return author;
  }

  static String _getTitle(int i, List<List<dynamic>> csv, List headers) {
    return csv[i][headers.indexOf('Title')].toString();
  }

  static int? _getRating(int i, List<List<dynamic>> csv, List headers) {
    // Example My Rating fields:
    // 0
    // 5
    final rating = int.parse(
          csv[i][headers.indexOf('My Rating')].toString(),
        ) *
        10;

    return rating != 0 ? rating : null;
  }

  static int? _getPages(int i, List<List<dynamic>> csv, List headers) {
    // Example Number of Pages fields:
    // 336
    final pagesField = csv[i][headers.indexOf('Number of Pages')].toString();
    return pagesField.isNotEmpty ? int.parse(pagesField) : null;
  }

  static int? _getPublicationYear(
      int i, List<List<dynamic>> csv, List headers) {
    // Example Year Published fields:
    // 2021
    final publicationYearField =
        csv[i][headers.indexOf('Year Published')].toString();
    return publicationYearField.isNotEmpty
        ? int.parse(publicationYearField)
        : null;
  }

  static String? _getMyReview(int i, List<List<dynamic>> csv, List headers) {
    // Example My Review fields:
    // https://example.com/some_url
    // Lorem ipsum dolor sit amet
    final myReview = csv[i][headers.indexOf('My Review')].toString();

    return myReview.isNotEmpty ? myReview : null;
  }

  static BookStatus _getStatus(
    int i,
    List<List<dynamic>> csv,
    List headers, {
    String? notFinishedShelf,
  }) {
    // Default Exclusive Shelf fields:
    // read
    // currently-reading
    // to-read
    // Custom Exclusive Shelf fields:
    // abandoned
    // did-not-finish
    final exclusiveShelfField =
        csv[i][headers.indexOf('Exclusive Shelf')].toString();
    return exclusiveShelfField == 'currently-reading'
        ? BookStatus.inProgress
        : exclusiveShelfField == 'to-read'
            ? BookStatus.forLater
            : notFinishedShelf != null &&
                    exclusiveShelfField == notFinishedShelf
                ? BookStatus.unfinished
                : BookStatus.read;
  }

  static String? _getTags(
    int i,
    List<List<dynamic>> csv,
    List headers, {
    String? notFinishedShelf,
  }) {
    // Example Bookshelves fields:
    // read
    // currently-reading
    // to-read
    // lorem ipsum
    final bookselvesField = csv[i][headers.indexOf('Bookshelves')].toString();
    List<String>? bookshelves = bookselvesField.isNotEmpty
        ? bookselvesField.split(',').map((e) => e.trim()).toList()
        : null;

    if (bookshelves != null) {
      if (bookshelves.contains('read')) {
        bookshelves.remove('read');
      }
      if (bookshelves.contains('currently-reading')) {
        bookshelves.remove('currently-reading');
      }
      if (bookshelves.contains('to-read')) {
        bookshelves.remove('to-read');
      }
      if (notFinishedShelf != null && bookshelves.contains(notFinishedShelf)) {
        bookshelves.remove(notFinishedShelf);
      }

      if (bookshelves.isEmpty) {
        bookshelves = null;
      }
    }

    return bookshelves?.join('|||||');
  }

  static List<Reading> _getReadingDates(
      int i, List<List<dynamic>> csv, List headers) {
    // Example Date Read fields:
    // 2021/04/06
    // 2022/04/27
    final dateReadField = csv[i][headers.indexOf('Date Read')].toString();
    final readingDates = List<Reading>.empty(growable: true);

    if (dateReadField.isNotEmpty) {
      final splittedDate = dateReadField.split('/');
      if (splittedDate.length == 3) {
        final year = int.parse(splittedDate[0]);
        final month = int.parse(splittedDate[1]);
        final day = int.parse(splittedDate[2]);

        final dateRead = DateTime(year, month, day);
        readingDates.add(Reading(startDate: dateRead));
      }
    }

    return readingDates;
  }

  static DateTime _getDateAdded(int i, List<List<dynamic>> csv, List headers) {
    // Example Date Added fields:
    // 2021/04/06
    // 2022/04/27
    final dateReadField = csv[i][headers.indexOf('Date Added')].toString();

    if (dateReadField.isNotEmpty) {
      final splittedDate = dateReadField.split('/');
      if (splittedDate.length == 3) {
        final year = int.parse(splittedDate[0]);
        final month = int.parse(splittedDate[1]);
        final day = int.parse(splittedDate[2]);

        return DateTime(year, month, day);
      }
    }

    return DateTime.now();
  }

  static BookFormat _getBookFormat(
      int i, List<List<dynamic>> csv, List headers) {
    // Example Binding fields:
    // Audible Audio
    // Audio Cassette
    // Audio CD
    // Audiobook
    // Board Book
    // Chapbook
    // ebook
    // Hardcover
    // Kindle Edition
    // Mass Market Paperback
    // Nook
    // Paperback
    final bindingField = csv[i][headers.indexOf('Binding')].toString();
    late BookFormat bookFormat;

    if (bindingField == 'Audible Audio' ||
        bindingField == 'Audio Cassette' ||
        bindingField == 'Audio CD' ||
        bindingField == 'Audiobook') {
      bookFormat = BookFormat.audiobook;
    } else if (bindingField == 'Kindle Edition' ||
        bindingField == 'Nook' ||
        bindingField == 'ebook') {
      bookFormat = BookFormat.ebook;
    } else if (bindingField == 'Mass Market Paperback' ||
        bindingField == 'Paperback' ||
        bindingField == 'Chapbook') {
      bookFormat = BookFormat.paperback;
    } else if (bindingField == 'Hardcover' || bindingField == 'Board Book') {
      bookFormat = BookFormat.hardcover;
    } else {
      bookFormat = BookFormat.paperback;
    }

    return bookFormat;
  }
}
