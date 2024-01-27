import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/additional_reading.dart';
import 'package:openreads/model/reading_time.dart';
import 'package:openreads/ui/add_book_screen/widgets/reading_time_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class AdditionalReadingRow extends StatefulWidget {
  const AdditionalReadingRow({
    super.key,
    required this.index,
    required this.reading,
  });

  final int index;
  final AdditionalReading reading;

  @override
  State<AdditionalReadingRow> createState() => _AdditionalReadingRowState();
}

class _AdditionalReadingRowState extends State<AdditionalReadingRow> {
  void _showStartDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final startDate = await showDatePicker(
      context: context,
      // if startDate is null, use DateTime.now()
      initialDate: widget.reading.startDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: LocaleKeys.select_start_date.tr(),
    );

    if (mounted && startDate != null) {
      context.read<EditBookCubit>().setAdditionalStartDate(
            startDate,
            widget.index,
          );
    }
  }

  void _showFinishDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final finishDate = await showDatePicker(
      context: context,
      // if finishDate is null, use DateTime.now()
      initialDate: widget.reading.finishDate ?? DateTime.now(),

      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: LocaleKeys.select_finish_date.tr(),
    );

    if (mounted && finishDate != null) {
      context.read<EditBookCubit>().setAdditionalFinishDate(
            finishDate,
            widget.index,
          );
    }
  }

  void _clearStartDate() {
    context.read<EditBookCubit>().setAdditionalStartDate(null, widget.index);
  }

  void _clearFinishDate() {
    context.read<EditBookCubit>().setAdditionalFinishDate(null, widget.index);
  }

  void _changeReadingTime(
    String daysString,
    String hoursString,
    String minutesString,
  ) {
    int days = int.tryParse(daysString) ?? 0;
    int hours = int.tryParse(hoursString) ?? 0;
    int mins = int.tryParse(minutesString) ?? 0;

    context.read<EditBookCubit>().setAdditionalReadingTime(
          ReadingTime.toMilliSeconds(days, hours, mins),
          widget.index,
        );

    Navigator.pop(context, 'OK');
  }

  void _resetTime() {
    context.read<EditBookCubit>().setAdditionalReadingTime(null, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(
      '${context.locale.languageCode}-${context.locale.countryCode}',
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        LocaleKeys.additional_reading.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: SetDateButton(
                            defaultHeight: defaultFormHeight,
                            icon: FontAwesomeIcons.play,
                            text: widget.reading.startDate != null
                                ? dateFormat.format(widget.reading.startDate!)
                                : LocaleKeys.start_date.tr(),
                            onPressed: _showStartDatePicker,
                            onClearPressed: _clearStartDate,
                            showClearButton: (widget.reading.startDate != null)
                                ? true
                                : false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SetDateButton(
                            defaultHeight: defaultFormHeight,
                            icon: FontAwesomeIcons.flagCheckered,
                            text: widget.reading.finishDate != null
                                ? dateFormat.format(widget.reading.finishDate!)
                                : LocaleKeys.finish_date.tr(),
                            onPressed: _showFinishDatePicker,
                            onClearPressed: _clearFinishDate,
                            showClearButton: (widget.reading.finishDate != null)
                                ? true
                                : false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BookReadingTimeField(
                          defaultHeight: defaultFormHeight,
                          changeReadingTime: _changeReadingTime,
                          resetTime: _resetTime,
                          readingTime: widget.reading.customReadingTime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              context
                  .read<EditBookCubit>()
                  .removeAdditionalReading(widget.index);
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
            ),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
