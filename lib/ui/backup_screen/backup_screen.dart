import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/year_from_backup_v3.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
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

    if (await _handlePermission()) {
      await _createLocalBackup();
    }

    setState(() => _creatingLocal = false);
  }

  _startCloudBackup(context) async {
    setState(() => _creatingCloud = true);

    await bookCubit.getAllBooks(tags: true);

    final books = await bookCubit.allBooks.first;
    final backedBooks = List<String>.empty(growable: true);

    for (var book in books) {
      backedBooks.add(jsonEncode(book.toJSON()));
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final challengeTargets = await _getChallengeTargets();

    final tmpBackupPath = await _writeTempBackupFile(
      backedBooks,
      challengeTargets,
    );

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
          style: TextStyle(
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
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
    await bookCubit.getAllBooks(tags: true);

    final books = await bookCubit.allBooks.first;
    final backedBooks = List<String>.empty(growable: true);

    for (var book in books) {
      backedBooks.add(jsonEncode(book.toJSON()));
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final challengeTargets = await _getChallengeTargets();

    try {
      final tmpBackupPath = await _writeTempBackupFile(
        backedBooks,
        challengeTargets,
      );

      if (tmpBackupPath == null) return;

      final backupPath = await _openFolderPicker();
      final date = DateTime.now();
      final backupDate =
          '${date.year}_${date.month}_${date.day}-${date.hour}_${date.minute}_${date.second}';
      const appVersion = '2_0_0';

      final filePath = '$backupPath/Openreads-4-$appVersion-$backupDate.backup';

      File(filePath).writeAsBytesSync(File(tmpBackupPath).readAsBytesSync());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.backup_successfull,
            style: TextStyle(
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
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
            style: TextStyle(
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
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

    final date = DateTime.now();
    final backupDate =
        '${date.year}_${date.month}_${date.day}-${date.hour}_${date.minute}_${date.second}';

    const appVersion = '2_0_0';

    final tmpFilePath =
        '${tmpDir.path}/Openreads-4-$appVersion-$backupDate.backup';

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
            style: TextStyle(
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
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

  Future<bool> _handlePermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt <= 31) {
      return await _requestStoragePermission();
    } else {
      return await _requestManageExternalStoragePermission();
    }
  }

  Future<bool> _requestManageExternalStoragePermission() async {
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      _openSystemSettings();
      return false;
    } else if (await Permission.manageExternalStorage.status.isDenied) {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else {
        _openSystemSettings();
        return false;
      }
    } else if (await Permission.manageExternalStorage.status.isGranted) {
      return true;
    }
    return false;
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

    if (await _handlePermission()) {
      await _restoreLocalBackup();
    }

    setState(() => _restoringLocal = false);
  }

  _restoreLocalBackup() async {
    final tmpPath = (await getApplicationSupportDirectory()).absolute;

    if (File('${tmpPath.path}/books.backup').existsSync()) {
      File('${tmpPath.path}/books.backup').deleteSync();
    }

    if (File('${tmpPath.path}/challenges.backup').existsSync()) {
      File('${tmpPath.path}/challenges.backup').deleteSync();
    }

    try {
      final archivePath = await _openFilePicker();
      if (archivePath == null) return;

      if (archivePath.contains('Openreads-4-')) {
        await restoreBackupVersion4(archivePath, tmpPath);
      } else if (archivePath.contains('openreads_3_')) {
        await restoreBackupVersion3(archivePath, tmpPath);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.backup_not_valid,
              style: TextStyle(
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
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
            style: TextStyle(
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
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
            style: TextStyle(
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
          ),
        ),
      );
    }
  }

  restoreBackupVersion4(String archivePath, Directory tmpPath) async {
    final archiveBytes = File(archivePath).readAsBytesSync();
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
              style: TextStyle(
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
            ),
          ),
        );
      }
    }

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();

    await _restoreChallengeTargetsV4(tmpPath);
  }

  restoreBackupVersion3(String archivePath, Directory tmpPath) async {
    final archiveBytes = File(archivePath).readAsBytesSync();
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
        title: Text(
          l10n.backup,
          style: TextStyle(
            fontSize: 18,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
        ),
      ),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text(
                  l10n.create_local_backup,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: context.read<ThemeBloc>().fontFamily,
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
                  style: TextStyle(
                    fontFamily: context.read<ThemeBloc>().fontFamily,
                  ),
                ),
                onPressed: _startLocalBackup,
              ),
              SettingsTile(
                title: Text(
                  l10n.create_cloud_backup,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: context.read<ThemeBloc>().fontFamily,
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
                  style: TextStyle(
                    fontFamily: context.read<ThemeBloc>().fontFamily,
                  ),
                ),
                onPressed: _startCloudBackup,
              ),
              SettingsTile(
                title: Text(
                  l10n.restore_backup,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: context.read<ThemeBloc>().fontFamily,
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: context.read<ThemeBloc>().fontFamily,
                            ),
                          )
                        : const SizedBox(),
                    Text(
                      '${l10n.restore_backup_description_1}\n${l10n.restore_backup_description_2}',
                      style: TextStyle(
                        fontFamily: context.read<ThemeBloc>().fontFamily,
                      ),
                    ),
                  ],
                ),
                onPressed: _startLocalRestore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
