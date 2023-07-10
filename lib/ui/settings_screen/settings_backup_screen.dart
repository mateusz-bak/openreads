import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/logic/bloc/migration_v1_to_v2_bloc/migration_v1_to_v2_bloc.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/year_from_backup_v3.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:openreads/ui/welcome_screen/widgets/widgets.dart';
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

class SettingsBackupScreen extends StatefulWidget {
  SettingsBackupScreen({
    super.key,
    this.autoMigrationV1ToV2 = false,
  });

  bool autoMigrationV1ToV2;

  @override
  State<SettingsBackupScreen> createState() => _SettingsBackupScreenState();
}

class _SettingsBackupScreenState extends State<SettingsBackupScreen> {
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
          LocaleKeys.need_storage_permission.tr(),
        ),
        action: SnackBarAction(
          label: LocaleKeys.open_settings.tr(),
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
            LocaleKeys.backup_successfull.tr(),
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
      title: LocaleKeys.choose_backup_folder.tr(),
      pickText: LocaleKeys.save_file_to_this_folder.tr(),
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
        mimeType: '',
        displayName: fileName,
        bytes: File(tmpBackupPath).readAsBytesSync(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.backup_successfull.tr(),
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
            LocaleKeys.backup_not_valid.tr(),
          ),
        ),
      );
    }

    setState(() => _restoringLocal = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocaleKeys.restore_successfull.tr(),
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
              LocaleKeys.backup_not_valid.tr(),
            ),
          ),
        );

        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.restore_successfull.tr(),
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
          '${LocaleKeys.restored.tr()} $booksBackupDone/$booksBackupLenght\n';
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
      title: LocaleKeys.choose_backup_file.tr(),
      pickText: LocaleKeys.use_this_file.tr(),
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

  _startMigrationV1ToV2() {
    BlocProvider.of<MigrationV1ToV2Bloc>(context).add(
      StartMigration(context: context, retrigger: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.backup.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                late final bool amoledDark;

                if (state is SetThemeState) {
                  amoledDark = state.amoledDark;
                } else {
                  amoledDark = false;
                }

                return SettingsList(
                  contentPadding: const EdgeInsets.only(top: 10),
                  darkTheme: SettingsThemeData(
                    settingsListBackground: amoledDark
                        ? Colors.black
                        : Theme.of(context).colorScheme.surface,
                  ),
                  lightTheme: SettingsThemeData(
                    settingsListBackground:
                        Theme.of(context).colorScheme.surface,
                  ),
                  sections: [
                    SettingsSection(
                      tiles: <SettingsTile>[
                        SettingsTile(
                          title: Text(
                            LocaleKeys.create_local_backup.tr(),
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
                            LocaleKeys.create_local_backup_description.tr(),
                          ),
                          onPressed: _startLocalBackup,
                        ),
                        SettingsTile(
                          title: Text(
                            LocaleKeys.create_cloud_backup.tr(),
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
                            LocaleKeys.create_cloud_backup_description.tr(),
                          ),
                          onPressed: _startCloudBackup,
                        ),
                        SettingsTile(
                          title: Text(
                            LocaleKeys.restore_backup.tr(),
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
                                '${LocaleKeys.restore_backup_description_1.tr()}\n${LocaleKeys.restore_backup_description_2.tr()}',
                              ),
                            ],
                          ),
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Builder(builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      LocaleKeys.are_you_sure.tr(),
                                    ),
                                    content: Text(
                                      LocaleKeys.restore_backup_alert_content
                                          .tr(),
                                    ),
                                    actionsAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    actions: [
                                      FilledButton.tonal(
                                        onPressed: () {
                                          _startLocalRestore(context);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(LocaleKeys.yes.tr()),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(LocaleKeys.no.tr()),
                                      ),
                                    ],
                                  );
                                });
                              },
                            );
                          },
                        ),
                        SettingsTile(
                          title: Text(
                            LocaleKeys.migration_v1_to_v2_retrigger.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.autoMigrationV1ToV2
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          leading: Icon(
                            FontAwesomeIcons.wrench,
                            color: widget.autoMigrationV1ToV2
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          description: Text(
                            LocaleKeys.migration_v1_to_v2_retrigger_description
                                .tr(),
                            style: TextStyle(
                              color: widget.autoMigrationV1ToV2
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    LocaleKeys.are_you_sure.tr(),
                                  ),
                                  content: Text(
                                    LocaleKeys.restore_backup_alert_content
                                        .tr(),
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  actions: [
                                    FilledButton.tonal(
                                      onPressed: () {
                                        _startMigrationV1ToV2();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(LocaleKeys.yes.tr()),
                                    ),
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(LocaleKeys.no.tr()),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          BlocBuilder<MigrationV1ToV2Bloc, MigrationV1ToV2State>(
            builder: (context, migrationState) {
              if (migrationState is MigrationOnging) {
                return MigrationNotification(
                  done: migrationState.done,
                  total: migrationState.total,
                );
              } else if (migrationState is MigrationFailed) {
                return MigrationNotification(
                  error: migrationState.error,
                );
              } else if (migrationState is MigrationSucceded) {
                return const MigrationNotification(
                  success: true,
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
