import 'package:colours/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static Color lightBackgroundColor = const Color(0xfff2f2f2);
  static Color lightSecondaryBackgroundColor =
      const Color.fromARGB(255, 211, 211, 211);
  static Color lightPrimaryColor = const Color(0xff344e41);
  static Color lightMainText = Colors.black;
  static Color lightSecondaryText = Colors.black54;
  static Color lightOutlineColor = const Color.fromARGB(255, 134, 134, 134);
  static Color lightLikeColor = const Color.fromARGB(255, 255, 71, 120);
  static Color lightRatingColor = const Color.fromARGB(255, 255, 211, 114);

  static Color darkBackgroundColor = const Color.fromARGB(255, 22, 22, 22);
  static Color darkSecondaryBackgroundColor =
      const Color.fromARGB(255, 63, 63, 63);
  static Color darkPrimaryColor = const Color(0xff3a5a40);
  static Color darkMainText = Colors.white;
  static Color darkSecondaryText = Colors.white70;
  static Color darkOutlineColor = const Color.fromARGB(255, 58, 58, 58);
  static Color darkLikeColor = const Color.fromARGB(255, 150, 23, 57);
  static Color darkRatingColor = const Color.fromARGB(255, 207, 161, 62);

  static Color primaryGreen = const Color(0xff285430);
  static Color primaryBlue = const Color(0xff2146C7);
  static Color primaryRed = const Color(0xffB73E3E);
  static Color primaryYellow = const Color.fromARGB(255, 204, 177, 2);
  static Color primaryOrange = const Color(0xffE14D2A);
  static Color primaryPurple = const Color(0xff9F73AB);
  static Color primaryPink = const Color(0xffFF577F);
  static Color primaryTeal = const Color(0xff3FA796);

  const AppTheme._();

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightPrimaryColor,
    backgroundColor: Colors.white38,
    scaffoldBackgroundColor: lightBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    primarySwatch: Colours.swatch(lightPrimaryColor),
    dividerColor: lightOutlineColor,
    fontFamily: 'Roboto',
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    backgroundColor: Colors.black38,
    scaffoldBackgroundColor: darkBackgroundColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    useMaterial3: true,
    primarySwatch: Colours.swatch(darkPrimaryColor),
    dividerColor: darkOutlineColor,
    fontFamily: 'Roboto',
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

  Color get secondaryBackgroundColor => brightness == Brightness.light
      ? AppTheme.lightSecondaryBackgroundColor
      : AppTheme.darkSecondaryBackgroundColor;

  Color get onPrimary =>
      brightness == Brightness.light ? Colors.white : Colors.black;

  Color get likeColor => brightness == Brightness.light
      ? AppTheme.lightLikeColor
      : AppTheme.darkLikeColor;

  Color get ratingColor => brightness == Brightness.light
      ? AppTheme.lightRatingColor
      : AppTheme.darkRatingColor;

  Color get primaryGreen => AppTheme.primaryGreen;
  Color get primaryBlue => AppTheme.primaryBlue;
  Color get primaryRed => AppTheme.primaryRed;
  Color get primaryYellow => AppTheme.primaryYellow;
  Color get primaryOrange => AppTheme.primaryOrange;
  Color get primaryPurple => AppTheme.primaryPurple;
  Color get primaryPink => AppTheme.primaryPink;
  Color get primaryTeal => AppTheme.primaryTeal;
}

@immutable
class CustomBorder extends ThemeExtension<CustomBorder> {
  const CustomBorder({
    required this.radius,
  });

  final BorderRadius? radius;

  @override
  CustomBorder copyWith({BorderRadius? radius}) {
    return CustomBorder(
      radius: radius ?? this.radius,
    );
  }

  @override
  CustomBorder lerp(ThemeExtension<CustomBorder>? other, double t) {
    if (other is! CustomBorder) {
      return this;
    }
    return CustomBorder(
      radius: BorderRadius.lerp(radius, other.radius, t),
    );
  }
}
