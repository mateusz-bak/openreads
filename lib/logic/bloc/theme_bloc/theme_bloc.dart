import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';
part 'theme_event.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(const SetThemeState(
          themeMode: ThemeMode.system,
          showOutlines: true,
          cornerRadius: 5,
        )) {
    on<ChangeThemeEvent>((event, emit) {
      emit(SetThemeState(
        themeMode: event.themeMode,
        showOutlines: event.showOutlines,
        cornerRadius: event.cornerRadius,
      ));
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final themeState = json['theme_state'] as int;
    final showOutlines = json['show_outlines'] as bool;
    final cornerRadius = json['corner_radius'] as double;

    switch (themeState) {
      case 1:
        return SetThemeState(
          themeMode: ThemeMode.light,
          showOutlines: showOutlines,
          cornerRadius: cornerRadius,
        );
      case 2:
        return SetThemeState(
          themeMode: ThemeMode.dark,
          showOutlines: showOutlines,
          cornerRadius: cornerRadius,
        );
      default:
        return SetThemeState(
          themeMode: ThemeMode.system,
          showOutlines: showOutlines,
          cornerRadius: cornerRadius,
        );
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    if (state is SetThemeState) {
      switch (state.themeMode) {
        case ThemeMode.light:
          return {
            'theme_state': 1,
            'show_outlines': state.showOutlines,
            'corner_radius': state.cornerRadius,
          };
        case ThemeMode.dark:
          return {
            'theme_state': 2,
            'show_outlines': state.showOutlines,
            'corner_radius': state.cornerRadius,
          };
        case ThemeMode.system:
          return {
            'theme_state': 0,
            'show_outlines': state.showOutlines,
            'corner_radius': state.cornerRadius,
          };
      }
    } else {
      return {
        'theme_state': 0,
        'show_outlines': true,
        'corner_radius': 5,
      };
    }
  }
}
