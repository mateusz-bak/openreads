import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_storage/shared_storage.dart';

import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';

class CSVExport {
  static exportCSVLegacyStorage(BuildContext context) async {
    final csv = await _prepareCSVExport();
    if (csv == null) return;

    // ignore: use_build_context_synchronously
    final exportPath = await BackupGeneral.openFolderPicker(context);
    if (exportPath == null) return;

    final fileName = await _prepareCSVExportFileName();
    final filePath = '$exportPath/$fileName';

    try {
      createFileAsBytes(
        Uri(path: filePath),
        mimeType: 'text/csv',
        displayName: fileName,
        bytes: Uint8List.fromList(utf8.encode(csv)),
      );

      BackupGeneral.showInfoSnackbar(LocaleKeys.export_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future exportCSV() async {
    final csvString = await _prepareCSVExport();
    if (csvString == null) return;
    final csv = Uint8List.fromList(utf8.encode(csvString));

    final fileName = await _prepareCSVExportFileName();

    try {
      if (Platform.isAndroid) {
        final selectedUriDir = await openDocumentTree();

        if (selectedUriDir == null) return;

        createFileAsBytes(
          selectedUriDir,
          mimeType: 'text/csv',
          displayName: fileName,
          bytes: csv,
        );
      } else if (Platform.isIOS) {
        String? selectedDirectory =
            await FilePicker.platform.getDirectoryPath();

        if (selectedDirectory == null) return;

        File('$selectedDirectory/$fileName').writeAsBytesSync(csv);
      }

      BackupGeneral.showInfoSnackbar(LocaleKeys.export_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future<String?> _prepareCSVExport() async {
    try {
      await bookCubit.getAllBooks(tags: true);

      final books = await bookCubit.allBooks.first;
      final rows = List<List<String>>.empty(growable: true);

      final firstRow = [
        ('title'),
        ('subtitle'),
        ('author'),
        ('description'),
        ('status'),
        ('favourite'),
        ('deleted'),
        ('rating'),
        ('start_date'),
        ('finish_date'),
        ('pages'),
        ('publication_year'),
        ('isbn'),
        ('olid'),
        ('tags'),
        ('my_review'),
        ('notes'),
        ('book_format'),
        ('reading_time'),
      ];

      rows.add(firstRow);

      for (var book in books) {
        final newRow = List<String>.empty(growable: true);

        newRow.add(book.title);
        newRow.add(book.subtitle ?? '');
        newRow.add(book.author);
        newRow.add(book.description ?? '');
        newRow.add(
          book.status == 0
              ? 'finished'
              : book.status == 1
                  ? 'in_progress'
                  : book.status == 2
                      ? 'planned'
                      : book.status == 3
                          ? 'abandoned'
                          : 'unknown',
        );
        newRow.add(book.favourite.toString());
        newRow.add(book.deleted.toString());
        newRow.add(book.rating != null ? (book.rating! / 10).toString() : '');
        newRow.add(
            book.startDate != null ? book.startDate!.toIso8601String() : '');
        newRow.add(
            book.finishDate != null ? book.finishDate!.toIso8601String() : '');
        newRow.add(book.pages != null ? book.pages.toString() : '');
        newRow.add(book.publicationYear != null
            ? book.publicationYear.toString()
            : '');
        newRow.add(book.isbn ?? '');
        newRow.add(book.olid ?? '');
        newRow.add(book.tags ?? '');
        newRow.add(book.myReview ?? '');
        newRow.add(book.notes ?? '');
        newRow.add(book.bookFormat == BookFormat.paperback
            ? 'paperback'
            : book.bookFormat == BookFormat.hardcover
                ? 'hardcover'
                : book.bookFormat == BookFormat.ebook
                    ? 'ebook'
                    : book.bookFormat == BookFormat.audiobook
                        ? 'audiobook'
                        : '');
        newRow.add(book.readingTime != null
            ? book.readingTime!.milliSeconds.toString()
            : '');

        rows.add(newRow);
      }

      return const ListToCsvConverter().convert(
        rows,
        textDelimiter: '"',
        textEndDelimiter: '"',
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static Future<String> _prepareCSVExportFileName() async {
    final date = DateTime.now();

    final exportDate =
        '${date.year}_${date.month}_${date.day}-${date.hour}_${date.minute}_${date.second}';

    return 'Openreads-$exportDate.csv';
  }
}
