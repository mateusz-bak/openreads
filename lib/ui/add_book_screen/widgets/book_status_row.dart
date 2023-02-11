import 'package:flutter/material.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class BookStatusRow extends StatelessWidget {
  const BookStatusRow({
    Key? key,
    required this.animDuration,
    required this.defaultHeight,
    required this.colors,
    required this.widths,
    required this.backgroundColors,
    required this.onPressed,
  }) : super(key: key);

  final Duration animDuration;
  final double defaultHeight;
  final List<Color> colors;
  final List<double> widths;
  final List backgroundColors;
  final Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedStatusButton(
          duration: animDuration,
          width: widths[0],
          height: defaultHeight,
          icon: Icons.done,
          text: l10n.book_status_finished,
          color: colors[0],
          backgroundColor: backgroundColors[0],
          onPressed: () {
            onPressed(0);
          },
        ),
        const SizedBox(width: 10),
        AnimatedStatusButton(
            duration: animDuration,
            width: widths[1],
            height: defaultHeight,
            icon: Icons.autorenew,
            text: l10n.book_status_in_progress,
            color: colors[1],
            backgroundColor: backgroundColors[1],
            onPressed: () {
              onPressed(1);
            }),
        const SizedBox(width: 10),
        AnimatedStatusButton(
            duration: animDuration,
            width: widths[2],
            height: defaultHeight,
            icon: Icons.timelapse,
            text: l10n.book_status_for_later,
            color: colors[2],
            backgroundColor: backgroundColors[2],
            onPressed: () {
              onPressed(2);
            }),
        const SizedBox(width: 10),
        AnimatedStatusButton(
            duration: animDuration,
            width: widths[3],
            height: defaultHeight,
            icon: Icons.not_interested,
            text: l10n.book_status_unfinished,
            color: colors[3],
            backgroundColor: backgroundColors[3],
            onPressed: () {
              onPressed(3);
            }),
      ],
    );
  }
}
