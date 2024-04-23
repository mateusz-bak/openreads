import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class QuickRatingDialog extends StatefulWidget {
  const QuickRatingDialog({super.key});

  @override
  State<QuickRatingDialog> createState() => _QuickRatingDialogState();
}

class _QuickRatingDialogState extends State<QuickRatingDialog> {
  int? quickRating;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      title: Text(
        LocaleKeys.rate_book.tr(),
        style: const TextStyle(fontSize: 18),
      ),
      content: QuickRating(
        onRatingUpdate: (double newRating) {
          setState(() {
            quickRating = (newRating * 10).toInt();
          });
        },
      ),
      actions: [
        Platform.isIOS
            ? CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(LocaleKeys.skip.tr()),
              )
            : FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
                child: Text(LocaleKeys.skip.tr()),
              ),
        Platform.isIOS
            ? CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop(quickRating);
                },
                child: Text(LocaleKeys.save.tr()),
              )
            : FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(quickRating);
                },
                child: Text(LocaleKeys.save.tr()),
              ),
      ],
    );
  }
}
