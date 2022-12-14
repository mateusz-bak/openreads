import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _creatingLocal = false;
  bool _creatingCloud = false;
  bool _restoringLocal = false;

  _startLocalBackup(context) async {
    setState(() => _creatingLocal = true);

    if (await Permission.storage.isPermanentlyDenied) {
      _openSystemSettings();
    } else if (await Permission.storage.status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        await _createLocalBackup();
      } else {
        _openSystemSettings();
      }
    } else if (await Permission.storage.status.isGranted) {
      await _createLocalBackup();
    }

    setState(() => _creatingLocal = false);
  }

  _openSystemSettings() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You need to grant storage permission'),
        action: SnackBarAction(
          label: 'Open settings',
          onPressed: () {
            if (mounted) {
              openAppSettings();
            }
          },
        ),
      ),
    );
  }

  _createLocalBackup() async {
    await bookCubit.getAllBooks(tags: true);

    final books = await bookCubit.allBooks.first;
    final backedBooks = List<String>.empty(growable: true);

    for (var book in books) {
      backedBooks.add(jsonEncode(book.toJSON()));
    }

    final challengeTargets = await _getChallengeTargets();

    try {
      await _writeBackupFile(backedBooks, challengeTargets);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup succesfull')),
      );
    } catch (e) {
      setState(() => _creatingLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<String?> _getChallengeTargets() async {
    if (!mounted) return null;

    final state = BlocProvider.of<ChallengeBloc>(context).state;

    if (state is SetChallengeState) {
      return state.yearlyChallenges;
    }

    return null;
  }

  _writeBackupFile(List<String> list, String? challengeTargets) async {
    final data = list.join('|||||');
    final backupPath = await _openFolderPicker();
    final tmpPath = (await getApplicationSupportDirectory()).absolute;

    final date = DateTime.now();
    final backupDate =
        '${date.year}-${date.month}-${date.day}_${date.hour}-${date.minute}-${date.second}';
    final filePath = '$backupPath/Openreads_4_2.0.0_$backupDate.backup';

    try {
      File('${tmpPath.path}/books.tmp').writeAsStringSync(data);

      final booksBytes = File('${tmpPath.path}/books.tmp').readAsBytesSync();
      final archivedBooks = ArchiveFile(
        'books.tmp',
        booksBytes.length,
        booksBytes,
      );

      final archive = Archive();
      archive.addFile(archivedBooks);

      if (challengeTargets != null) {
        File('${tmpPath.path}/challenges.tmp')
            .writeAsStringSync(challengeTargets);
        final challengeTargetsBytes =
            File('${tmpPath.path}/challenges.tmp').readAsBytesSync();
        final archivedChallengeTargets = ArchiveFile(
          'challenges.tmp',
          challengeTargetsBytes.length,
          challengeTargetsBytes,
        );

        archive.addFile(archivedChallengeTargets);
      }

      final encodedArchive = ZipEncoder().encode(archive);

      if (encodedArchive == null) return;

      File(filePath).writeAsBytesSync(encodedArchive);

      if (File('${tmpPath.path}/books.tmp').existsSync()) {
        File('${tmpPath.path}/books.tmp').deleteSync();
      }

      if (File('${tmpPath.path}/challenges.tmp').existsSync()) {
        File('${tmpPath.path}/challenges.tmp').deleteSync();
      }
    } catch (e) {
      setState(() => _creatingLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<String?> _openFolderPicker() async {
    return await FilesystemPicker.open(
      context: context,
      title: 'Choose backup folder',
      pickText: 'Save file to this folder',
      fsType: FilesystemType.folder,
      rootDirectory: Directory('/storage/emulated/0/'),
      contextActions: [
        FilesystemPickerNewFolderContextAction(
          icon: Icon(
            Icons.create_new_folder,
            color: Theme.of(context).mainTextColor,
            size: 24,
          ),
        ),
      ],
      theme: FilesystemPickerTheme(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        pickerAction: FilesystemPickerActionThemeData(
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        fileList: FilesystemPickerFileListThemeData(
          iconSize: 24,
          upIconSize: 24,
          checkIconSize: 24,
          folderTextStyle: const TextStyle(fontSize: 16),
        ),
        topBar: FilesystemPickerTopBarThemeData(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).mainTextColor,
          titleTextStyle: const TextStyle(fontSize: 18),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  _startLocalRestore(context) async {
    setState(() => _restoringLocal = true);

    if (await Permission.storage.isPermanentlyDenied) {
      _openSystemSettings();
    } else if (await Permission.storage.status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        await _restoreLocalBackup();
      } else {
        _openSystemSettings();
      }
    } else if (await Permission.storage.status.isGranted) {
      await _restoreLocalBackup();
    }

    setState(() => _restoringLocal = false);
  }

  _restoreLocalBackup() async {
    final tmpPath = (await getApplicationSupportDirectory()).absolute;

    if (File('${tmpPath.path}/books.tmp').existsSync()) {
      File('${tmpPath.path}/books.tmp').deleteSync();
    }

    if (File('${tmpPath.path}/challenges.tmp').existsSync()) {
      File('${tmpPath.path}/challenges.tmp').deleteSync();
    }

    try {
      final archivePath = await _openFilePicker();
      if (archivePath == null) return;

      final archiveBytes = File(archivePath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(archiveBytes);

      extractArchiveToDisk(archive, tmpPath.path);

      final booksData = File('${tmpPath.path}/books.tmp').readAsStringSync();
      final books = booksData.split('|||||');

      await bookCubit.removeAllBooks();

      for (var book in books) {
        bookCubit.addBook(Book.fromJSON(jsonDecode(book)));
      }

      await _restoreChallengeTargets(tmpPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restoration succesfull')),
      );
    } catch (e) {
      setState(() => _restoringLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  _restoreChallengeTargets(Directory tmpPath) async {
    if (!mounted) return;

    if (File('${tmpPath.path}/challenges.tmp').existsSync()) {
      final challengesData =
          File('${tmpPath.path}/challenges.tmp').readAsStringSync();

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

  Future<String?> _openFilePicker() async {
    return await FilesystemPicker.open(
      context: context,
      title: 'Choose backup file',
      pickText: 'Use this file',
      fsType: FilesystemType.file,
      rootDirectory: Directory('/storage/emulated/0/'),
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      allowedExtensions: ['.backup'],
      theme: FilesystemPickerTheme(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        pickerAction: FilesystemPickerActionThemeData(
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        fileList: FilesystemPickerFileListThemeData(
          iconSize: 24,
          upIconSize: 24,
          checkIconSize: 24,
          folderTextStyle: const TextStyle(fontSize: 16),
        ),
        topBar: FilesystemPickerTopBarThemeData(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).mainTextColor,
          titleTextStyle: const TextStyle(fontSize: 18),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Backup'),
      ),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text(
                  'Create local backup',
                  style: TextStyle(fontSize: 16),
                ),
                leading: (_creatingLocal)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.copy),
                description: const Text('Backup books to your device'),
                onPressed: _startLocalBackup,
              ),
              // SettingsTile(
              //   title: const Text(
              //     'Create cloud backup',
              //     style: TextStyle(fontSize: 16),
              //   ),
              //   leading: const Icon(Icons.backup),
              //   description: const Text('Backup books to the cloud'),
              //   onPressed: (context) {},
              // ),
              SettingsTile(
                title: const Text(
                  'Restore backup',
                  style: TextStyle(fontSize: 16),
                ),
                leading: (_restoringLocal)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(Icons.restore_outlined),
                description: const Text('Restore books from your device'),
                onPressed: _startLocalRestore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
