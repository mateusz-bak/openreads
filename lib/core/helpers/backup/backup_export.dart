import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:archive/archive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:share_plus/share_plus.dart';

class BackupExport {
  static createLocalBackupLegacyStorage(BuildContext context) async {
    final tmpBackupPath = await prepareTemporaryBackup(context);
    if (tmpBackupPath == null) return;

    try {
      // ignore: use_build_context_synchronously
      final backupPath = await BackupGeneral.openFolderPicker(context);
      final fileName = await _prepareBackupFileName();

      final filePath = '$backupPath/$fileName';

      File(filePath).writeAsBytesSync(File(tmpBackupPath).readAsBytesSync());

      BackupGeneral.showInfoSnackbar(LocaleKeys.backup_successfull.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future createLocalBackup(BuildContext context) async {
    final tmpBackupPath = await prepareTemporaryBackup(context);
    if (tmpBackupPath == null) return;

    final fileName = await _prepareBackupFileName();

    try {
      if (Platform.isAndroid) {
        final safStream = SafStream();
        final safUtil = SafUtil();

        final selectedDirectory = await safUtil.pickDirectory(
          writePermission: true,
        );

        await safStream.writeFileBytes(
          selectedDirectory!.uri,
          fileName,
          'application/zip',
          File(tmpBackupPath).readAsBytesSync(),
        );
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';

        File(path).writeAsBytesSync(
          File(tmpBackupPath).readAsBytesSync(),
        );
        await Share.shareXFiles([XFile(path)]);
      }

      BackupGeneral.showInfoSnackbar(LocaleKeys.backup_successfull.tr());
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());
    }
  }

  static Future<String?> prepareTemporaryBackup(BuildContext context) async {
    try {
      await bookCubit.getAllBooks(getTags: false, getAuthors: false);

      final books = await bookCubit.allBooks.first;
      final listOfBookJSONs = List<String>.empty(growable: true);
      final coverFiles = List<File>.empty(growable: true);

      for (var book in books) {
        // Making sure no covers are stored as JSON
        final bookWithCoverNull = book.copyWithNullCover();

        listOfBookJSONs.add(jsonEncode(bookWithCoverNull.toJSON()));

        // Creating a list of current cover files
        if (book.hasCover) {
          // Check if cover file exists, if not then skip
          if (!File('${appDocumentsDirectory.path}/${book.id}.jpg')
              .existsSync()) {
            continue;
          }

          final coverFile = File(
            '${appDocumentsDirectory.path}/${book.id}.jpg',
          );
          coverFiles.add(coverFile);
        }

        await Future.delayed(const Duration(milliseconds: 50));
      }

      // ignore: use_build_context_synchronously
      final challengeTargets = await _getChallengeTargets(context);

      // ignore: use_build_context_synchronously
      return await _writeTempBackupFile(
        listOfBookJSONs,
        challengeTargets,
        coverFiles,
      );
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static Future<String?> _getChallengeTargets(BuildContext context) async {
    if (!context.mounted) return null;

    final state = BlocProvider.of<ChallengeBloc>(context).state;

    if (state is SetChallengeState) {
      return state.yearlyChallenges;
    }

    return null;
  }

  // Current backup version: 5
  static Future<String?> _writeTempBackupFile(
    List<String> listOfBookJSONs,
    String? challengeTargets,
    List<File>? coverFiles,
  ) async {
    final data = listOfBookJSONs.join('@@@@@');
    final fileName = await _prepareBackupFileName();
    final tmpFilePath = '${appTempDirectory.path}/$fileName';

    try {
      // Saving books to temp file
      File('${appTempDirectory.path}/books.backup').writeAsStringSync(data);

      // Reading books temp file to memory
      final booksBytes =
          File('${appTempDirectory.path}/books.backup').readAsBytesSync();

      final archivedBooks = ArchiveFile(
        'books.backup',
        booksBytes.length,
        booksBytes,
      );

      // Prepare main archive
      final archive = Archive();
      archive.addFile(archivedBooks);

      if (challengeTargets != null) {
        // Saving challenges to temp file
        File('${appTempDirectory.path}/challenges.backup')
            .writeAsStringSync(challengeTargets);

        // Reading challenges temp file to memory
        final challengeTargetsBytes =
            File('${appTempDirectory.path}/challenges.backup')
                .readAsBytesSync();

        final archivedChallengeTargets = ArchiveFile(
          'challenges.backup',
          challengeTargetsBytes.length,
          challengeTargetsBytes,
        );

        archive.addFile(archivedChallengeTargets);
      }

      // Adding covers to the backup file
      if (coverFiles != null && coverFiles.isNotEmpty) {
        for (var coverFile in coverFiles) {
          final coverBytes = coverFile.readAsBytesSync();

          final archivedCover = ArchiveFile(
            coverFile.path.split('/').last,
            coverBytes.length,
            coverBytes,
          );

          archive.addFile(archivedCover);
        }
      }

      // Add info file
      final info = await _prepareBackupInfo();
      final infoBytes = utf8.encode(info);

      final archivedInfo = ArchiveFile(
        'info.txt',
        infoBytes.length,
        infoBytes,
      );
      archive.addFile(archivedInfo);

      final encoder = ZipEncoder();

      final encodedArchive = encoder.encode(archive);

      File(tmpFilePath).writeAsBytesSync(encodedArchive);

      return tmpFilePath;
    } catch (e) {
      BackupGeneral.showInfoSnackbar(e.toString());

      return null;
    }
  }

  static Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  static Future<String> _prepareBackupFileName() async {
    final date = DateTime.now();
    final backupDate =
        '${date.year}_${date.month}_${date.day}-${date.hour}_${date.minute}_${date.second}';

    return 'Openreads-$backupDate.backup';
  }

  static Future<String> _prepareBackupInfo() async {
    final appVersion = await _getAppVersion();

    return 'App version: $appVersion\nBackup version: 5';
  }
}
