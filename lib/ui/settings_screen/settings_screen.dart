import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                onPressed: (_) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
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
                                              .add(const ChangeThemeEvent(
                                                  ThemeMode.system));
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
                                              .add(const ChangeThemeEvent(
                                                  ThemeMode.light));
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
                                              .add(const ChangeThemeEvent(
                                                  ThemeMode.dark));
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
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('About'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('Version'),
                description: const Text('2.0.0-alpha2'),
                onPressed: (_) {
                  launchUrl(
                    Uri.parse(
                      'https://github.com/mateusz-bak/openreads-android/releases/tag/v2.0.0-alpha2',
                    ),
                    mode: LaunchMode.externalNonBrowserApplication,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
