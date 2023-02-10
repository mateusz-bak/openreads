import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    listContentConfig.add(
      ContentConfig(
        title: AppLocalizations.of(context)!.welcome_1,
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
            '${AppLocalizations.of(context)!.welcome_1_description_1}\n\n\n${AppLocalizations.of(context)!.welcome_1_description_2}',
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
            '${AppLocalizations.of(context)!.welcome_2_description_1}\n\n\n${AppLocalizations.of(context)!.welcome_2_description_2}',
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
            '${AppLocalizations.of(context)!.welcome_3_description_1}\n\n\n${AppLocalizations.of(context)!.welcome_3_description_2}\n\n\n${AppLocalizations.of(context)!.welcome_3_description_3}',
        backgroundImage: 'assets/images/welcome_3.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
      ),
    );
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
    return IntroSlider(
      key: UniqueKey(),
      isShowSkipBtn: false,
      isShowPrevBtn: false,
      listContentConfig: listContentConfig,
      onDonePress: onDonePress,
      renderDoneBtn: Text(AppLocalizations.of(context)!.start_button),
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
