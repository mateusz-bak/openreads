import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(color: dividerColor, width: 1),
        label: Text(
          dbYear.toString(),
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        selected: selected,
        selectedColor: Theme.of(context).colorScheme.primary,
        onSelected: onYearChipPressed,
      ),
    );
  }
}
