import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
                                    Font.system,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Atkinson Hyperlegible',
                                  fontFamily: 'AtkinsonHyperlegible',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.atkinsonHyperlegible,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Open Dyslexic',
                                  fontFamily: 'OpenDyslexic',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.openDyslexic,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Nunito',
                                  fontFamily: 'Nunito',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.nunito,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Jost',
                                  fontFamily: 'Jost',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.jost,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Barlow',
                                  fontFamily: 'Barlow',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.barlow,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Inter',
                                  fontFamily: 'Inter',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.inter,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Kanit',
                                  fontFamily: 'Kanit',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.kanit,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Lato',
                                  fontFamily: 'Lato',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.lato,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Lora',
                                  fontFamily: 'Lora',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.lora,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Montserrat',
                                  fontFamily: 'Montserrat',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.montserrat,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Playfair Display',
                                  fontFamily: 'PlayfairDisplay',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.playfairDisplay,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Poppins',
                                  fontFamily: 'Poppins',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.poppins,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Raleway',
                                  fontFamily: 'Raleway',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.raleway,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Sofia Sans',
                                  fontFamily: 'SofiaSans',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.sofiaSans,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Quicksand',
                                  fontFamily: 'Quicksand',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.quicksand,
                                  ),
                                ),
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

  _showOutlinesDialog(BuildContext context) {
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
                          LocaleKeys.display_outlines.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: LocaleKeys.show_outlines.tr(),
                        onPressed: () => _showOutlines(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.hide_outlines.tr(),
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
                          LocaleKeys.select_corner_radius.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: LocaleKeys.no_rounded_corners.tr(),
                        onPressed: () => _changeCornerRadius(context, state, 0),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.small_rounded_corners.tr(),
                        onPressed: () => _changeCornerRadius(context, state, 5),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.medium_rounded_corners.tr(),
                        onPressed: () =>
                            _changeCornerRadius(context, state, 10),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.big_rounded_corners.tr(),
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

  _showTabsOrderDialog(BuildContext context) {
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
                          LocaleKeys.select_tabs_order.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: LocaleKeys.tabs_order_read_first.tr(),
                        onPressed: () {
                          BlocProvider.of<ThemeBloc>(context).add(
                            ChangeThemeEvent(
                              themeMode: state.themeMode,
                              showOutlines: state.showOutlines,
                              cornerRadius: state.cornerRadius,
                              primaryColor: state.primaryColor,
                              fontFamily: state.fontFamily,
                              readTabFirst: true,
                              useMaterialYou: state.useMaterialYou,
                              amoledDark: state.amoledDark,
                            ),
                          );

                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: LocaleKeys.tabs_order_in_progress_first.tr(),
                        onPressed: () {
                          BlocProvider.of<ThemeBloc>(context).add(
                            ChangeThemeEvent(
                              themeMode: state.themeMode,
                              showOutlines: state.showOutlines,
                              cornerRadius: state.cornerRadius,
                              primaryColor: state.primaryColor,
                              fontFamily: state.fontFamily,
                              readTabFirst: false,
                              useMaterialYou: state.useMaterialYou,
                              amoledDark: state.amoledDark,
                            ),
                          );

                          Navigator.of(context).pop();
                        },
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

  _setThemeModeLight(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.light,
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

  _setThemeModeDark(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.dark,
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

  _setDarkMode(BuildContext context, SetThemeState state, bool amoledDark) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.dark,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      amoledDark: amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _setFont(
    BuildContext context,
    SetThemeState state,
    Font font,
  ) {
    String? fontFamily;

    switch (font) {
      case Font.system:
        fontFamily = null;
        break;
      case Font.montserrat:
        fontFamily = 'Montserrat';
        break;
      case Font.lato:
        fontFamily = 'Lato';
        break;
      case Font.sofiaSans:
        fontFamily = 'SofiaSans';
        break;
      case Font.poppins:
        fontFamily = 'Poppins';
        break;
      case Font.raleway:
        fontFamily = 'Raleway';
        break;
      case Font.nunito:
        fontFamily = 'Nunito';
        break;
      case Font.playfairDisplay:
        fontFamily = 'PlayfairDisplay';
        break;
      case Font.kanit:
        fontFamily = 'Kanit';
        break;
      case Font.lora:
        fontFamily = 'Lora';
        break;
      case Font.quicksand:
        fontFamily = 'Quicksand';
        break;
      case Font.barlow:
        fontFamily = 'Barlow';
        break;
      case Font.inter:
        fontFamily = 'Inter';
        break;
      case Font.jost:
        fontFamily = 'Jost';
        break;
      case Font.atkinsonHyperlegible:
        fontFamily = 'AtkinsonHyperlegible';
        break;
      case Font.openDyslexic:
        fontFamily = 'OpenDyslexic';
        break;
      default:
        fontFamily = 'Nunito';
        break;
    }

    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _showOutlines(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: true,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
    ));

    Navigator.of(context).pop();
  }

  _hideOutlines(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: false,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      amoledDark: state.amoledDark,
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
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
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
                  : Theme.of(context).colorScheme.surface,
            ),
            lightTheme: SettingsThemeData(
              settingsListBackground: Theme.of(context).colorScheme.surface,
            ),
            sections: [
              SettingsSection(
                tiles: <SettingsTile>[
                  _buildAccentSetting(context),
                  _buildThemeModeSetting(context),
                  _buildDarkModeSetting(context),
                  _buildFontSetting(context),
                  _buildRatingTypeSetting(context),
                  _buildTabOrderSetting(context),
                  _buildOutlinesSetting(context),
                  _buildCornersSetting(context),
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

  SettingsTile _buildTabOrderSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.tabs_order.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const FaIcon(
        FontAwesomeIcons.tableColumns,
        size: 22,
      ),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, state) {
          if (state is SetThemeState) {
            if (state.readTabFirst) {
              return Text(
                LocaleKeys.tabs_order_read_first.tr(),
                style: const TextStyle(),
              );
            } else {
              return Text(
                LocaleKeys.tabs_order_in_progress_first.tr(),
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showTabsOrderDialog(context),
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

  SettingsTile _buildCornersSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.rounded_corners.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.rounded_corner_rounded),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.cornerRadius == 5) {
              return Text(
                LocaleKeys.small_rounded_corners.tr(),
                style: const TextStyle(),
              );
            } else if (themeState.cornerRadius == 10) {
              return Text(
                LocaleKeys.medium_rounded_corners.tr(),
                style: const TextStyle(),
              );
            } else if (themeState.cornerRadius == 20) {
              return Text(
                LocaleKeys.big_rounded_corners.tr(),
                style: const TextStyle(),
              );
            } else {
              return Text(
                LocaleKeys.no_rounded_corners.tr(),
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showCornerRadiusDialog(context),
    );
  }

  SettingsTile _buildOutlinesSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.display_outlines.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.check_box_outline_blank_rounded),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            if (themeState.showOutlines) {
              return Text(
                LocaleKeys.show_outlines.tr(),
                style: const TextStyle(),
              );
            } else {
              return Text(
                LocaleKeys.hide_outlines.tr(),
                style: const TextStyle(),
              );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showOutlinesDialog(context),
    );
  }
}
