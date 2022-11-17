part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
}

class SetThemeState extends ThemeState {
  final ThemeMode themeMode;
  final bool showOutlines;
  final double cornerRadius;

  const SetThemeState({
    required this.themeMode,
    required this.showOutlines,
    required this.cornerRadius,
  });

  @override
  List<Object> get props => [themeMode, showOutlines, cornerRadius];
}
