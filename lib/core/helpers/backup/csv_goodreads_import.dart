import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_storage/shared_storage.dart';

import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/core/helpers/backup/backup_helpers.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/main.dart';

class CSVGoodreadsImport {
  static importGoodreadsCSVLegacyStorage(BuildContext context) async {
    try {
      final csvPath = await BackupGeneral.openFilePicker(
        context,
        allowedExtensions: ['.csv'],
      );
      if (csvPath == null) return;

      final csvBytes = await File(csvPath).readAsBytes();

      // ignore: use_build_context_synchronously
      final books = await _parseGoodreadsCSV(context, csvBytes);
      await bookCubit.importAdditionalBooks(books);

      BackupGeneral.showInfoSnackbar(LocaleKeys.import_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future importGoodreadsCSV(BuildContext context) async {
    try {
      final csvBytes = await BackupGeneral.pickFileAndGetContent();
      if (csvBytes == null) return;

      // ignore: use_build_context_synchronously
      final books = await _parseGoodreadsCSV(context, csvBytes);
      await bookCubit.importAdditionalBooks(books);

      BackupGeneral.showInfoSnackbar(LocaleKeys.import_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future<List<Book>> _parseGoodreadsCSV(
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
      final book = _parseGoodreadsBook(
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
        return AlertDialog(
          title: Text(
            LocaleKeys.choose_not_finished_shelf.tr(),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: notFinishedShelfPropositions
                  .map(
                    (e) => ListTile(
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

  static Book? _parseGoodreadsBook(
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
        finishDate: _getFinishDate(i, csv, headers),
        bookFormat: _getBookFormat(i, csv, headers),
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

  static int _getStatus(
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
    return exclusiveShelfField == 'read'
        ? 0
        : exclusiveShelfField == 'currently-reading'
            ? 1
            : exclusiveShelfField == 'to-read'
                ? 2
                : notFinishedShelf != null &&
                        exclusiveShelfField == notFinishedShelf
                    ? 3
                    : 0;
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

  static DateTime? _getFinishDate(
      int i, List<List<dynamic>> csv, List headers) {
    // Example Date Read fields:
    // 2021/04/06
    // 2022/04/27
    final dateReadField = csv[i][headers.indexOf('Date Read')].toString();
    DateTime? dateRead;

    if (dateReadField.isNotEmpty) {
      final splittedDate = dateReadField.split('/');
      if (splittedDate.length == 3) {
        final year = int.parse(splittedDate[0]);
        final month = int.parse(splittedDate[1]);
        final day = int.parse(splittedDate[2]);

        dateRead = DateTime(year, month, day);
      }
    }

    return dateRead;
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
