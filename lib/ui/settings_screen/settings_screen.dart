import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/outlines_bloc/outlines_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const repoUrl = 'https://github.com/mateusz-bak/openreads-android';
  static const translationUrl = 'https://crwd.in/openreads-android';
  final releaseUrl = '$repoUrl/releases/tag/v2.0.0-alpha2';
  final licenceUrl = '$repoUrl/blob/master/LICENSE';

  _setThemeModeAuto(BuildContext context) {
    BlocProvider.of<ThemeBloc>(context)
        .add(const ChangeThemeEvent(ThemeMode.system));
    Navigator.of(context).pop();
  }

  _setThemeModeLight(BuildContext context) {
    BlocProvider.of<ThemeBloc>(context)
        .add(const ChangeThemeEvent(ThemeMode.light));
    Navigator.of(context).pop();
  }

  _setThemeModeDark(BuildContext context) {
    BlocProvider.of<ThemeBloc>(context)
        .add(const ChangeThemeEvent(ThemeMode.dark));
    Navigator.of(context).pop();
  }

  _showOutlines(BuildContext context) {
    BlocProvider.of<OutlinesBloc>(context).add(
      const ChangeOutlinesEvent(true),
    );
    Navigator.of(context).pop();
  }

  _hideOutlines(BuildContext context) {
    BlocProvider.of<OutlinesBloc>(context).add(
      const ChangeOutlinesEvent(false),
    );
    Navigator.of(context).pop();
  }

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
              SettingsTile(
                title: const Text('Display outlines in the UI'),
                description: BlocBuilder<OutlinesBloc, OutlinesState>(
                  builder: (_, themeState) {
                    if (themeState is ShowOutlinesState) {
                      return const Text('Show outlines');
                    } else if (themeState is HideOutlinesState) {
                      return const Text('Hide outlines');
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                onPressed: (context) => _showOutlinesDialog(context),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Select theme mode',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: 'Follow system mode',
                  onPressed: () => _setThemeModeAuto(context),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: 'Light mode',
                  onPressed: () => _setThemeModeLight(context),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: 'Dark mode',
                  onPressed: () => _setThemeModeDark(context),
                ),
              ],
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
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Display outlines in the UI',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: 'Show outlines',
                  onPressed: () => _showOutlines(context),
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: 'Hide outlines',
                  onPressed: () => _hideOutlines(context),
                ),
              ],
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
