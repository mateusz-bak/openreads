import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class BookStatusRow extends StatelessWidget {
  const BookStatusRow({
    Key? key,
    required this.animDuration,
    required this.defaultHeight,
    required this.currentStatus,
    required this.onPressed,
  }) : super(key: key);

  final Duration animDuration;
  final double defaultHeight;
  final int? currentStatus;

  final Function(int, bool) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedStatusButton(
          duration: animDuration,
          height: defaultHeight,
          icon: Icons.done,
          text: LocaleKeys.book_status_finished.tr(),
          isSelected: currentStatus == 0,
          currentStatus: currentStatus,
          onPressed: () {
            onPressed(0, true);
          },
        ),
        const SizedBox(width: 10),
        AnimatedStatusButton(
          duration: animDuration,
          height: defaultHeight,
          icon: Icons.autorenew,
          text: LocaleKeys.book_status_in_progress.tr(),
          isSelected: currentStatus == 1,
          currentStatus: currentStatus,
          onPressed: () {
            onPressed(1, true);
          },
        ),
        const SizedBox(width: 10),
        AnimatedStatusButton(
          duration: animDuration,
          height: defaultHeight,
          icon: Icons.timelapse,
          text: LocaleKeys.book_status_for_later.tr(),
          isSelected: currentStatus == 2,
          currentStatus: currentStatus,
          onPressed: () {
            onPressed(2, true);
          },
        ),
        const SizedBox(width: 10),
        AnimatedStatusButton(
          duration: animDuration,
          height: defaultHeight,
          icon: Icons.not_interested,
          text: LocaleKeys.book_status_unfinished.tr(),
          isSelected: currentStatus == 3,
          currentStatus: currentStatus,
          onPressed: () {
            onPressed(3, true);
          },
        ),
      ],
    );
  }
}
