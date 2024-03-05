import 'package:flutter/material.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

double get cornerRadius => _cornerRadius!;
double? _cornerRadius;
bool get readTabFirst => _readTabFirst!;
bool? _readTabFirst;
Color get dividerColor => _dividerColor!;
Color? _dividerColor;

Color likeColor = const Color.fromARGB(255, 194, 49, 61);
Color ratingColor = const Color.fromARGB(255, 255, 211, 114);

Color primaryRed = const Color(0xffB73E3E);

class AppTheme {
  static init(SetThemeState state, BuildContext context) {
    _cornerRadius = state.cornerRadius;
    _readTabFirst = state.readTabFirst;
    _dividerColor = state.showOutlines
        ? Theme.of(context).colorScheme.onSurface
        : Colors.transparent;
  }
}

class ThemeGetters {
  static Color getSelectionColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary.withOpacity(0.4);
}
