import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/constants.dart/locale.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/backup_screen/backup_screen.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:openreads/ui/trash_screen/trash_screen.dart';
import 'package:openreads/ui/unfinished_screen/unfinished_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  String? version;
  static const licence = 'GNU General Public Licence v2.0';
  static const repoUrl = 'https://github.com/mateusz-bak/openreads-android';
  static const translationUrl = 'https://crwd.in/openreads-android';
  static const communityUrl = 'https://matrix.to/#/#openreads:matrix.org';
  static const rateUrl = 'market://details?id=software.mdev.bookstracker';
  final releasesUrl = '$repoUrl/releases';
  final licenceUrl = '$repoUrl/blob/master/LICENSE';
  final githubIssuesUrl = '$repoUrl/issues';
  final githubSponsorUrl = 'https://github.com/sponsors/mateusz-bak';
  final buyMeCoffeUrl = 'https://www.buymeacoffee.com/mateuszbak';

  _sendEmailToDev(BuildContext context, [bool mounted = true]) async {
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

  _setThemeModeAuto(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: ThemeMode.system,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
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
      case Font.jost:
        fontFamily = 'Jost';
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
    ));

    Navigator.of(context).pop();
  }

  _setAccentColor(BuildContext context, SetThemeState state, Color color) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: color,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: false,
    ));

    Navigator.of(context).pop();
  }

  _setMaterialYou(BuildContext context, SetThemeState state) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: true,
    ));

    Navigator.of(context).pop();
  }

  _showAccentColorDialog(BuildContext context) {
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
                          LocaleKeys.select_accent_color.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Scrollbar(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _setMaterialYou(
                                  context,
                                  state,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(cornerRadius),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    border: Border.all(color: dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        LocaleKeys.material_you.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              _buildAccentButton(
                                context,
                                state,
                                primaryGreen,
                                LocaleKeys.green_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryBlue,
                                LocaleKeys.blue_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryRed,
                                LocaleKeys.red_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryYellow,
                                LocaleKeys.yellow_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryOrange,
                                LocaleKeys.orange_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryPurple,
                                LocaleKeys.purple_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryPink,
                                LocaleKeys.pink_color.tr(),
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryTeal,
                                LocaleKeys.teal_color.tr(),
                              ),
                            ],
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
    ));

    Navigator.of(context).pop();
  }

  Widget _buildAccentButton(
    BuildContext context,
    SetThemeState state,
    Color color,
    String colorName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 50,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
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
        ),
      ),
    );
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
                                  text: 'Nunito',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.nunito,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Jost',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.jost,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Barlow',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.barlow,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Kanit',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.kanit,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Lato',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.lato,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Lora',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.lora,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Montserrat',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.montserrat,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Playfair Display',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.playfairDisplay,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Poppins',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.poppins,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Raleway',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.raleway,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Sofia Sans',
                                  onPressed: () => _setFont(
                                    context,
                                    state,
                                    Font.sofiaSans,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SettingsDialogButton(
                                  text: 'Quicksand',
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
          mode: LaunchMode.externalNonBrowserApplication,
        );
      },
    );
  }

  SettingsTile _buildFeedbackSetting(BuildContext context) {
    return SettingsTile(
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

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: ContactButton(
                            text: LocaleKeys.send_dev_email.tr(),
                            icon: FontAwesomeIcons.solidEnvelope,
                            onPressed: () => _sendEmailToDev(context),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ContactButton(
                            text: LocaleKeys.raise_github_issue.tr(),
                            icon: FontAwesomeIcons.github,
                            onPressed: () => _openGithubIssue(context),
                          ),
                        ),
                        const SizedBox(width: 10),
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

  SettingsTile _buildSupportSetting(BuildContext context) {
    return SettingsTile(
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
        child: Icon(
          FontAwesomeIcons.mugHot,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      onPressed: (context) {
        FocusManager.instance.primaryFocus?.unfocus();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10)),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: ContactButton(
                            text: LocaleKeys.support_option_1.tr(),
                            icon: FontAwesomeIcons.github,
                            onPressed: () => _supportGithub(context),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ContactButton(
                            text: LocaleKeys.support_option_2.tr(),
                            icon: FontAwesomeIcons.mugHot,
                            onPressed: () => _supportBuyMeCoffe(context),
                          ),
                        ),
                        const SizedBox(width: 10),
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

  SettingsTile _buildTrashSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.deleted_books.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(
        FontAwesomeIcons.trash,
        size: 20,
      ),
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

  SettingsTile _buildUnfinishedSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        LocaleKeys.unfinished_books.tr(),
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.not_interested),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UnfinishedScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildBackupSetting(BuildContext context) {
    return SettingsTile(
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
            builder: (context) => BackupScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildAccentSetting(BuildContext context) {
    return SettingsTile(
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
            }

            switch (themeState.primaryColor.value) {
              case 0xffB73E3E:
                return Text(
                  LocaleKeys.red_color.tr(),
                  style: const TextStyle(),
                );
              case 0xff2146C7:
                return Text(
                  LocaleKeys.blue_color.tr(),
                  style: const TextStyle(),
                );
              case 0xff285430:
                return Text(
                  LocaleKeys.green_color.tr(),
                  style: const TextStyle(),
                );
              case 0xffE14D2A:
                return Text(
                  LocaleKeys.orange_color.tr(),
                  style: const TextStyle(),
                );
              case 0xff9F73AB:
                return Text(
                  LocaleKeys.purple_color.tr(),
                  style: const TextStyle(),
                );
              case 0xffFF577F:
                return Text(
                  LocaleKeys.pink_color.tr(),
                  style: const TextStyle(),
                );
              case 0xff3FA796:
                return Text(
                  LocaleKeys.teal_color.tr(),
                  style: const TextStyle(),
                );
              default:
                return Text(
                  LocaleKeys.yellow_color.tr(),
                  style: const TextStyle(),
                );
            }
          } else {
            return const SizedBox();
          }
        },
      ),
      onPressed: (context) => _showAccentColorDialog(context),
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
      leading: const Icon(FontAwesomeIcons.earthAmericas),
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
              version = snapshot.data;

              return SettingsList(
                contentPadding: const EdgeInsets.only(top: 10),
                darkTheme: SettingsThemeData(
                  settingsListBackground: Theme.of(context).colorScheme.surface,
                ),
                lightTheme: SettingsThemeData(
                  settingsListBackground: Theme.of(context).colorScheme.surface,
                ),
                sections: [
                  SettingsSection(
                    tiles: <SettingsTile>[
                      _buildSupportSetting(context),
                      _buildURLSetting(
                        title: LocaleKeys.join_community.tr(),
                        description: LocaleKeys.join_community_description.tr(),
                        url: communityUrl,
                        iconData: FontAwesomeIcons.peopleGroup,
                        context: context,
                      ),
                      // TODO: Show only on GPlay variant
                      _buildURLSetting(
                        title: LocaleKeys.rate_app.tr(),
                        description: LocaleKeys.rate_app_description.tr(),
                        url: rateUrl,
                        iconData: Icons.star_rounded,
                        context: context,
                      ),
                      _buildFeedbackSetting(context),
                      _buildURLSetting(
                        title: LocaleKeys.translate_app.tr(),
                        description: LocaleKeys.translate_app_description.tr(),
                        url: translationUrl,
                        iconData: Icons.translate_rounded,
                        context: context,
                      ),
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
                      _buildLanguageSetting(context),
                      _buildTrashSetting(context),
                      _buildUnfinishedSetting(context),
                      _buildBackupSetting(context),
                    ],
                  ),
                  SettingsSection(
                    title: Text(
                      LocaleKeys.apperance.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    tiles: <SettingsTile>[
                      _buildAccentSetting(context),
                      _buildThemeModeSetting(context),
                      _buildFontSetting(context),
                      _buildRatingTypeSetting(context),
                      _buildTabOrderSetting(context),
                      _buildOutlinesSetting(context),
                      _buildCornersSetting(context),
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
                      _buildURLSetting(
                        title: LocaleKeys.version.tr(),
                        description: version,
                        iconData: FontAwesomeIcons.rocket,
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
                        description: LocaleKeys.source_code_description.tr(),
                        url: repoUrl,
                        iconData: FontAwesomeIcons.code,
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
            } else {
              return const SizedBox();
            }
          }),
    );
  }
}
