import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/app_language.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/backup_screen/backup_screen.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';
import 'package:openreads/ui/trash_screen/trash_screen.dart';
import 'package:openreads/ui/unfinished_screen/unfinished_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  static const version = '2.0.0-rc3';
  static const licence = 'GNU General Public Licence v2.0';
  static const repoUrl = 'https://github.com/mateusz-bak/openreads-android';
  static const translationUrl = 'https://crwd.in/openreads-android';
  static const communityUrl = 'https://matrix.to/#/#openreads:matrix.org';
  static const rateUrl = 'market://details?id=software.mdev.bookstracker';
  final releaseUrl = '$repoUrl/releases/tag/$version';
  final licenceUrl = '$repoUrl/blob/master/LICENSE';
  final githubIssuesUrl = '$repoUrl/issues';
  final githubSponsorUrl = 'https://github.com/sponsors/mateusz-bak';
  final buyMeCoffeUrl = 'https://www.buymeacoffee.com/mateuszbak';

  final languages = [
    AppLanguage(fullName: l10n.english, twoLetterCode: 'en'),
    AppLanguage(fullName: l10n.arabic, twoLetterCode: 'ar'),
    AppLanguage(fullName: l10n.catalan, twoLetterCode: 'ca'),
    AppLanguage(fullName: l10n.czech, twoLetterCode: 'cs'),
    AppLanguage(fullName: l10n.danish, twoLetterCode: 'da'),
    AppLanguage(fullName: l10n.dutch, twoLetterCode: 'nl'),
    AppLanguage(fullName: l10n.french, twoLetterCode: 'fr'),
    AppLanguage(fullName: l10n.georgian, twoLetterCode: 'ka'),
    AppLanguage(fullName: l10n.german, twoLetterCode: 'de'),
    AppLanguage(fullName: l10n.hindi, twoLetterCode: 'hi'),
    AppLanguage(fullName: l10n.italian, twoLetterCode: 'it'),
    AppLanguage(fullName: l10n.norwegian, twoLetterCode: 'no'),
    AppLanguage(fullName: l10n.portugese, twoLetterCode: 'pt'),
    AppLanguage(fullName: l10n.russian, twoLetterCode: 'ru'),
    AppLanguage(fullName: l10n.spanish, twoLetterCode: 'es'),
    AppLanguage(fullName: l10n.turkish, twoLetterCode: 'tr'),
    AppLanguage(fullName: l10n.ukrainian, twoLetterCode: 'uk'),
    AppLanguage(fullName: l10n.polish, twoLetterCode: 'pl'),
  ];

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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
      locale: state.locale,
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
                          l10n.select_accent_color,
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
                                        l10n.material_you,
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
                                l10n.green_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryBlue,
                                l10n.blue_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryRed,
                                l10n.red_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryYellow,
                                l10n.yellow_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryOrange,
                                l10n.orange_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryPurple,
                                l10n.purple_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryPink,
                                l10n.pink_color,
                              ),
                              _buildAccentButton(
                                context,
                                state,
                                primaryTeal,
                                l10n.teal_color,
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
                          l10n.select_language,
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
        language: l10n.default_locale,
        onPressed: () => _setLanguage(
          context,
          state,
          null,
        ),
      ),
    );

    for (var language in languages) {
      widgets.add(
        LanguageButton(
          language: language.fullName,
          onPressed: () => _setLanguage(
            context,
            state,
            language.twoLetterCode,
          ),
        ),
      );
    }

    return widgets;
  }

  _setLanguage(BuildContext context, SetThemeState state, String? locale) {
    BlocProvider.of<ThemeBloc>(context).add(ChangeThemeEvent(
      themeMode: state.themeMode,
      showOutlines: state.showOutlines,
      cornerRadius: state.cornerRadius,
      primaryColor: state.primaryColor,
      fontFamily: state.fontFamily,
      readTabFirst: state.readTabFirst,
      useMaterialYou: state.useMaterialYou,
      locale: locale,
    ));

    Navigator.of(context).pop();
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
                    l10n.seletct_rating_type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SettingsDialogButton(
                  text: l10n.rating_as_bar,
                  onPressed: () {
                    BlocProvider.of<RatingTypeBloc>(context).add(
                      const RatingTypeChange(ratingType: RatingType.bar),
                    );

                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 5),
                SettingsDialogButton(
                  text: l10n.rating_as_number,
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
                          l10n.select_theme_mode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: l10n.theme_mode_system,
                        onPressed: () => _setThemeModeAuto(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.theme_mode_light,
                        onPressed: () => _setThemeModeLight(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.theme_mode_dark,
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
                          l10n.select_font,
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
                                  text: l10n.font_default,
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
                          l10n.display_outlines,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: l10n.show_outlines,
                        onPressed: () => _showOutlines(context, state),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.hide_outlines,
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
                          l10n.select_corner_radius,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: l10n.no_rounded_corners,
                        onPressed: () => _changeCornerRadius(context, state, 0),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.small_rounded_corners,
                        onPressed: () => _changeCornerRadius(context, state, 5),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.medium_rounded_corners,
                        onPressed: () =>
                            _changeCornerRadius(context, state, 10),
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.big_rounded_corners,
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
                          l10n.select_tabs_order,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SettingsDialogButton(
                        text: l10n.tabs_order_read_first,
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
                              locale: state.locale,
                            ),
                          );

                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 5),
                      SettingsDialogButton(
                        text: l10n.tabs_order_in_progress_first,
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
                              locale: state.locale,
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
    required String url,
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
        l10n.send_feedback,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      description: Text(
        l10n.report_bugs_or_ideas,
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
                            text: l10n.send_dev_email,
                            icon: FontAwesomeIcons.solidEnvelope,
                            onPressed: () => _sendEmailToDev(context),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ContactButton(
                            text: l10n.raise_github_issue,
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
        l10n.support_the_project,
        style: TextStyle(
          fontSize: 17,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      description: Text(
        l10n.support_the_project_description,
      ),
      leading: Icon(
        FontAwesomeIcons.mugHot,
        color: Theme.of(context).colorScheme.primary,
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
                            text: l10n.support_option_1,
                            icon: FontAwesomeIcons.github,
                            onPressed: () => _supportGithub(context),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ContactButton(
                            text: l10n.support_option_2,
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
        l10n.deleted_books,
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
        l10n.unfinished_books,
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
        l10n.backup_and_restore,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.settings_backup_restore_rounded),
      onPressed: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BackupScreen(),
          ),
        );
      },
    );
  }

  SettingsTile _buildAccentSetting(BuildContext context) {
    return SettingsTile(
      title: Text(
        l10n.accent_color,
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
                l10n.material_you,
                style: const TextStyle(),
              );
            }

            switch (themeState.primaryColor.value) {
              case 0xffB73E3E:
                return Text(
                  l10n.red_color,
                  style: const TextStyle(),
                );
              case 0xff2146C7:
                return Text(
                  l10n.blue_color,
                  style: const TextStyle(),
                );
              case 0xff285430:
                return Text(
                  l10n.green_color,
                  style: const TextStyle(),
                );
              case 0xffE14D2A:
                return Text(
                  l10n.orange_color,
                  style: const TextStyle(),
                );
              case 0xff9F73AB:
                return Text(
                  l10n.purple_color,
                  style: const TextStyle(),
                );
              case 0xffFF577F:
                return Text(
                  l10n.pink_color,
                  style: const TextStyle(),
                );
              case 0xff3FA796:
                return Text(
                  l10n.teal_color,
                  style: const TextStyle(),
                );
              default:
                return Text(
                  l10n.yellow_color,
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
        l10n.language,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(FontAwesomeIcons.earthAmericas),
      description: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, themeState) {
          if (themeState is SetThemeState) {
            final locale = themeState.locale;

            if (locale != null) {
              for (var language in languages) {
                if (language.twoLetterCode == locale) {
                  return Text(
                    language.fullName,
                    style: const TextStyle(),
                  );
                }
              }
            }

            return Text(
              l10n.default_locale,
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
        l10n.rounded_corners,
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
                l10n.small_rounded_corners,
                style: const TextStyle(),
              );
            } else if (themeState.cornerRadius == 10) {
              return Text(
                l10n.medium_rounded_corners,
                style: const TextStyle(),
              );
            } else if (themeState.cornerRadius == 20) {
              return Text(
                l10n.big_rounded_corners,
                style: const TextStyle(),
              );
            } else {
              return Text(
                l10n.no_rounded_corners,
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
        l10n.display_outlines,
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
                l10n.show_outlines,
                style: const TextStyle(),
              );
            } else {
              return Text(
                l10n.hide_outlines,
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
        l10n.theme_mode,
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
                  l10n.theme_mode_light,
                  style: const TextStyle(),
                );
              case ThemeMode.dark:
                return Text(
                  l10n.theme_mode_dark,
                  style: const TextStyle(),
                );
              default:
                return Text(
                  l10n.theme_mode_system,
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
        l10n.font,
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
                l10n.font_default,
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
        l10n.rating_type,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      leading: const Icon(Icons.star_rounded),
      description: BlocBuilder<RatingTypeBloc, RatingTypeState>(
        builder: (_, state) {
          if (state is RatingTypeNumber) {
            return Text(
              l10n.rating_as_number,
              style: const TextStyle(),
            );
          } else if (state is RatingTypeBar) {
            return Text(
              l10n.rating_as_bar,
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
        l10n.tabs_order,
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
                l10n.tabs_order_read_first,
                style: const TextStyle(),
              );
            } else {
              return Text(
                l10n.tabs_order_in_progress_first,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: SettingsList(
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
                title: l10n.join_community,
                description: l10n.join_community_description,
                url: communityUrl,
                iconData: FontAwesomeIcons.peopleGroup,
                context: context,
              ),
              // TODO: Show only on GPlay variant
              _buildURLSetting(
                title: l10n.rate_app,
                description: l10n.rate_app_description,
                url: rateUrl,
                iconData: Icons.star_rounded,
                context: context,
              ),
              _buildFeedbackSetting(context),
              _buildURLSetting(
                title: l10n.translate_app,
                description: l10n.translate_app_description,
                url: translationUrl,
                iconData: Icons.translate_rounded,
                context: context,
              ),
            ],
          ),
          SettingsSection(
            title: Text(
              l10n.app,
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
              l10n.apperance,
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
              l10n.about,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            tiles: <SettingsTile>[
              _buildURLSetting(
                title: l10n.version,
                description: version,
                url: releaseUrl,
                iconData: FontAwesomeIcons.rocket,
                context: context,
              ),
              _buildURLSetting(
                title: l10n.source_code,
                description: l10n.source_code_description,
                url: repoUrl,
                iconData: FontAwesomeIcons.code,
                context: context,
              ),
              _buildURLSetting(
                title: l10n.changelog,
                description: l10n.changelog_description,
                url: releaseUrl,
                iconData: Icons.auto_awesome_rounded,
                context: context,
              ),
              _buildURLSetting(
                title: l10n.licence,
                description: licence,
                url: licenceUrl,
                iconData: Icons.copyright_rounded,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
