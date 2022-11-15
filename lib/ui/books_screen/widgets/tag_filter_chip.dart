import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class TagFilterChip extends StatelessWidget {
  const TagFilterChip({
    Key? key,
    required this.tag,
    required this.selected,
    required this.onTagChipPressed,
  }) : super(key: key);

  final String tag;
  final bool selected;
  final Function(bool) onTagChipPressed;

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
          tag.toString(),
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).mainTextColor,
          ),
        ),
        checkmarkColor: Colors.white,
        selected: selected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: onTagChipPressed,
      ),
    );
  }
}
