import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';
part 'theme_event.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  String? fontFamily = 'Nunito';

  ThemeBloc()
      : super(SetThemeState(
          themeMode: ThemeMode.system,
          primaryColor: const Color(0xff3FA796),
          fontFamily: 'Nunito',
          useMaterialYou: Platform.isAndroid ? true : false,
          amoledDark: false,
        )) {
    on<ChangeThemeEvent>((event, emit) {
      fontFamily = event.fontFamily;

      emit(const ChangingThemeState());

      emit(SetThemeState(
        themeMode: event.themeMode,
        primaryColor: event.primaryColor,
        fontFamily: fontFamily,
        useMaterialYou: event.useMaterialYou,
        amoledDark: event.amoledDark,
      ));
    });
    on<ChangeAccentEvent>((event, emit) {
      if (state is SetThemeState) {
        final themeState = state as SetThemeState;

        emit(const ChangingThemeState());

        emit(themeState.copyWith(
          primaryColor: event.primaryColor,
          useMaterialYou: event.useMaterialYou,
        ));
      }
    });
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    final themeState = json['theme_state'] as int?;

    final primaryColor = json['primary_color'] as int?;
    final fontFamily = json['font_family'] as String?;
    final useMaterialYou = json['use_material_you'] as bool?;
    final amoledDark = json['amoled_dark'] as bool?;

    switch (themeState) {
      case 1:
        return SetThemeState(
          themeMode: ThemeMode.light,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          useMaterialYou: useMaterialYou ?? true,
          amoledDark: amoledDark ?? false,
        );
      case 2:
        return SetThemeState(
          themeMode: ThemeMode.dark,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          useMaterialYou: useMaterialYou ?? true,
          amoledDark: amoledDark ?? false,
        );
      default:
        return SetThemeState(
          themeMode: ThemeMode.system,
          primaryColor: Color(primaryColor ?? 0xff2146C7),
          fontFamily: fontFamily ?? 'Nunito',
          useMaterialYou: useMaterialYou ?? true,
          amoledDark: amoledDark ?? false,
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
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'use_material_you': state.useMaterialYou,
            'amoled_dark': state.amoledDark,
          };
        case ThemeMode.dark:
          return {
            'theme_state': 2,
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'use_material_you': state.useMaterialYou,
            'amoled_dark': state.amoledDark,
          };
        case ThemeMode.system:
          return {
            'theme_state': 0,
            'primary_color': state.primaryColor.value,
            'font_family': state.fontFamily,
            'use_material_you': state.useMaterialYou,
            'amoled_dark': state.amoledDark,
          };
      }
    } else {
      return {
        'theme_state': 0,
        'primary_color': null,
        'font_family': null,
        'read_tab_first': null,
        'use_material_you': null,
        'locale': null,
        'amoled_dark': false,
      };
    }
  }
}
