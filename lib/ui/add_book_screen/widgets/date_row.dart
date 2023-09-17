import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/generated/locale_keys.g.dart';
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
    required this.clearStartDate,
    required this.clearFinishDate,
    required this.showClearStartDate,
    required this.showClearFinishDate,
  }) : super(key: key);

  final Duration animDuration;
  final int? status;
  final double defaultHeight;
  final DateTime? startDate;
  final DateTime? finishDate;
  final Function() showStartDatePicker;
  final Function() showFinishDatePicker;
  final Function() clearStartDate;
  final Function() clearFinishDate;
  final bool showClearStartDate;
  final bool showClearFinishDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedContainer(
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
                        : (MediaQuery.of(context).size.width - 40) / 2,
                child: SetDateButton(
                  defaultHeight: defaultHeight,
                  icon: FontAwesomeIcons.play,
                  text: (startDate == null)
                      ? LocaleKeys.start_date.tr()
                      : '${startDate?.day}/${startDate?.month}/${startDate?.year}',
                  onPressed: showStartDatePicker,
                  onClearPressed: clearStartDate,
                  showClearButton: showClearStartDate,
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
                    ? (MediaQuery.of(context).size.width - 20) / 2
                    : 0,
                child: SetDateButton(
                  defaultHeight: defaultHeight,
                  icon: FontAwesomeIcons.flagCheckered,
                  text: (finishDate == null)
                      ? LocaleKeys.finish_date.tr()
                      : '${finishDate?.day}/${finishDate?.month}/${finishDate?.year}',
                  onPressed: showFinishDatePicker,
                  onClearPressed: clearFinishDate,
                  showClearButton: showClearFinishDate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
