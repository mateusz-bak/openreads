import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

// Use insetad of Scaffold to apply theming to entire screen
class ThemedScaffold extends StatelessWidget {
  const ThemedScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    // Added BlocBuilder rebuilds Scaffold when light/dark mode is changed
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      if (themeState is! SetThemeState) {
        return const SizedBox();
      } else {
        AppTheme.init(themeState, context);
      }

      return Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? darkBackgroundColor
                  : lightBackgroundColor,
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? darkBackgroundColor
                : lightBackgroundColor,
          ),
        ),
        child: Scaffold(
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          bottomNavigationBar: bottomNavigationBar,
        ),
      );
    });
  }
}
