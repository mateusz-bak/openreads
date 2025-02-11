import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/settings_screen/download_missing_covers_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openreads/generated/locale_keys.g.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

class BackupGeneral {
  static showInfoSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (await Permission.storage.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously
      _openSystemSettings(context);
      return false;
    } else if (await Permission.storage.status.isDenied) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        // ignore: use_build_context_synchronously
        _openSystemSettings(context);
        return false;
      }
    } else if (await Permission.storage.status.isGranted) {
      return true;
    }
    return false;
  }

  static Future<String?> openFolderPicker(BuildContext context) async {
    if (!context.mounted) return null;

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

  static Future<String?> openFilePicker(
    BuildContext context, {
    List<String> allowedExtensions = const ['.backup', '.zip', '.png'],
  }) async {
    if (!context.mounted) return null;

    return await FilesystemPicker.open(
      context: context,
      title: LocaleKeys.choose_backup_file.tr(),
      pickText: LocaleKeys.use_this_file.tr(),
      fsType: FilesystemType.file,
      rootDirectory: Directory('/storage/emulated/0/'),
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      allowedExtensions: allowedExtensions,
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

  static _openSystemSettings(BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LocaleKeys.need_storage_permission.tr(),
        ),
        action: SnackBarAction(
          label: LocaleKeys.open_settings.tr(),
          onPressed: () {
            if (context.mounted) {
              openAppSettings();
            }
          },
        ),
      ),
    );
  }

  static Future<Uint8List?> pickCSVFileAndGetContent() async {
    if (Platform.isAndroid) {
      final safStream = SafStream();
      final safUtil = SafUtil();

      final pickedFile = await safUtil.pickFile();

      if (pickedFile == null) {
        BackupGeneral.showInfoSnackbar(LocaleKeys.backup_not_valid.tr());
        return null;
      }

      return await safStream.readFileBytes(pickedFile.uri);
    } else if (Platform.isIOS) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        return file.readAsBytesSync();
      }
    }

    return null;
  }

  static void showRestoreMissingCoversDialog({
    required BuildContext context,
    required List<int> bookIDs,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Builder(builder: (context) {
          return AlertDialog.adaptive(
            title: Text(
              LocaleKeys.import_successful.tr(),
            ),
            content: Text(LocaleKeys.try_downloading_covers.tr()),
            actions: [
              Platform.isIOS
                  ? CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadMissingCoversScreen(
                              bookIDs: bookIDs,
                            ),
                          ),
                        );
                      },
                      isDefaultAction: true,
                      child: Text(LocaleKeys.yes.tr()),
                    )
                  : FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadMissingCoversScreen(
                              bookIDs: bookIDs,
                            ),
                          ),
                        );
                      },
                      child: Text(LocaleKeys.yes.tr()),
                    ),
              Platform.isIOS
                  ? CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(LocaleKeys.no.tr()),
                    )
                  : FilledButton.tonal(
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BooksScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(LocaleKeys.no.tr()),
                    ),
            ],
          );
        });
      },
    );
  }
}
