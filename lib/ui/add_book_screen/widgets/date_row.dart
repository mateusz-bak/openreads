import 'package:flutter/material.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class DateRow extends StatelessWidget {
  const DateRow({
    Key? key,
    required this.animDuration,
    required this.status,
    required this.defaultHeight,
    required this.startDate,
    required this.finishDate,
    required this.showStartDatePicker,
    required this.showFinishDatePicker,
  }) : super(key: key);

  final Duration animDuration;
  final int? status;
  final double defaultHeight;
  final DateTime? startDate;
  final DateTime? finishDate;
  final Function() showStartDatePicker;
  final Function() showFinishDatePicker;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animDuration,
      height: (status == 2 || status == null) ? 0 : defaultHeight,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Row(
          children: [
            AnimatedContainer(
              duration: animDuration,
              width: (status == 1 || status == 3)
                  ? (MediaQuery.of(context).size.width - 20)
                  : (status == 2)
                      ? (MediaQuery.of(context).size.width - 20)
                      : (MediaQuery.of(context).size.width - 30) / 2,
              child: SetDateButton(
                defaultHeight: defaultHeight,
                icon: Icons.timer_outlined,
                text: (startDate == null)
                    ? 'Start Date'
                    : '${startDate?.day}/${startDate?.month}/${startDate?.year}',
                onPressed: showStartDatePicker,
              ),
            ),
            AnimatedContainer(
              duration: animDuration,
              width: (status == 0) ? 10 : 0,
            ),
            AnimatedContainer(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              duration: animDuration,
              width: (status == 0)
                  ? (MediaQuery.of(context).size.width - 30) / 2
                  : 0,
              child: SetDateButton(
                defaultHeight: defaultHeight,
                icon: Icons.timer_off_outlined,
                text: (finishDate == null)
                    ? 'Finish Date'
                    : '${finishDate?.day}/${finishDate?.month}/${finishDate?.year}',
                onPressed: showFinishDatePicker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
