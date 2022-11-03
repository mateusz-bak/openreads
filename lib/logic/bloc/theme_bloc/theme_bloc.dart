import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';
part 'theme_event.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeAutoState()) {
    on<ChangeThemeEvent>((event, emit) {
      switch (event.themeMode) {
        case ThemeMode.light:
          emit(ThemeLightState());
          break;
        case ThemeMode.dark:
          emit(ThemeDarkState());
          break;
        default:
          emit(ThemeAutoState());
          break;
      }
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final storedValue = json['ThemeState'] as int;

    switch (storedValue) {
      case 1:
        return ThemeLightState();
      case 2:
        return ThemeDarkState();
      default:
        return ThemeAutoState();
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    if (state is ThemeLightState) {
      return {'ThemeState': 1};
    } else if (state is ThemeDarkState) {
      return {'ThemeState': 2};
    } else {
      return {'ThemeState': 0};
    }
  }
}
