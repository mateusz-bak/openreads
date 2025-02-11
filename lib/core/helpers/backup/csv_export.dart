import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:share_plus/share_plus.dart';

class CSVExport {
  static exportCSVLegacyStorage(BuildContext context) async {
    final fileName = await _prepareCSVExportFileName();

    try {
      final csvString = await _prepareCSVExport();
      final csv = Uint8List.fromList(utf8.encode(csvString!));

      // ignore: use_build_context_synchronously
      final exportPath = await BackupGeneral.openFolderPicker(context);
      final filePath = '$exportPath/$fileName';

      File(filePath).writeAsBytesSync(csv);

      BackupGeneral.showInfoSnackbar(LocaleKeys.export_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future exportCSV() async {
    final fileName = await _prepareCSVExportFileName();

    try {
      final csvString = await _prepareCSVExport();
      final csv = Uint8List.fromList(utf8.encode(csvString!));

      if (Platform.isAndroid) {
        final safStream = SafStream();
        final safUtil = SafUtil();

        final selectedDirectory = await safUtil.pickDirectory(
          writePermission: true,
        );

        await safStream.writeFileBytes(
          selectedDirectory!.uri,
          fileName,
          'text/csv',
          csv,
        );
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';

        File(path).writeAsBytesSync(csv);
        await Share.shareXFiles([XFile(path)]);
      }

      BackupGeneral.showInfoSnackbar(LocaleKeys.export_successful.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future<String?> _prepareCSVExport() async {
    try {
      await bookCubit.getAllBooks(getAuthors: false, getTags: false);

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
        ('pages'),
        ('publication_year'),
        ('isbn'),
        ('olid'),
        ('tags'),
        ('my_review'),
        ('notes'),
        ('book_format'),
        ('readings'),
        ('date_added'),
        ('date_modified'),
      ];

      rows.add(firstRow);

      for (var book in books) {
        final newRow = List<String>.empty(growable: true);

        newRow.add(book.title);
        newRow.add(book.subtitle ?? '');
        newRow.add(book.author);
        newRow.add(book.description ?? '');
        newRow.add(
          book.status == BookStatus.read
              ? 'finished'
              : book.status == BookStatus.inProgress
                  ? 'in_progress'
                  : book.status == BookStatus.forLater
                      ? 'planned'
                      : book.status == BookStatus.unfinished
                          ? 'abandoned'
                          : 'unknown',
        );
        newRow.add(book.favourite.toString());
        newRow.add(book.deleted.toString());
        newRow.add(book.rating != null ? (book.rating! / 10).toString() : '');
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
        newRow.add(
          book.readings.isNotEmpty
              ? book.readings.map((reading) => reading.toString()).join(';')
              : '',
        );
        newRow.add(book.dateAdded.toIso8601String());
        newRow.add(book.dateModified.toIso8601String());

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
