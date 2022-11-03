import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/logic/cubit/theme_cubit.dart';
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
                leading: StreamBuilder<AppThemeMode>(
                  stream: BlocProvider.of<ThemeCubit>(context).appThemeMode,
                  builder: (context, AsyncSnapshot<AppThemeMode> snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data) {
                        case AppThemeMode.auto:
                          return const Icon(Icons.autorenew);
                        case AppThemeMode.light:
                          return const Icon(Icons.sunny);
                        case AppThemeMode.dark:
                          return const FaIcon(FontAwesomeIcons.moon);
                        default:
                          return const SizedBox();
                      }
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                title: const Text('App theme mode'),
                description: StreamBuilder<AppThemeMode>(
                  stream: BlocProvider.of<ThemeCubit>(context).appThemeMode,
                  builder: (context, AsyncSnapshot<AppThemeMode> snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data) {
                        case AppThemeMode.auto:
                          return const Text('Auto mode');
                        case AppThemeMode.light:
                          return const Text('Light mode');
                        case AppThemeMode.dark:
                          return const Text('Dark mode');
                        default:
                          return const SizedBox();
                      }
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
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SimpleDialogOption(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          // BlocProvider.of<ThemeCubit>(context)
                                          //     .updateAppThemeAuto();
                                          context
                                              .read<ThemeCubit>()
                                              .updateAppThemeAuto();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 15,
                                          ),
                                          child: Text(
                                            'Auto mode',
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
                                          // BlocProvider.of<ThemeCubit>(context)
                                          //     .updateAppThemeLight();
                                          context
                                              .read<ThemeCubit>()
                                              .updateAppThemeLight();
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
                                          // BlocProvider.of<ThemeCubit>(context)
                                          //     .updateAppThemeDark();
                                          context
                                              .read<ThemeCubit>()
                                              .updateAppThemeDark();
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
                          // title: const Text('Select theme mode'),
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
