import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class TagFilterChip extends StatelessWidget {
  const TagFilterChip({
    super.key,
    required this.tag,
    required this.selected,
    required this.onTagChipPressed,
  });

  final String? tag;
  final bool selected;
  final Function(bool) onTagChipPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(color: dividerColor, width: 1),
        label: Text(
          tag != null ? tag.toString() : LocaleKeys.select_all.tr(),
          style: TextStyle(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        selected: selected,
        selectedColor: Theme.of(context).colorScheme.primary,
        onSelected: onTagChipPressed,
      ),
    );
  }
}
