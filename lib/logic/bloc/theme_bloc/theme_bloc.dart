import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';
part 'theme_event.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  String fontFamily = 'Nunito';

  ThemeBloc()
      : super(const SetThemeState(
          themeMode: ThemeMode.system,
          showOutlines: true,
          cornerRadius: 5,
          primaryColor: Color(0xff3FA796),
          fontFamily: 'Nunito',
          readTabFirst: true,
        )) {
    on<ChangeThemeEvent>((event, emit) {
      fontFamily = event.fontFamily;

      emit(SetThemeState(
        themeMode: event.themeMode,
        showOutlines: event.showOutlines,
        cornerRadius: event.cornerRadius,
        primaryColor: event.primaryColor,
        fontFamily: fontFamily,
        readTabFirst: event.readTabFirst,
      ));
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final themeState = json['theme_state'] as int?;
    final showOutlines = json['show_outlines'] as bool?;
    final cornerRadius = json['corner_radius'] as double?;
    final primaryColor = json['primary_color'] as int?;
    final fontFamily = json['font_family'] as String?;
    final readTabFirst = json['read_tab_first'] as bool?;

    switch (themeState) {
      case 1:
        return SetThemeState(
          themeMode: ThemeMode.light,
          showOutlines: showOutlines ?? true,
          cornerRadius: cornerRadius ?? 5,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          readTabFirst: readTabFirst ?? true,
        );
      case 2:
        return SetThemeState(
          themeMode: ThemeMode.dark,
          showOutlines: showOutlines ?? true,
          cornerRadius: cornerRadius ?? 5,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          readTabFirst: readTabFirst ?? true,
        );
      default:
        return SetThemeState(
          themeMode: ThemeMode.system,
          showOutlines: showOutlines ?? true,
          cornerRadius: cornerRadius ?? 5,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          readTabFirst: readTabFirst ?? true,
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
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'read_tab_first': state.readTabFirst,
          };
        case ThemeMode.dark:
          return {
            'theme_state': 2,
            'show_outlines': state.showOutlines,
            'corner_radius': state.cornerRadius,
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'read_tab_first': state.readTabFirst,
          };
        case ThemeMode.system:
          return {
            'theme_state': 0,
            'show_outlines': state.showOutlines,
            'corner_radius': state.cornerRadius,
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'read_tab_first': state.readTabFirst,
          };
      }
    } else {
      return {
        'theme_state': 0,
        'show_outlines': true,
        'corner_radius': 5,
        'primary_color': null,
        'font_family': null,
        'read_tab_first': null,
      };
    }
  }
}
