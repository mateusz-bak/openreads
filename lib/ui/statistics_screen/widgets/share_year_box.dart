import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class ShareYearBox extends StatelessWidget {
  const ShareYearBox({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(cornerRadius),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 15,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.share_year_in_books.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              ShareYearButton(onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}
