import 'package:flutter/material.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

double get cornerRadius => _cornerRadius!;
double? _cornerRadius;
bool get readTabFirst => _readTabFirst!;
bool? _readTabFirst;
Color get dividerColor => _dividerColor!;
Color? _dividerColor;

Color likeColor = const Color.fromARGB(255, 255, 71, 120);
Color ratingColor = const Color.fromARGB(255, 255, 211, 114);

Color primaryGreen = const Color(0xff285430);
Color primaryBlue = const Color(0xff2146C7);
Color primaryRed = const Color(0xffB73E3E);
Color primaryYellow = const Color.fromARGB(255, 204, 177, 2);
Color primaryOrange = const Color(0xffE14D2A);
Color primaryPurple = const Color(0xff9F73AB);
Color primaryPink = const Color(0xffFF577F);
Color primaryTeal = const Color(0xff3FA796);

class AppTheme {
  static init(SetThemeState state, BuildContext context) {
    _cornerRadius = state.cornerRadius;
    _readTabFirst = state.readTabFirst;
    _dividerColor = state.showOutlines
        ? Theme.of(context).colorScheme.onSurface
        : Colors.transparent;
  }
}
