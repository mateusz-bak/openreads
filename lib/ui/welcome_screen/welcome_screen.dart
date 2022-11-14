import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:openreads/core/themes/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    listContentConfig.add(
      ContentConfig(
        title: 'Welcome to Openreads',
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
            "Openreads will help you keep track of your books.\n\n\nIt is also a great tool for organizing your personal library in an easy and transparent way.",
        textAlignDescription: TextAlign.start,
        backgroundImage: 'assets/images/welcome_1.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
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
            "Progress with your readings thanks to awesome and detailed statistics.\n\n\nChallenge yourself to be a better reader.",
        backgroundImage: 'assets/images/welcome_2.jpg',
        backgroundColor: widget.themeData.scaffoldBackgroundColor,
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
            "Openreads is completely open source!\n\n\nIt means that you can inspect the app's code on your own and contribute to it's development.\n\n\nAs a bonus you get zero ads and absolutely no tracking!",
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
      renderDoneBtn: const Text('START'),
      skipButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        backgroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).secondaryTextColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
      nextButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        backgroundColor:
            MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      doneButtonStyle: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
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
