import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/settings_screen/settings_accent_screen.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsApperanceScreen extends StatelessWidget {
  const SettingsApperanceScreen({super.key});

  _showThemeModeDialog(BuildContext context) {
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
                          LocaleKeys.select_theme_mode.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: LocaleKeys.theme_mode_system.tr(),
                        onPressed: () => _setThemeModeAuto(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.theme_mode_light.tr(),
                        onPressed: () => _setThemeModeLight(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.theme_mode_dark.tr(),
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

  _showDarkModeDialog(BuildContext context) {
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
                          LocaleKeys.dark_mode_style.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: LocaleKeys.dark_mode_natural.tr(),
                        onPressed: () => _setDarkMode(context, state, false),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.dark_mode_amoled.tr(),
                        onPressed: () => _setDarkMode(context, state, true),
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

  _showFontDialog(BuildContext context) {
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
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                if (state is SetThemeState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          LocaleKeys.select_font.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SettingsDialogButton(
                                  text: LocaleKeys.font_default.tr(),
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    null,
                                  ),
                                ),
                                for (var font in Constants.fonts) ...[
                                  const SizedBox(height: 5),
                                  SettingsDialogButton(
                                    text: font['text'] as String,
                                    fontFamily: font['family'] as String,
                                    onPressed: () => _setFont(
                                      context,
                                      state,
                                      font['family'] as String,
                                    ),
                                  ),
                                ],
                              ],
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

  _setThemeModeAuto(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.system,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _setThemeModeLight(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.light,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _setThemeModeDark(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.dark,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _setDarkMode(BuildContext context, SetThemeState state, bool amoledDark) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.dark,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _setFont(
    BuildContext context,
    SetThemeState state,
    String? fontFamily,
  ) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      primaryColor: state.primaryColor,
      fontFamily: fontFamily,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _showRatingBarDialog(BuildContext context) {
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
                    LocaleKeys.seletct_rating_type.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: LocaleKeys.rating_as_bar.tr(),
                  onPressed: () {
                    BlocProvider.of<RatingTypeBloc>(context).add(
                      const RatingTypeChange(ratingType: RatingType.bar),
                    );

                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: LocaleKeys.rating_as_number.tr(),
                  onPressed: () {
                    BlocProvider.of<RatingTypeBloc>(context).add(
                      const RatingTypeChange(ratingType: RatingType.number),
                    );

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.apperance.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
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
                  : Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            lightTheme: SettingsThemeData(
              settingsListBackground:
                  Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            sections: [
              SettingsSection(
                tiles: <SettingsTile>[
                  _buildAccentSetting(context),
                  _buildThemeModeSetting(context),
                  _buildDarkModeSetting(context),
                  _buildFontSetting(context),
                  _buildRatingTypeSetting(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  SettingsTile _buildThemeModeSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.theme_mode.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.sunny),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            switch (themeState.themeMode) {
              case ThemeMode.light:
                return Text(
                  LocaleKeys.theme_mode_light.tr(),
                  style: const TextStyle(),
                );
              case ThemeMode.dark:
                return Text(
                  LocaleKeys.theme_mode_dark.tr(),
                  style: const TextStyle(),
                );
              default:
                return Text(
                  LocaleKeys.theme_mode_system.tr(),
                  style: const TextStyle(),
                );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showThemeModeDialog(context),
    );
  }

  SettingsTile _buildDarkModeSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.dark_mode_style.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.contrast),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.amoledDark) {
              return Text(
                LocaleKeys.dark_mode_amoled.tr(),
                style: const TextStyle(),
              );
            } else {
              return Text(
                LocaleKeys.dark_mode_natural.tr(),
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showDarkModeDialog(context),
    );
  }

  SettingsTile _buildFontSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.font.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(
        Icons.font_download,
        size: 22,
      ),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, state) {
          if (state is SetThemeState) {
            if (state.fontFamily != null) {
              return Text(
                state.fontFamily!,
                style: const TextStyle(),
              );
            } else {
              return Text(
                LocaleKeys.font_default.tr(),
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showFontDialog(context),
    );
  }

  SettingsTile _buildRatingTypeSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.rating_type.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.star_rounded),
      description: BlocBuilder<RatingTypeBloc, RatingTypeState>(
        builder: (_, state) {
          if (state is RatingTypeNumber) {
            return Text(
              LocaleKeys.rating_as_number.tr(),
              style: const TextStyle(),
            );
          } else if (state is RatingTypeBar) {
            return Text(
              LocaleKeys.rating_as_bar.tr(),
              style: const TextStyle(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showRatingBarDialog(context),
    );
  }

  SettingsTile _buildAccentSetting(BuildContext context) {
    return SettingsTile.navigation(
      title: Text(
        LocaleKeys.accent_color.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.color_lens),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.useMaterialYou) {
              return Text(
                LocaleKeys.material_you.tr(),
                style: const TextStyle(),
              );
            } else {
              return Text(
                '0xFF${themeState.primaryColor.hex}',
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SettingsAccentScreen(),
          ),
        );
      },
    );
  }
}
