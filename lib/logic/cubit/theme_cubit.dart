import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:rxdart/rxdart.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(themeMode: ThemeMode.light));

  final BehaviorSubject<AppThemeMode> _appThemeModeFetcher =
      BehaviorSubject<AppThemeMode>();
  Stream<AppThemeMode> get appThemeMode => _appThemeModeFetcher;

  void updateAppThemeAuto() {
    final Brightness currentBrightness = AppTheme.currentSystemBrightness;
    currentBrightness == Brightness.light
        ? _setTheme(ThemeMode.light)
        : _setTheme(ThemeMode.dark);

    _appThemeModeFetcher.sink.add(AppThemeMode.auto);
  }

  void updateAppThemeLight() {
    _setTheme(ThemeMode.light);
    _appThemeModeFetcher.sink.add(AppThemeMode.light);
  }

  void updateAppThemeDark() {
    _setTheme(ThemeMode.dark);
    _appThemeModeFetcher.sink.add(AppThemeMode.dark);
  }

  void _setTheme(ThemeMode themeMode) {
    AppTheme.setStatusAndNavBarsColors(themeMode);
    emit(ThemeState(themeMode: themeMode));
  }
}
