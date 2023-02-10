import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

class YearFilterChip extends StatelessWidget {
  const YearFilterChip({
    Key? key,
    required this.dbYear,
    required this.selected,
    required this.onYearChipPressed,
  }) : super(key: key);

  final int dbYear;
  final bool selected;
  final Function(bool) onYearChipPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        label: Text(
          dbYear.toString(),
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).mainTextColor,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
        ),
        checkmarkColor: Colors.white,
        selected: selected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: onYearChipPressed,
      ),
    );
  }
}
