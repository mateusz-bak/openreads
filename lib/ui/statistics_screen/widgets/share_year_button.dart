import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class ShareYearButton extends StatelessWidget {
  const ShareYearButton({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      // primary is too close to primaryContainer in dark mode
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        foregroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      tooltip: LocaleKeys.share_year_in_books.tr(),
      icon: const Icon(
        Icons.share_rounded,
        size: 18,
      ),
    );
  }
}
