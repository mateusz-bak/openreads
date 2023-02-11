import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';

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
        title: l10n.welcome_1,
        maxLineTitle: 3,
        styleTitle: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
        textAlignTitle: TextAlign.start,
        styleDescription: TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
        description:
            '${l10n.welcome_1_description_1}\n\n\n${l10n.welcome_1_description_2}',
        textAlignDescription: TextAlign.start,
        backgroundImage: 'assets/images/welcome_1.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
      ),
    );

    listContentConfig.add(
      ContentConfig(
        styleTitle: TextStyle(
          fontSize: 26,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
        textAlignTitle: TextAlign.start,
        textAlignDescription: TextAlign.start,
        styleDescription: TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
        description:
            '${l10n.welcome_2_description_1}\n\n\n${l10n.welcome_2_description_2}',
        backgroundImage: 'assets/images/welcome_2.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
      ),
    );

    listContentConfig.add(
      ContentConfig(
        textAlignTitle: TextAlign.start,
        textAlignDescription: TextAlign.start,
        styleDescription: TextStyle(
          letterSpacing: 2,
          fontSize: 22,
          color: Colors.white,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
        description:
            '${l10n.welcome_3_description_1}\n\n\n${l10n.welcome_3_description_2}\n\n\n${l10n.welcome_3_description_3}',
        backgroundImage: 'assets/images/welcome_3.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
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

    return IntroSlider(
      key: UniqueKey(),
      isShowSkipBtn: false,
      isShowPrevBtn: false,
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      renderDoneBtn: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FittedBox(
          child: Text(l10n.start_button),
        ),
      ),
      skipButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
              BorderRadius.circular(5),
        )),
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).secondaryTextColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
      nextButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
              BorderRadius.circular(5),
        )),
        backgroundColor:
            MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      doneButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
              BorderRadius.circular(5),
        )),
        backgroundColor:
            MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      indicatorConfig: const IndicatorConfig(
        colorIndicator: Colors.white,
        typeIndicatorAnimation: TypeIndicatorAnimation.sizeTransition,
      ),
    );
  }
}
