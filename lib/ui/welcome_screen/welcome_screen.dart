import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/helpers/backup/backup_general.dart';
import 'package:openreads/core/helpers/backup/backup_import.dart';
import 'package:openreads/core/helpers/backup/csv_import_bookwyrm.dart';
import 'package:openreads/core/helpers/backup/csv_import_goodreads.dart';
import 'package:openreads/core/helpers/backup/csv_import_openreads.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/migration_v1_to_v2_bloc/migration_v1_to_v2_bloc.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/widgets/widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  bool preparationTriggered = false;

  bool _checkIfMigrationIsOngoing() {
    if (context.read<MigrationV1ToV2Bloc>().state is MigrationOnging) {
      return true;
    } else {
      return false;
    }
  }

  _setWelcomeState() {
    BlocProvider.of<WelcomeBloc>(context).add(
      const ChangeWelcomeEvent(false),
    );
  }

  _moveToBooksScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BooksScreen()),
      (Route<dynamic> route) => false,
    );
  }

  _restoreBackup() async {
    if (_checkIfMigrationIsOngoing()) return;
    _setWelcomeState();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 30) {
        await BackupGeneral.requestStoragePermission(context);
        await BackupImport.restoreLocalBackupLegacyStorage(context);
      } else {
        await BackupImport.restoreLocalBackup(context);
      }
    } else if (Platform.isIOS) {
      await BackupImport.restoreLocalBackup(context);
    }
  }

  _importOpenreadsCsv() async {
    if (_checkIfMigrationIsOngoing()) return;
    _setWelcomeState();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 30) {
        await BackupGeneral.requestStoragePermission(context);
        await CSVImportOpenreads.importCSVLegacyStorage(context);
      } else {
        await CSVImportOpenreads.importCSV(context);
      }
    } else if (Platform.isIOS) {
      await CSVImportOpenreads.importCSV(context);
    }
  }

  _importGoodreadsCsv() async {
    if (_checkIfMigrationIsOngoing()) return;
    _setWelcomeState();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 30) {
        await BackupGeneral.requestStoragePermission(context);
        await CSVImportGoodreads.importCSVLegacyStorage(context);
      } else {
        await CSVImportGoodreads.importCSV(context);
      }
    } else if (Platform.isIOS) {
      await CSVImportGoodreads.importCSV(context);
    }
  }

  _importBookwyrmCsv() async {
    if (_checkIfMigrationIsOngoing()) return;
    _setWelcomeState();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 30) {
        await BackupGeneral.requestStoragePermission(context);
        await CSVImportBookwyrm.importCSVLegacyStorage(context);
      } else {
        await CSVImportBookwyrm.importCSV(context);
      }
    } else if (Platform.isIOS) {
      await CSVImportBookwyrm.importCSV(context);
    }
  }

  _skipImportingBooks() {
    if (_checkIfMigrationIsOngoing()) return;

    _setWelcomeState();
    _moveToBooksScreen();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          AppTheme.init(state, context);

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            LocaleKeys.welcome_1.tr(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      children: [
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_1_description_1.tr(),
                            LocaleKeys.welcome_1_description_2.tr(),
                          ],
                          image: Image.asset(
                            'assets/icons/icon_cropped.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_2_description_1.tr(),
                            LocaleKeys.welcome_2_description_2.tr(),
                          ],
                          image: const Icon(
                            FontAwesomeIcons.chartSimple,
                            size: 60,
                          ),
                        ),
                        WelcomePageText(
                          descriptions: [
                            LocaleKeys.welcome_3_description_1.tr(),
                            LocaleKeys.welcome_3_description_2.tr(),
                            LocaleKeys.welcome_3_description_3.tr(),
                          ],
                          image: const Icon(
                            FontAwesomeIcons.code,
                            size: 60,
                          ),
                        ),
                        WelcomePageChoices(
                          restoreBackup: _restoreBackup,
                          importOpenreadsCsv: _importOpenreadsCsv,
                          importGoodreadsCsv: _importGoodreadsCsv,
                          importBookwyrmCsv: _importBookwyrmCsv,
                          skipImportingBooks: _skipImportingBooks,
                        ),
                      ],
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(context).colorScheme.surfaceVariant,
                      dotHeight: 12,
                      dotWidth: 12,
                    ),
                    onDotClicked: (index) {
                      _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<MigrationV1ToV2Bloc, MigrationV1ToV2State>(
                    builder: (context, migrationState) {
                      if (migrationState is MigrationNotStarted) {
                        BlocProvider.of<MigrationV1ToV2Bloc>(context).add(
                          StartMigration(context: context),
                        );
                      } else if (migrationState is MigrationOnging) {
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
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
