import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({
    super.key,
    required this.defaultHeight,
    required this.onPressed,
  });

  final double defaultHeight;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(cornerRadius),
        dashPattern: const [10, 8],
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        strokeWidth: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            onTap: onPressed,
            child: Ink(
              height: defaultHeight + 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                border: Border.all(color: dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 10,
                ),
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
          ),
        ),
      ),
    );
  }
}
