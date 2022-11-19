import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const version = '2.0.0-alpha3';
  static const repoUrl = 'https://github.com/mateusz-bak/openreads-android';
  static const translationUrl = 'https://crwd.in/openreads-android';
  static const communityUrl = 'https://matrix.to/#/#openreads:matrix.org';
  static const rateUrl = 'market://details?id=software.mdev.bookstracker';
  final releaseUrl = '$repoUrl/releases/tag/$version';
  final licenceUrl = '$repoUrl/blob/master/LICENSE';

  _setThemeModeAuto(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.system,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _setThemeModeLight(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.light,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _setThemeModeDark(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.dark,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _showOutlines(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: true,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _hideOutlines(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: false,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _changeCornerRadius(
      BuildContext context, SetThemeState state, double radius) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: radius,
      primaryColor: state.primaryColor,
    ));

    Navigator.of(context).pop();
  }

  _setAccentColor(BuildContext context, SetThemeState state, Color color) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: color,
    ));

    Navigator.of(context).pop();
  }

  _showAccentColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
                BorderRadius.circular(5.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  final theme = Theme.of(context);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Select accent color',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildAccentButton(
                          context, state, theme.primaryGreen, 'Green'),
                      _buildAccentButton(
                          context, state, theme.primaryBlue, 'Blue'),
                      _buildAccentButton(
                          context, state, theme.primaryRed, 'Red'),
                      _buildAccentButton(
                          context, state, theme.primaryYellow, 'Yellow'),
                      _buildAccentButton(
                          context, state, theme.primaryOrange, 'Orange'),
                      _buildAccentButton(
                          context, state, theme.primaryPurple, 'Purple'),
                      _buildAccentButton(
                          context, state, theme.primaryPink, 'Pink'),
                      _buildAccentButton(
                          context, state, theme.primaryTeal, 'Teal'),
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

  Row _buildAccentButton(
    BuildContext context,
    SetThemeState state,
    Color color,
    String colorName,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 50,
            height: 25,
            decoration: BoxDecoration(
              borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: SettingsDialogButton(
            text: colorName,
            onPressed: () => _setAccentColor(
              context,
              state,
              color,
            ),
          ),
        ),
      ],
    );
  }

  _showThemeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
                BorderRadius.circular(5.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Select theme mode',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: 'Follow system mode',
                        onPressed: () => _setThemeModeAuto(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Light mode',
                        onPressed: () => _setThemeModeLight(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Dark mode',
                        onPressed: () => _setThemeModeDark(context, state),
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

  _showOutlinesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
                BorderRadius.circular(5.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Select level of corner radius',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: 'Show outlines',
                        onPressed: () => _showOutlines(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Hide outlines',
                        onPressed: () => _hideOutlines(context, state),
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

  _showCornerRadiusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
                BorderRadius.circular(5.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          'Display outlines in the UI',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: 'No rounded corners',
                        onPressed: () => _changeCornerRadius(context, state, 0),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Small radius',
                        onPressed: () => _changeCornerRadius(context, state, 5),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Medium radius',
                        onPressed: () =>
                            _changeCornerRadius(context, state, 10),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: 'Big radius',
                        onPressed: () =>
                            _changeCornerRadius(context, state, 20),
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

  SettingsTile _buildURLSetting({
    required String title,
    String? description,
    required String url,
    IconData? iconData,
  }) {
    return SettingsTile.navigation(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: (iconData == null) ? null : Icon(iconData),
      description: (description != null) ? Text(description) : null,
      onPressed: (_) {
        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      },
    );
  }

  SettingsTile _buildFeedbackSetting() {
    return SettingsTile(
      title: const Text(
        'Send feedback',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      description: const Text('Report bugs or new ideas'),
      leading: const Icon(Icons.record_voice_over_rounded),
      onPressed: (context) {
        FocusManager.instance.primaryFocus?.unfocus();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ContactButton(
                            text: 'Send the developer an email',
                            icon: Icons.mail_outline_rounded,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ContactButton(
                            text: 'Raise an issue on Github',
                            icon: Icons.bug_report_rounded,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  SettingsTile _buildAccentSetting() {
    return SettingsTile(
      title: const Text(
        'Accent color',
        style: TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.color_lens),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            switch (themeState.primaryColor.value) {
              case 0xffB73E3E:
                return const Text('Red');
              case 0xff2146C7:
                return const Text('Blue');
              default:
                return const Text('Green');
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showAccentColorDialog(context),
    );
  }

  SettingsTile _buildCornersSetting() {
    return SettingsTile(
      title: const Text(
        'Rounded corners',
        style: TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.rounded_corner_rounded),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.cornerRadius == 5) {
              return const Text('Small radius');
            } else if (themeState.cornerRadius == 10) {
              return const Text('Medium radius');
            } else if (themeState.cornerRadius == 20) {
              return const Text('Big radius');
            } else {
              return const Text('No radius');
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showCornerRadiusDialog(context),
    );
  }

  SettingsTile _buildOutlinesSetting() {
    return SettingsTile(
      title: const Text(
        'Display outlines in the UI',
        style: TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.check_box_outline_blank_rounded),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.showOutlines) {
              return const Text('Show outlines');
            } else {
              return const Text('Hide outlines');
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showOutlinesDialog(context),
    );
  }

  SettingsTile _buildThemeModeSetting() {
    return SettingsTile(
      title: const Text(
        'App theme mode',
        style: TextStyle(fontSize: 16),
      ),
      leading: const Icon(Icons.sunny),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            switch (themeState.themeMode) {
              case ThemeMode.light:
                return const Text('Light mode');
              case ThemeMode.dark:
                return const Text('Dark mode');
              default:
                return const Text('Follow system');
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showThemeModeDialog(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Settings'),
      ),
      body: SettingsList(
        contentPadding: const EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              _buildURLSetting(
                title: 'Join the community',
                description: 'To be up to date with the Openreads project',
                url: communityUrl,
                iconData: Icons.rocket,
              ),
              _buildURLSetting(
                title: 'Rate the application',
                description: 'You like Openreads? Click here to rate it',
                url: rateUrl,
                iconData: Icons.star_border_rounded,
              ),
              //TODO feedback setting
              _buildFeedbackSetting(),
              _buildURLSetting(
                title: 'Help with translation',
                description: 'We can use your language skills',
                url: translationUrl,
                iconData: Icons.translate_rounded,
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'App',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            tiles: <SettingsTile>[
              //TODO trash setting
              _buildURLSetting(
                title: 'Trash',
                description: 'Deleted books',
                url: communityUrl,
                iconData: Icons.delete_outline_rounded,
              ),
              //TODO backup setting
              _buildURLSetting(
                title: 'Backup',
                description: 'Create or restore',
                url: communityUrl,
                iconData: Icons.settings_backup_restore,
              ),
              //TODO unfinished setting
              _buildURLSetting(
                title: 'Unfinished list',
                description: 'Do not show on main screen',
                url: communityUrl,
                iconData: Icons.not_interested,
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            tiles: <SettingsTile>[
              _buildAccentSetting(),
              _buildThemeModeSetting(),
              _buildOutlinesSetting(),
              _buildCornersSetting(),
            ],
          ),
          SettingsSection(
            title: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            tiles: <SettingsTile>[
              _buildURLSetting(
                title: 'Version',
                description: version,
                url: releaseUrl,
                iconData: Icons.info,
              ),
              _buildURLSetting(
                title: 'Source code',
                description: 'See on Github',
                url: repoUrl,
                iconData: Icons.code_rounded,
              ),
              _buildURLSetting(
                title: 'Changelog',
                description: 'Check what\'s new in Openreads',
                url: releaseUrl,
                iconData: Icons.auto_awesome_rounded,
              ),
              _buildURLSetting(
                title: 'Licence',
                description: 'GNU General Public License v2.0',
                url: licenceUrl,
                iconData: Icons.copyright_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
