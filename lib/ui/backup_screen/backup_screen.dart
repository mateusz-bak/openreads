import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/year_from_backup_v3.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_storage/shared_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _creatingLocal = false;
  bool _creatingCloud = false;
  bool _restoringLocal = false;
  int booksBackupLenght = 0;
  int booksBackupDone = 0;
  String restoredCounterText = '';

  _startLocalBackup(context) async {
    setState(() => _creatingLocal = true);

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt <= 31) {
      await _requestStoragePermission();
      await _createLocalBackup();
    } else {
      await _createLocalBackupWithScopedStorage();
    }

    setState(() => _creatingLocal = false);
  }

  _startCloudBackup(context) async {
    setState(() => _creatingCloud = true);

    final tmpBackupPath = await _prepareTemporaryBackup();
    if (tmpBackupPath == null) return;

    Share.shareXFiles([
      XFile(tmpBackupPath),
    ]);

    setState(() => _creatingCloud = false);
  }

  _openSystemSettings() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.need_storage_permission,
        ),
        action: SnackBarAction(
          label: l10n.open_settings,
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
    final tmpBackupPath = await _prepareTemporaryBackup();
    if (tmpBackupPath == null) return;

    try {
      final backupPath = await _openFolderPicker();
      final fileName = await _prepareBackupFileName();

      final filePath = '$backupPath/$fileName';

      File(filePath).writeAsBytesSync(File(tmpBackupPath).readAsBytesSync());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backup_successfull,
          ),
        ),
      );
    } catch (e) {
      setState(() => _creatingLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
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

  Future<String?> _writeTempBackupFile(
      List<String> list, String? challengeTargets) async {
    final data = list.join('@@@@@');

    final tmpDir = await getApplicationSupportDirectory();

    final fileName = await _prepareBackupFileName();

    final tmpFilePath = '${tmpDir.path}/$fileName';

    try {
      File('${tmpDir.path}/books.backup').writeAsStringSync(data);

      final booksBytes = File('${tmpDir.path}/books.backup').readAsBytesSync();

      final archivedBooks = ArchiveFile(
        'books.backup',
        booksBytes.length,
        booksBytes,
      );

      final archive = Archive();
      archive.addFile(archivedBooks);

      if (challengeTargets != null) {
        File('${tmpDir.path}/challenges.backup')
            .writeAsStringSync(challengeTargets);

        final challengeTargetsBytes =
            File('${tmpDir.path}/challenges.backup').readAsBytesSync();

        final archivedChallengeTargets = ArchiveFile(
          'challenges.backup',
          challengeTargetsBytes.length,
          challengeTargetsBytes,
        );

        archive.addFile(archivedChallengeTargets);
      }

      final encodedArchive = ZipEncoder().encode(archive);

      if (encodedArchive == null) return null;

      File(tmpFilePath).writeAsBytesSync(encodedArchive);

      return tmpFilePath;
    } catch (e) {
      setState(() => _creatingLocal = false);
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

      return null;
    }
  }

  Future<String?> _openFolderPicker() async {
    return await FilesystemPicker.open(
      context: context,
      title: l10n.choose_backup_folder,
      pickText: l10n.save_file_to_this_folder,
      fsType: FilesystemType.folder,
      rootDirectory: Directory('/storage/emulated/0/'),
      contextActions: [
        FilesystemPickerNewFolderContextAction(
          icon: Icon(
            Icons.create_new_folder,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
      ],
      theme: FilesystemPickerTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
        pickerAction: FilesystemPickerActionThemeData(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        fileList: FilesystemPickerFileListThemeData(
          iconSize: 24,
          upIconSize: 24,
          checkIconSize: 24,
          folderTextStyle: const TextStyle(fontSize: 16),
        ),
        topBar: FilesystemPickerTopBarThemeData(
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleTextStyle: const TextStyle(fontSize: 18),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Future<String?> _prepareTemporaryBackup() async {
    try {
      await bookCubit.getAllBooks(tags: true);

      final books = await bookCubit.allBooks.first;
      final backedBooks = List<String>.empty(growable: true);

      for (var book in books) {
        backedBooks.add(jsonEncode(book.toJSON()));
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final challengeTargets = await _getChallengeTargets();

      return await _writeTempBackupFile(
        backedBooks,
        challengeTargets,
      );
    } catch (e) {
      setState(() => _creatingLocal = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

      return null;
    }
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  Future<String> _prepareBackupFileName() async {
    final date = DateTime.now();
    final backupDate =
        '${date.year}_${date.month}_${date.day}-${date.hour}_${date.minute}_${date.second}';
    final appVersion = await _getAppVersion();

    return 'Openreads-4-$appVersion-$backupDate.backup';
  }

  Future _createLocalBackupWithScopedStorage() async {
    final tmpBackupPath = await _prepareTemporaryBackup();
    if (tmpBackupPath == null) return;

    final selectedUriDir = await openDocumentTree();

    if (selectedUriDir == null) {
      setState(() => _creatingLocal = false);
      return;
    }

    final fileName = await _prepareBackupFileName();

    try {
      createFileAsBytes(
        selectedUriDir,
        mimeType: 'application/zip',
        displayName: fileName,
        bytes: File(tmpBackupPath).readAsBytesSync(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backup_successfull,
          ),
        ),
      );
    } catch (e) {
      setState(() => _creatingLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  _deleteTmpData(Directory tmpDir) {
    if (File('${tmpDir.path}/books.backup').existsSync()) {
      File('${tmpDir.path}/books.backup').deleteSync();
    }

    if (File('${tmpDir.path}/challenges.backup').existsSync()) {
      File('${tmpDir.path}/challenges.backup').deleteSync();
    }
  }

  Future _restoreLocalBackupWithScopedStorage() async {
    final tmpDir = (await getApplicationSupportDirectory()).absolute;
    _deleteTmpData(tmpDir);

    final selectedUris = await openDocument(multiple: false);

    if (selectedUris == null || selectedUris.isEmpty) {
      setState(() => _restoringLocal = false);
      return;
    }

    final selectedUriDir = selectedUris[0];
    final backupFile = await getDocumentContent(selectedUriDir);

    if (selectedUriDir.path.contains('Openreads-4-')) {
      await restoreBackupVersion4(archiveFile: backupFile, tmpPath: tmpDir);
    } else if (selectedUriDir.path.contains('openreads_3_')) {
      await restoreBackupVersion3(archiveFile: backupFile, tmpPath: tmpDir);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backup_not_valid,
          ),
        ),
      );
    }

    setState(() => _restoringLocal = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.restore_successfull,
        ),
      ),
    );

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.isPermanentlyDenied) {
      _openSystemSettings();
      return false;
    } else if (await Permission.storage.status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        _openSystemSettings();
        return false;
      }
    } else if (await Permission.storage.status.isGranted) {
      return true;
    }
    return false;
  }

  _startLocalRestore(context) async {
    setState(() => _restoringLocal = true);

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt <= 31) {
      await _requestStoragePermission();
      await _restoreLocalBackup();
    } else {
      await _restoreLocalBackupWithScopedStorage();
    }

    setState(() => _restoringLocal = false);
  }

  _restoreLocalBackup() async {
    final tmpDir = (await getApplicationSupportDirectory()).absolute;
    _deleteTmpData(tmpDir);

    try {
      final archivePath = await _openFilePicker();
      if (archivePath == null) return;

      if (archivePath.contains('Openreads-4-')) {
        await restoreBackupVersion4(archivePath: archivePath, tmpPath: tmpDir);
      } else if (archivePath.contains('openreads_3_')) {
        await restoreBackupVersion3(archivePath: archivePath, tmpPath: tmpDir);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.backup_not_valid,
            ),
          ),
        );

        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.restore_successfull,
          ),
        ),
      );

      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _restoringLocal = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  restoreBackupVersion4({
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
      setState(() => _restoringLocal = false);

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

    await bookCubit.removeAllBooks();

    for (var book in books) {
      try {
        bookCubit.addBook(
          Book.fromJSON(jsonDecode(book)),
          refreshBooks: false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );

        setState(() => _restoringLocal = false);
      }
    }

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();

    await _restoreChallengeTargetsV4(tmpPath);
  }

  restoreBackupVersion3({
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
      setState(() => _restoringLocal = false);

      return;
    }

    final archive = ZipDecoder().decodeBytes(archiveBytes);

    extractArchiveToDisk(archive, tmpPath.path);

    final booksDB = await openDatabase(path.join(tmpPath.path, 'books.sql'));
    final result = await booksDB.query("Book");

    final List<BookFromBackupV3> books = result.isNotEmpty
        ? result.map((item) => BookFromBackupV3.fromJson(item)).toList()
        : [];

    booksBackupLenght = books.length;
    booksBackupDone = 0;

    await bookCubit.removeAllBooks();

    for (var book in books) {
      await _addBookFromBackupV3(book);
    }

    setState(() {
      restoredCounterText = '';
    });

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();

    await _restoreChallengeTargetsFromBackup3(tmpPath);
  }

  _restoreChallengeTargetsFromBackup3(Directory tmpPath) async {
    if (!mounted) return;
    if (!File(path.join(tmpPath.path, 'years.sql')).existsSync()) return;

    final booksDB = await openDatabase(path.join(tmpPath.path, 'years.sql'));
    final result = await booksDB.query("Year");

    final List<YearFromBackupV3>? years = result.isNotEmpty
        ? result.map((item) => YearFromBackupV3.fromJson(item)).toList()
        : null;

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

  Future<void> _addBookFromBackupV3(BookFromBackupV3 book) async {
    final blurHash = await compute(_generateBlurHash, book.bookCoverImg);
    final newBook = Book.fromBookFromBackupV3(book, blurHash);

    bookCubit.addBook(newBook, refreshBooks: false);
    booksBackupDone = booksBackupDone + 1;

    if (!mounted) return;

    setState(() {
      restoredCounterText =
          '${l10n.restored} $booksBackupDone/$booksBackupLenght\n';
    });
  }

  static String? _generateBlurHash(Uint8List? cover) {
    if (cover == null) return null;

    return blurhash_dart.BlurHash.encode(
      img.decodeImage(cover)!,
      numCompX: 4,
      numCompY: 3,
    ).hash;
  }

  _restoreChallengeTargetsV4(Directory tmpPath) async {
    if (!mounted) return;

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

  Future<String?> _openFilePicker() async {
    return await FilesystemPicker.open(
      context: context,
      title: l10n.choose_backup_file,
      pickText: l10n.use_this_file,
      fsType: FilesystemType.file,
      rootDirectory: Directory('/storage/emulated/0/'),
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      allowedExtensions: ['.backup', '.zip', '.png'],
      theme: FilesystemPickerTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
        fileList: FilesystemPickerFileListThemeData(
          iconSize: 24,
          upIconSize: 24,
          checkIconSize: 24,
          folderTextStyle: const TextStyle(fontSize: 16),
        ),
        topBar: FilesystemPickerTopBarThemeData(
          titleTextStyle: const TextStyle(fontSize: 18),
          shadowColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.backup,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 10),
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.surface,
        ),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text(
                  l10n.create_local_backup,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                leading: (_creatingLocal)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(FontAwesomeIcons.solidFloppyDisk),
                description: Text(
                  l10n.create_local_backup_description,
                ),
                onPressed: _startLocalBackup,
              ),
              SettingsTile(
                title: Text(
                  l10n.create_cloud_backup,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                leading: (_creatingCloud)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(FontAwesomeIcons.cloudArrowUp),
                description: Text(
                  l10n.create_cloud_backup_description,
                ),
                onPressed: _startCloudBackup,
              ),
              SettingsTile(
                title: Text(
                  l10n.restore_backup,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                leading: (_restoringLocal)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Icon(FontAwesomeIcons.arrowUpFromBracket),
                description: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    restoredCounterText.isNotEmpty
                        ? Text(
                            restoredCounterText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox(),
                    Text(
                      '${l10n.restore_backup_description_1}\n${l10n.restore_backup_description_2}',
                    ),
                  ],
                ),
                onPressed: (context) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            l10n.are_you_sure,
                          ),
                          content: Text(
                            l10n.restore_backup_alert_content,
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            FilledButton.tonal(
                              onPressed: () {
                                _startLocalRestore(context);
                                Navigator.of(context).pop();
                              },
                              child: Text(l10n.yes),
                            ),
                            FilledButton.tonal(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.no),
                            ),
                          ],
                        );
                      });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
