import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/reading_time.dart';
import 'package:openreads/ui/add_book_screen/widgets/reading_time_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class ReadingRow extends StatefulWidget {
  const ReadingRow({
    super.key,
    required this.index,
    required this.reading,
  });

  final int index;
  final Reading reading;

  @override
  State<ReadingRow> createState() => _ReadingRowState();
}

class _ReadingRowState extends State<ReadingRow> {
  void _showStartDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return CupertinoDatePickerBottomSheet(
              text: LocaleKeys.select_start_date.tr(),
              initialDate: widget.reading.startDate ?? DateTime.now(),
              onDateTimeChanged: (value) {
                context.read<EditBookCubit>().setReadingStartDate(
                      value,
                      widget.index,
                    );
              },
            );
          });
    } else if (Platform.isAndroid) {
      final startDate = await showDatePicker(
        context: context,
        initialDate: widget.reading.startDate ?? DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now(),
        helpText: LocaleKeys.select_start_date.tr(),
      );

      if (mounted && startDate != null) {
        context.read<EditBookCubit>().setReadingStartDate(
              startDate,
              widget.index,
            );
      }
    }
  }

  void _showFinishDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (Platform.isIOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (_) {
            return CupertinoDatePickerBottomSheet(
              text: LocaleKeys.select_finish_date.tr(),
              initialDate: widget.reading.finishDate ?? DateTime.now(),
              onDateTimeChanged: (value) {
                context.read<EditBookCubit>().setReadingFinishDate(
                      value,
                      widget.index,
                    );
              },
            );
          });
    } else if (Platform.isAndroid) {
      final finishDate = await showDatePicker(
        context: context,
        initialDate: widget.reading.finishDate ?? DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now(),
        helpText: LocaleKeys.select_finish_date.tr(),
      );

      if (mounted && finishDate != null) {
        context.read<EditBookCubit>().setReadingFinishDate(
              finishDate,
              widget.index,
            );
      }
    }
  }

  void _clearStartDate() {
    context.read<EditBookCubit>().setReadingStartDate(null, widget.index);
  }

  void _clearFinishDate() {
    context.read<EditBookCubit>().setReadingFinishDate(null, widget.index);
  }

  void _changeReadingTime(
    String daysString,
    String hoursString,
    String minutesString,
  ) {
    int days = int.tryParse(daysString) ?? 0;
    int hours = int.tryParse(hoursString) ?? 0;
    int mins = int.tryParse(minutesString) ?? 0;

    if (days != 0 || hours != 0 || mins != 0) {
      context.read<EditBookCubit>().setCustomReadingTime(
            ReadingTime.toMilliSeconds(days, hours, mins),
            widget.index,
          );
    }

    Navigator.pop(context, 'OK');
  }

  void _resetTime() {
    context.read<EditBookCubit>().setCustomReadingTime(null, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: SetDateButton(
                            defaultHeight: Constants.formHeight,
                            icon: FontAwesomeIcons.play,
                            date: widget.reading.startDate,
                            text: LocaleKeys.start_date.tr(),
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
                            defaultHeight: Constants.formHeight,
                            icon: FontAwesomeIcons.flagCheckered,
                            date: widget.reading.finishDate,
                            text: LocaleKeys.finish_date.tr(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BookReadingTimeField(
                        defaultHeight: Constants.formHeight,
                        changeReadingTime: _changeReadingTime,
                        resetTime: _resetTime,
                        readingTime: widget.reading.customReadingTime,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              context.read<EditBookCubit>().removeReading(widget.index);
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }
}
