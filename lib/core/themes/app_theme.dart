import 'package:flutter/material.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

double get cornerRadius => _cornerRadius!;
double? _cornerRadius;

Color get dividerColor => _dividerColor!;
Color? _dividerColor;

Color get lightBackgroundColor => _lightBackgroundColor!;
Color? _lightBackgroundColor;

Color get darkBackgroundColor => _darkBackgroundColor!;
Color? _darkBackgroundColor;

Color get lightCardColor => _lightCardColor!;
Color? _lightCardColor;

Color get darkCardColor => _darkCardColor!;
Color? _darkCardColor;

Color likeColor = const Color.fromARGB(255, 194, 49, 61);
Color ratingColor = const Color.fromARGB(255, 255, 211, 114);

Color primaryRed = const Color(0xffB73E3E);

RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    );

class AppTheme {
  static init(SetThemeState state, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    _cornerRadius = state.cornerRadius;

    _dividerColor =
        state.showOutlines ? colorScheme.onSurface : Colors.transparent;

    _lightBackgroundColor = colorScheme.surfaceContainerLowest;

    _darkBackgroundColor =
        state.amoledDark ? Colors.black : colorScheme.surfaceContainerLowest;

    _lightCardColor = colorScheme.surfaceContainerLowest;

    _darkCardColor = state.amoledDark
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerLow;
  }
}

class ThemeGetters {
  static Color getSelectionColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary.withOpacity(0.4);
}
