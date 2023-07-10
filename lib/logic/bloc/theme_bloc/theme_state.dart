part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
}

class ChangingThemeState extends ThemeState {
  const ChangingThemeState();

  @override
  List<Object?> get props => [];
}

class SetThemeState extends ThemeState {
  final ThemeMode themeMode;
  final bool showOutlines;
  final double cornerRadius;
  final Color primaryColor;
  final String? fontFamily;
  final bool readTabFirst;
  final bool useMaterialYou;
  final bool amoledDark;

  const SetThemeState({
    required this.themeMode,
    required this.showOutlines,
    required this.cornerRadius,
    required this.primaryColor,
    required this.fontFamily,
    required this.readTabFirst,
    required this.useMaterialYou,
    required this.amoledDark,
  });

  SetThemeState copyWith({
    ThemeMode? themeMode,
    bool? showOutlines,
    double? cornerRadius,
    Color? primaryColor,
    String? fontFamily,
    bool? readTabFirst,
    bool? useMaterialYou,
    bool? amoledDark,
  }) {
    return SetThemeState(
      themeMode: themeMode ?? this.themeMode,
      showOutlines: showOutlines ?? this.showOutlines,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      readTabFirst: readTabFirst ?? this.readTabFirst,
      useMaterialYou: useMaterialYou ?? this.useMaterialYou,
      amoledDark: amoledDark ?? this.amoledDark,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        showOutlines,
        cornerRadius,
        primaryColor,
        fontFamily,
        readTabFirst,
        useMaterialYou,
        amoledDark,
      ];
}
