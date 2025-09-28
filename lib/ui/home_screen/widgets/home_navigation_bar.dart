import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  // List<NavigationDestination> _addHubDestination(bool useHub) {
  //   return useHub
  //       ? [
  //           const NavigationDestination(
  //             icon: FaIcon(FontAwesomeIcons.users),
  //             label: 'Hub',
  //           ),
  //         ]
  //       : [];
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WelcomeBloc, WelcomeState>(builder: (context, state) {
      // final useHub = state is HideWelcomeState ? state.useHub : false;
      return NavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? darkBackgroundColor
            : lightBackgroundColor,
        onDestinationSelected: (int index) {
          widget.onTap(index);
        },
        selectedIndex: widget.currentIndex,
        destinations: <Widget>[
          NavigationDestination(
            icon: const FaIcon(FontAwesomeIcons.bars),
            label: LocaleKeys.books_settings.tr(),
          ),
          NavigationDestination(
            icon: const FaIcon(FontAwesomeIcons.chartSimple),
            label: LocaleKeys.statistics.tr(),
          ),
          // ..._addHubDestination(useHub),
        ],
      );
    });
  }
}
