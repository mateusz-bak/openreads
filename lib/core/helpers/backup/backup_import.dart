import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:archive/archive_io.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/logic/cubit/backup_progress_cubit.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;

import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/year_from_backup_v3.dart';
import 'package:openreads/model/yearly_challenge.dart';

class BackupImport {
  static restoreLocalBackupLegacyStorage(BuildContext context) async {
    final tmpDir = appTempDirectory.absolute;
    _deleteTmpData(tmpDir);

    try {
      final archivePath = await BackupGeneral.openFilePicker(context);
      if (archivePath == null) return;

      if (archivePath.contains('Openreads-4-')) {
        // ignore: use_build_context_synchronously
        await _restoreBackupVersion4(
          context,
          archivePath: archivePath,
          tmpPath: tmpDir,
        );
      } else if (archivePath.contains('openreads_3_')) {
        // ignore: use_build_context_synchronously
        await _restoreBackupVersion3(
          context,
          archivePath: archivePath,
          tmpPath: tmpDir,
        );
      } else {
        // Because file name is not always possible to read
        // backups v5 is recognized by the info.txt file
        final infoFileVersion =
            _checkInfoFileVersion(File(archivePath).readAsBytesSync(), tmpDir);
        if (infoFileVersion == 5) {
          // ignore: use_build_context_synchronously
          await _restoreBackupVersion5(
            context,
            File(archivePath).readAsBytesSync(),
            tmpDir,
          );
        } else {
          BackupGeneral.showInfoSnackbar(LocaleKeys.backup_not_valid.tr());
          return;
        }
      }

      BackupGeneral.showInfoSnackbar(LocaleKeys.restore_successfull.tr());

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future restoreLocalBackup(BuildContext context) async {
    final tmpDir = appTempDirectory.absolute;
    _deleteTmpData(tmpDir);

    try {
      if (Platform.isAndroid) {
        final safStream = SafStream();
        final safUtil = SafUtil();

        final pickedFile = await safUtil.pickFile();

        if (pickedFile == null) {
          BackupGeneral.showInfoSnackbar(LocaleKeys.backup_not_valid.tr());
          return;
        }

        final file = await safStream.readFileBytes(pickedFile.uri);

        // Backups v3 and v4 are recognized by their file name
        if (pickedFile.name.contains('Openreads-4-')) {
          // ignore: use_build_context_synchronously
          await _restoreBackupVersion4(
            context,
            archiveFile: file,
            tmpPath: tmpDir,
          );
        } else if (pickedFile.name.contains('openreads_3_')) {
          // ignore: use_build_context_synchronously
          await _restoreBackupVersion3(
            context,
            archiveFile: file,
            tmpPath: tmpDir,
          );
        } else {
          // Because file name is not always possible to read
          // backups v5 is recognized by the info.txt file
          final infoFileVersion = _checkInfoFileVersion(file, tmpDir);
          if (infoFileVersion == 5) {
            // ignore: use_build_context_synchronously
            await _restoreBackupVersion5(context, file, tmpDir);
          } else {
            BackupGeneral.showInfoSnackbar(LocaleKeys.backup_not_valid.tr());
            return;
          }
        }
      } else if (Platform.isIOS) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          withData: true,
        );

        final file = result!.files.single;

        // iOS app was released when backup 5 was the latest
        final infoFileVersion = _checkInfoFileVersion(file.bytes, tmpDir);
        if (infoFileVersion == 5) {
          // ignore: use_build_context_synchronously
          await _restoreBackupVersion5(context, file.bytes!, tmpDir);
        } else {
          BackupGeneral.showInfoSnackbar(LocaleKeys.backup_not_valid.tr());
          return;
        }
      } else {
        return;
      }

      BackupGeneral.showInfoSnackbar(LocaleKeys.restore_successfull.tr());

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BooksScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static _restoreBackupVersion5(
    BuildContext context,
    Uint8List archiveBytes,
    Directory tmpPath,
  ) async {
    final decoder = ZipDecoder();
    final archive = decoder.decodeBytes(archiveBytes);

    extractArchiveToDisk(archive, tmpPath.path);

    String? booksData;
    booksData = File('${tmpPath.path}/books.backup').readAsStringSync();

    // First backups of v2 used ||||| as separation between books,
    // That caused problems because this is as well a separator for tags
    // Now @@@@@ is a separator for books but some backups may need below line
    booksData = booksData.replaceAll('}|||||{', '}@@@@@{');

    final bookStrings = booksData.split('@@@@@');

    await bookCubit.removeAllBooks();

    for (var bookString in bookStrings) {
      try {
        final newBook = Book.fromJSON(jsonDecode(bookString));
        File? coverFile;

        if (newBook.hasCover) {
          coverFile = File('${tmpPath.path}/${newBook.id}.jpg');

          // Making sure cover is not stored in the Book object
          newBook.cover = null;
        }

        bookCubit.addBook(
          newBook,
          refreshBooks: false,
          cover: coverFile?.readAsBytesSync(),
        );
      } catch (e) {
        BackupGeneral.showInfoSnackbar(e.toString());
      }
    }

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();

    // No changes in challenges since v4 so we can use the v4 method
    // ignore: use_build_context_synchronously
    await _restoreChallengeTargetsV4(context, tmpPath);
  }

  static _restoreBackupVersion4(
    BuildContext context, {
    String? archivePath,
    Uint8List? archiveFile,
    required Directory tmpPath,
  }) async {
    late Uint8List archiveBytes;

    if (archivePath != null) {
      archiveBytes = File(archivePath).readAsBytesSync();
    } else if (archiveFile != null) {
      archiveBytes = archiveFile;
    } else {
      return;
    }

    final archive = ZipDecoder().decodeBytes(archiveBytes);
    extractArchiveToDisk(archive, tmpPath.path);

    var booksData = File('${tmpPath.path}/books.backup').readAsStringSync();

    // First backups of v2 used ||||| as separation between books,
    // That caused problems because this is as well a separator for tags
    // Now @@@@@ is a separator for books but some backups may need below line
    booksData = booksData.replaceAll('}|||||{', '}@@@@@{');

    final books = booksData.split('@@@@@');
    final booksCount = books.length;
    int restoredBooks = 0;

    context
        .read<BackupProgressCubit>()
        .updateString('$restoredBooks/$booksCount ${LocaleKeys.restored.tr()}');

    await bookCubit.removeAllBooks();

    for (var book in books) {
      try {
        final newBook = Book.fromJSON(jsonDecode(book));

        Uint8List? cover;
        if (newBook.cover != null) {
          cover = newBook.cover;
          newBook.hasCover = true;
          newBook.cover = null;
        }

        bookCubit.addBook(
          newBook,
          refreshBooks: false,
          cover: cover,
        );

        restoredBooks++;

        // ignore: use_build_context_synchronously
        context.read<BackupProgressCubit>().updateString(
            '$restoredBooks/$booksCount ${LocaleKeys.restored.tr()}');
      } catch (e) {
        BackupGeneral.showInfoSnackbar(e.toString());
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();

    // ignore: use_build_context_synchronously
    await _restoreChallengeTargetsV4(context, tmpPath);
  }

  static _restoreBackupVersion3(
    BuildContext context, {
    String? archivePath,
    Uint8List? archiveFile,
    required Directory tmpPath,
  }) async {
    late Uint8List archiveBytes;
    try {
      if (archivePath != null) {
        archiveBytes = File(archivePath).readAsBytesSync();
      } else if (archiveFile != null) {
        archiveBytes = archiveFile;
      } else {
        return;
      }

      final archive = ZipDecoder().decodeBytes(archiveBytes);

      extractArchiveToDisk(archive, tmpPath.path);

      final booksDB = await openDatabase(path.join(tmpPath.path, 'books.sql'));
      final result = await booksDB.query("Book");

      final List<BookFromBackupV3> books = result.isNotEmpty
          ? result.map((item) => BookFromBackupV3.fromJson(item)).toList()
          : [];

      final booksCount = books.length;
      int restoredBooks = 0;

      // ignore: use_build_context_synchronously
      context.read<BackupProgressCubit>().updateString(
          '$restoredBooks/$booksCount ${LocaleKeys.restored.tr()}');

      await bookCubit.removeAllBooks();

      for (var book in books) {
        // ignore: use_build_context_synchronously
        await _addBookFromBackupV3(context, book);

        restoredBooks += 1;
        // ignore: use_build_context_synchronously
        context.read<BackupProgressCubit>().updateString(
            '$restoredBooks/$booksCount ${LocaleKeys.restored.tr()}');
      }

      bookCubit.getAllBooksByStatus();
      bookCubit.getAllBooks();

      // ignore: use_build_context_synchronously
      await _restoreChallengeTargetsFromBackup3(context, tmpPath);

      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static _restoreChallengeTargetsFromBackup3(
      BuildContext context, Directory tmpPath) async {
    if (!context.mounted) return;
    if (!File(path.join(tmpPath.path, 'years.sql')).existsSync()) return;

    final booksDB = await openDatabase(path.join(tmpPath.path, 'years.sql'));
    final result = await booksDB.query("Year");

    final List<YearFromBackupV3>? years = result.isNotEmpty
        ? result.map((item) => YearFromBackupV3.fromJson(item)).toList()
        : null;

    if (!context.mounted) return;
    BlocProvider.of<ChallengeBloc>(context).add(
      const RemoveAllChallengesEvent(),
    );

    String newChallenges = '';

    if (years == null) return;

    for (var year in years) {
      if (newChallenges.isEmpty) {
        if (year.year != null) {
          final newJson = json
              .encode(YearlyChallenge(
                year: int.parse(year.year!),
                books: year.yearChallengeBooks,
                pages: year.yearChallengePages,
              ).toJSON())
              .toString();

          newChallenges = [
            newJson,
          ].join('|||||');
        }
      } else {
        final splittedNewChallenges = newChallenges.split('|||||');

        final newJson = json
            .encode(YearlyChallenge(
              year: int.parse(year.year!),
              books: year.yearChallengeBooks,
              pages: year.yearChallengePages,
            ).toJSON())
            .toString();

        splittedNewChallenges.add(newJson);

        newChallenges = splittedNewChallenges.join('|||||');
      }
    }

    BlocProvider.of<ChallengeBloc>(context).add(
      RestoreChallengesEvent(
        challenges: newChallenges,
      ),
    );
  }

  static Future<void> _addBookFromBackupV3(
      BuildContext context, BookFromBackupV3 book) async {
    final blurHash = await compute(_generateBlurHash, book.bookCoverImg);
    final newBook = Book.fromBookFromBackupV3(book, blurHash);

    Uint8List? cover;
    if (newBook.cover != null) {
      cover = newBook.cover;
      newBook.hasCover = true;
      newBook.cover = null;
    }

    bookCubit.addBook(
      newBook,
      refreshBooks: false,
      cover: cover,
    );
  }

  static String? _generateBlurHash(Uint8List? cover) {
    if (cover == null) return null;

    return blurhash_dart.BlurHash.encode(
      img.decodeImage(cover)!,
      numCompX: Constants.blurHashX,
      numCompY: Constants.blurHashY,
    ).hash;
  }

  static _restoreChallengeTargetsV4(
    BuildContext context,
    Directory tmpPath,
  ) async {
    if (!context.mounted) return;

    if (File('${tmpPath.path}/challenges.backup').existsSync()) {
      final challengesData =
          File('${tmpPath.path}/challenges.backup').readAsStringSync();

      BlocProvider.of<ChallengeBloc>(context).add(
        const RemoveAllChallengesEvent(),
      );

      BlocProvider.of<ChallengeBloc>(context).add(
        RestoreChallengesEvent(
          challenges: challengesData,
        ),
      );
    } else {
      BlocProvider.of<ChallengeBloc>(context).add(
        const RemoveAllChallengesEvent(),
      );
    }
  }

  // Open the info.txt file and check the backup version
  static int? _checkInfoFileVersion(Uint8List? backupFile, Directory tmpDir) {
    if (backupFile == null) return null;

    final archive = ZipDecoder().decodeBytes(backupFile);
    extractArchiveToDisk(archive, tmpDir.path);

    final infoFile = File('${tmpDir.path}/info.txt');
    if (!infoFile.existsSync()) return null;

    final infoFileContent = infoFile.readAsStringSync();
    final infoFileContentSplitted = infoFileContent.split('\n');

    if (infoFileContentSplitted.isEmpty) return null;

    final infoFileVersion = infoFileContentSplitted[1].split(': ')[1];

    return int.tryParse(infoFileVersion);
  }

  static _deleteTmpData(Directory tmpDir) {
    if (File('${tmpDir.path}/books.backup').existsSync()) {
      File('${tmpDir.path}/books.backup').deleteSync();
    }

    if (File('${tmpDir.path}/challenges.backup').existsSync()) {
      File('${tmpDir.path}/challenges.backup').deleteSync();
    }
  }
}
