import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({
    Key? key,
    required this.defaultHeight,
    required this.onPressed,
  }) : super(key: key);

  final double defaultHeight;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      onTap: onPressed,
      child: Ink(
        height: defaultHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(color: dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(
                  Icons.image,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 15),
                Text(LocaleKeys.click_to_add_cover.tr()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
