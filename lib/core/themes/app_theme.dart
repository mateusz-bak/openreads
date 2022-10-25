import 'package:colours/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static Color lightBackgroundColor = const Color(0xfff2f2f2);
  static Color lightPrimaryColor = const Color(0xff344e41);
  static Color lightMainText = Colors.black;
  static Color lightSecondaryText = Colors.black54;

  static Color darkBackgroundColor = const Color.fromARGB(255, 22, 22, 22);
  static Color darkPrimaryColor = const Color(0xff3a5a40);
  static Color darkMainText = Colors.white;
  static Color darkSecondaryText = Colors.white70;

  const AppTheme._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: lightBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    primarySwatch: Colours.swatch(lightPrimaryColor),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    backgroundColor: Colors.black54,
    scaffoldBackgroundColor: darkBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    primarySwatch: Colours.swatch(darkPrimaryColor),
  );

  static Brightness get currentSystemBrightness =>
      SchedulerBinding.instance.window.platformBrightness;

  static setStatusAndNavBarsColors(ThemeMode themeMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      systemNavigationBarIconBrightness:
          themeMode == ThemeMode.light ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: themeMode == ThemeMode.light
          ? lightBackgroundColor
          : darkBackgroundColor,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }
}

extension ThemeExtras on ThemeData {
  Color get mainTextColor => brightness == Brightness.light
      ? AppTheme.lightMainText
      : AppTheme.darkMainText;

  Color get secondaryTextColor => brightness == Brightness.light
      ? AppTheme.lightSecondaryText
      : AppTheme.darkSecondaryText;
}
