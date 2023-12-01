import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/migration_v1_to_v2_bloc/migration_v1_to_v2_bloc.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<ContentConfig> listContentConfig = [];

  bool preparationTriggered = false;

  _prepareWelcomePages() {
    if (preparationTriggered) return;
    preparationTriggered = true;

    listContentConfig.add(
      ContentConfig(
        title: LocaleKeys.welcome_1.tr(),
        maxLineTitle: 3,
        styleTitle: const TextStyle(
          fontSize: 32,
          color: Colors.white,
        ),
        textAlignTitle: TextAlign.start,
        styleDescription: const TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
        ),
        description:
            '${LocaleKeys.welcome_1_description_1.tr()}\n\n\n${LocaleKeys.welcome_1_description_2.tr()}',
        textAlignDescription: TextAlign.start,
        backgroundImage: 'assets/images/welcome_1.jpg',
        backgroundColor: widget.themeData.colorScheme.surface,
      ),
    );

    listContentConfig.add(
      ContentConfig(
        styleTitle: const TextStyle(
          fontSize: 26,
        ),
        textAlignTitle: TextAlign.start,
        textAlignDescription: TextAlign.start,
        styleDescription: const TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
        ),
        description:
            '${LocaleKeys.welcome_2_description_1.tr()}\n\n\n${LocaleKeys.welcome_2_description_2.tr()}',
        backgroundImage: 'assets/images/welcome_2.jpg',
        backgroundColor: widget.themeData.colorScheme.surface,
      ),
    );

    listContentConfig.add(
      ContentConfig(
        textAlignTitle: TextAlign.start,
        textAlignDescription: TextAlign.start,
        styleDescription: const TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
        ),
        description:
            '${LocaleKeys.welcome_3_description_1.tr()}\n\n\n${LocaleKeys.welcome_3_description_2.tr()}\n\n\n${LocaleKeys.welcome_3_description_3.tr()}',
        backgroundImage: 'assets/images/welcome_3.jpg',
        backgroundColor: widget.themeData.colorScheme.surface,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  void onDonePress() {
    if (context.read<MigrationV1ToV2Bloc>().state is MigrationOnging) {
      return;
    } else {
      BlocProvider.of<WelcomeBloc>(context)
          .add(const ChangeWelcomeEvent(false));

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BooksScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _prepareWelcomePages();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          AppTheme.init(state, context);

          return Column(
            children: [
              Expanded(
                child: IntroSlider(
                  key: UniqueKey(),
                  isShowSkipBtn: false,
                  isShowPrevBtn: false,
                  listContentConfig: listContentConfig,
                  onDonePress: onDonePress,
                  isShowDoneBtn: true,
                  renderDoneBtn: FittedBox(
                    child:
                        BlocBuilder<MigrationV1ToV2Bloc, MigrationV1ToV2State>(
                      builder: (context, state) {
                        if (state is MigrationOnging) {
                          return const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Text(LocaleKeys.start_button.tr());
                        }
                      },
                    ),
                  ),
                  renderNextBtn: FittedBox(
                    child: Text(LocaleKeys.next_button.tr()),
                  ),
                  nextButtonStyle: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius),
                    )),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green.shade200,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black,
                    ),
                  ),
                  doneButtonStyle: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius),
                    )),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.green.shade700,
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                  ),
                  indicatorConfig: const IndicatorConfig(
                    colorIndicator: Colors.white,
                    typeIndicatorAnimation:
                        TypeIndicatorAnimation.sizeTransition,
                  ),
                ),
              ),
              BlocBuilder<MigrationV1ToV2Bloc, MigrationV1ToV2State>(
                builder: (context, migrationState) {
                  if (migrationState is MigrationNotStarted) {
                    BlocProvider.of<MigrationV1ToV2Bloc>(context).add(
                      StartMigration(context: context),
                    );
                  } else if (migrationState is MigrationOnging) {
                    return MigrationNotification(
                      done: migrationState.done,
                      total: migrationState.total,
                    );
                  } else if (migrationState is MigrationFailed) {
                    return MigrationNotification(
                      error: migrationState.error,
                    );
                  } else if (migrationState is MigrationSucceded) {
                    return const MigrationNotification(
                      success: true,
                    );
                  }

                  return const SizedBox();
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
