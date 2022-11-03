import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const repoUrl = 'https://github.com/mateusz-bak/openreads-android';
  static const translationUrl = 'https://crwd.in/openreads-android';
  final releaseUrl = '$repoUrl/releases/tag/v2.0.0-alpha2';
  final licenceUrl = '$repoUrl/blob/master/LICENSE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Appearance'),
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text('App theme mode'),
                description: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (_, themeState) {
                    if (themeState is ThemeAutoState) {
                      return const Text('Follow system mode');
                    } else if (themeState is ThemeLightState) {
                      return const Text('Light mode');
                    } else if (themeState is ThemeDarkState) {
                      return const Text('Dark mode');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                onPressed: (context) => _showThemeModeDialog(context),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('About'),
            tiles: <SettingsTile>[
              _buildURLSetting(
                title: 'Version',
                description: '2.0.0-alpha2',
                url: releaseUrl,
              ),
              _buildURLSetting(
                title: 'Source code',
                url: repoUrl,
              ),
              _buildURLSetting(
                title: 'Changelog',
                url: releaseUrl,
              ),
              _buildURLSetting(
                title: 'Licence',
                description: 'GNU General Public License v2.0',
                url: licenceUrl,
              ),
              _buildURLSetting(
                title: 'Help with translation',
                url: translationUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _showThemeModeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Select theme mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SimpleDialogOption(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            BlocProvider.of<ThemeBloc>(context)
                                .add(const ChangeThemeEvent(ThemeMode.system));
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            child: Text(
                              'Follow system mode',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: SimpleDialogOption(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            BlocProvider.of<ThemeBloc>(context)
                                .add(const ChangeThemeEvent(ThemeMode.light));
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            child: Text(
                              'Light mode',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: SimpleDialogOption(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            BlocProvider.of<ThemeBloc>(context)
                                .add(const ChangeThemeEvent(ThemeMode.dark));
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 15,
                            ),
                            child: Text(
                              'Dark mode',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  SettingsTile _buildURLSetting({
    required String title,
    String? description,
    required String url,
  }) {
    return SettingsTile.navigation(
      title: Text(title),
      description: (description != null) ? Text(description) : null,
      onPressed: (_) {
        launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      },
    );
  }
}
