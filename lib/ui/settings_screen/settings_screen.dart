import 'dart:io';

import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/constants/locale.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/ui/settings_screen/download_missing_covers_screen.dart';
import 'package:openreads/ui/settings_screen/settings_backup_screen.dart';
import 'package:openreads/ui/settings_screen/settings_apperance_screen.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:openreads/ui/trash_screen/trash_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const licence = 'GNU General Public Licence v2.0';
  static const repoUrl = 'https://github.com/mateusz-bak/openreads';
  static const translationUrl = 'https://hosted.weblate.org/engage/openreads/';
  static const communityUrl = 'https://matrix.to/#/#openreads:matrix.org';
  static const rateUrlAndroid =
      'market://details?id=software.mdev.bookstracker';
  static const rateUrlIOS = 'https://apps.apple.com/app/id6476542305';
  static const releasesUrl = '$repoUrl/releases';
  static const licenceUrl = '$repoUrl/blob/master/LICENSE';
  static const githubIssuesUrl = '$repoUrl/issues';
  static const githubSponsorUrl = 'https://github.com/sponsors/mateusz-bak';
  static const buyMeCoffeUrl = 'https://www.buymeacoffee.com/mateuszbak';

  _sendEmailToDev(
    BuildContext context,
    String version, [
    bool mounted = true,
  ]) async {
    final Email email = Email(
      subject: 'Openreads feedback',
      body: 'Version $version\n',
      recipients: ['mateusz.bak.dev@gmail.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  _openGithubIssue(BuildContext context, [bool mounted = true]) async {
    try {
      await launchUrl(
        Uri.parse(githubIssuesUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  _supportGithub(BuildContext context, [bool mounted = true]) async {
    try {
      await launchUrl(
        Uri.parse(githubSponsorUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  _supportBuyMeCoffe(BuildContext context, [bool mounted = true]) async {
    try {
      await launchUrl(
        Uri.parse(buyMeCoffeUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$error',
          ),
        ),
      );
    }
  }

  _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          LocaleKeys.select_language.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Scrollbar(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: SingleChildScrollView(
                              child: Column(
                                children: _buildLanguageButtons(context, state),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        );
      },
    );
  }

  _showDefaultBooksFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    LocaleKeys.default_books_format.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_paperback.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.paperback,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_hardcover.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.hardcover,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_ebook.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.ebook,
                  ),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.book_format_audiobook.tr(),
                  onPressed: () => _setDefaultBooksFormat(
                    context,
                    BookFormat.audiobook,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _setDefaultBooksFormat(BuildContext context, BookFormat bookFormat) {
    BlocProvider.of<DefaultBooksFormatCubit>(context).setBookFormat(bookFormat);

    Navigator.of(context).pop();
  }

  List<Widget> _buildLanguageButtons(
    BuildContext context,
    SetThemeState state,
  ) {
    final widgets = List<Widget>.empty(growable: true);

    widgets.add(
      LanguageButton(
        language: LocaleKeys.default_locale.tr(),
        onPressed: () => _setLanguage(
          context,
          state,
          null,
        ),
      ),
    );

    for (var language in supportedLocales) {
      widgets.add(
        LanguageButton(
          language: language.fullName,
          onPressed: () => _setLanguage(
            context,
            state,
            language.locale,
          ),
        ),
      );
    }

    return widgets;
  }

  _setLanguage(BuildContext context, SetThemeState state, Locale? locale) {
    if (locale == null) {
      if (context.supportedLocales.contains(context.deviceLocale)) {
        context.resetLocale();
      } else {
        context.setLocale(context.fallbackLocale!);
      }
    } else {
      context.setLocale(locale);
    }

    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  SettingsTile _buildURLSetting({
    required String title,
    String? description,
    String? url,
    IconData? iconData,
    required BuildContext context,
  }) {
    return SettingsTile.navigation(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: (iconData == null) ? null : Icon(iconData),
      description: (description != null)
          ? Text(
              description,
              style: const TextStyle(),
            )
          : null,
      onPressed: (_) {
        if (url == null) return;

        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }

  SettingsTile _buildBasicSetting({
    required String title,
    String? description,
    IconData? iconData,
    required BuildContext context,
  }) {
    return SettingsTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: (iconData == null) ? null : Icon(iconData),
      description: (description != null)
          ? Text(
              description,
              style: const TextStyle(),
            )
          : null,
    );
  }

  SettingsTile _buildFeedbackSetting(BuildContext context, String version) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.send_feedback.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      description: Text(
        LocaleKeys.report_bugs_or_ideas.tr(),
        style: const TextStyle(),
      ),
      leading: const Icon(Icons.record_voice_over_rounded),
      onPressed: (context) {
        FocusManager.instance.primaryFocus?.unfocus();

        if (Platform.isIOS) {
          showCupertinoModalBottomSheet(
            context: context,
            expand: false,
            builder: (_) {
              return _buildFeedbackBottomSheet(context, version);
            },
          );
        } else if (Platform.isAndroid) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (context) {
              return _buildFeedbackBottomSheet(context, version);
            },
          );
        }
      },
    );
  }

  Widget _buildFeedbackBottomSheet(BuildContext context, String version) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ListTile(
              title: Text(LocaleKeys.send_dev_email.tr()),
              leading: Icon(
                Icons.email,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => _sendEmailToDev(context, version),
            ),
            ListTile(
              title: Text(LocaleKeys.raise_github_issue.tr()),
              leading: FaIcon(
                FontAwesomeIcons.github,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => _openGithubIssue(context),
            ),
          ],
        ),
      ),
    );
  }

  SettingsTile _buildSupportSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.support_the_project.tr(),
        style: TextStyle(
          fontSize: 17,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      description: Text(
        LocaleKeys.support_the_project_description.tr(),
      ),
      leading: ShakeAnimatedWidget(
        duration: const Duration(seconds: 3),
        shakeAngle: Rotation.deg(z: 20),
        curve: Curves.bounceInOut,
        child: FaIcon(
          FontAwesomeIcons.mugHot,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: (context) {
        FocusManager.instance.primaryFocus?.unfocus();
        if (Platform.isIOS) {
          showCupertinoModalBottomSheet(
            context: context,
            expand: false,
            builder: (_) {
              return _buildSupportBottomSheet(context);
            },
          );
        } else if (Platform.isAndroid) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (context) {
              return _buildSupportBottomSheet(context);
            },
          );
        }
      },
    );
  }

  Widget _buildSupportBottomSheet(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ListTile(
              title: Text(LocaleKeys.support_option_1.tr()),
              leading: FaIcon(
                FontAwesomeIcons.github,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => _supportGithub(context),
            ),
            ListTile(
              title: Text(LocaleKeys.support_option_2.tr()),
              leading: FaIcon(
                FontAwesomeIcons.mugHot,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => _supportBuyMeCoffe(context),
            ),
          ],
        ),
      ),
    );
  }

  SettingsTile _buildTrashSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.deleted_books.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.delete),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TrashScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildDownloadMissingCovers(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.download_missing_covers.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.image),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DownloadMissingCoversScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildDefaultBooksFormat(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.default_books_format.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.book_rounded),
      description: BlocBuilder<DefaultBooksFormatCubit, BookFormat>(
        builder: (_, state) {
          if (state == BookFormat.paperback) {
            return Text(
              LocaleKeys.book_format_paperback.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.hardcover) {
            return Text(
              LocaleKeys.book_format_hardcover.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.ebook) {
            return Text(
              LocaleKeys.book_format_ebook.tr(),
              style: const TextStyle(),
            );
          } else if (state == BookFormat.audiobook) {
            return Text(
              LocaleKeys.book_format_audiobook.tr(),
              style: const TextStyle(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showDefaultBooksFormatDialog(context),
    );
  }

  SettingsTile _buildBackupSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.backup_and_restore.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.settings_backup_restore_rounded),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsBackupScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildAppearanceSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.apperance.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.color_lens),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsApperanceScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildLanguageSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.language.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.public),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            final locale = context.locale;

            for (var language in supportedLocales) {
              if (language.locale == locale) {
                return Text(
                  language.fullName,
                  style: const TextStyle(),
                );
              }
            }

            return Text(
              LocaleKeys.default_locale.tr(),
              style: const TextStyle(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showLanguageDialog(context),
    );
  }

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings.tr(),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final version = snapshot.data;

              return BlocBuilder<ThemeBloc, ThemeState>(
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
                        tiles: _buildGeneralSettingsTiles(context, version),
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.books_settings.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildTrashSetting(context),
                          _buildDownloadMissingCovers(context),
                          _buildDefaultBooksFormat(context),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.app.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildBackupSetting(context),
                          _buildAppearanceSetting(context),
                          _buildLanguageSetting(context),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          LocaleKeys.about.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        tiles: <SettingsTile>[
                          _buildBasicSetting(
                            title: LocaleKeys.version.tr(),
                            description: version,
                            iconData: Icons.rocket_launch,
                            context: context,
                          ),
                          _buildURLSetting(
                            title: LocaleKeys.changelog.tr(),
                            description: LocaleKeys.changelog_description.tr(),
                            url: releasesUrl,
                            iconData: Icons.auto_awesome_rounded,
                            context: context,
                          ),
                          _buildURLSetting(
                            title: LocaleKeys.source_code.tr(),
                            description:
                                LocaleKeys.source_code_description.tr(),
                            url: repoUrl,
                            iconData: Icons.code,
                            context: context,
                          ),
                          _buildURLSetting(
                            title: LocaleKeys.licence.tr(),
                            description: licence,
                            url: licenceUrl,
                            iconData: Icons.copyright_rounded,
                            context: context,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }

  List<SettingsTile> _buildGeneralSettingsTiles(
      BuildContext context, String? version) {
    final tiles = List<SettingsTile>.empty(growable: true);

    // TODO: Implement in app purchase for iOS
    if (!Platform.isIOS) {
      tiles.add(_buildSupportSetting(context));
    }

    tiles.add(_buildURLSetting(
      title: LocaleKeys.join_community.tr(),
      description: LocaleKeys.join_community_description.tr(),
      url: communityUrl,
      iconData: Icons.groups,
      context: context,
    ));

    tiles.add(_buildURLSetting(
      title: LocaleKeys.rate_app.tr(),
      description: LocaleKeys.rate_app_description.tr(),
      url: Platform.isIOS
          ? rateUrlIOS
          : Platform.isAndroid
              ? rateUrlAndroid
              : null,
      iconData: Icons.star_rounded,
      context: context,
    ));
    tiles.add(_buildFeedbackSetting(context, version!));
    tiles.add(_buildURLSetting(
      title: LocaleKeys.translate_app.tr(),
      description: LocaleKeys.translate_app_description.tr(),
      url: translationUrl,
      iconData: Icons.translate_rounded,
      context: context,
    ));

    return tiles;
  }
}
