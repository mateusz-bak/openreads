import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/resources/l10n.dart';
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

  bool _showMigrationNotification = false;

  _prepareWelcomePages() {
    if (preparationTriggered) return;
    preparationTriggered = true;

    listContentConfig.add(
      ContentConfig(
        title: l10n.welcome_1,
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
            '${l10n.welcome_1_description_1}\n\n\n${l10n.welcome_1_description_2}',
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
            '${l10n.welcome_2_description_1}\n\n\n${l10n.welcome_2_description_2}',
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
            '${l10n.welcome_3_description_1}\n\n\n${l10n.welcome_3_description_2}\n\n\n${l10n.welcome_3_description_3}',
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
    BlocProvider.of<WelcomeBloc>(context).add(const ChangeWelcomeEvent(false));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BooksScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppTranslations.init(context);

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
                  isShowDoneBtn: !_showMigrationNotification,
                  renderDoneBtn: FittedBox(
                    child: Text(l10n.start_button),
                  ),
                  renderNextBtn: FittedBox(
                    child: Text(l10n.next_button),
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
              _showMigrationNotification
                  ? const MigrationNotification()
                  : const SizedBox(),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
