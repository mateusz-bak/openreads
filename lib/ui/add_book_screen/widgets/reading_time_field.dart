import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/reading_time.dart';

class BookReadingTimeField extends StatefulWidget {
  const BookReadingTimeField({
    Key? key,
    required this.defaultHeight,
  }) : super(key: key);

  final double defaultHeight;

  @override
  State<BookReadingTimeField> createState() => _BookReadingTimeField();
}

class _BookReadingTimeField extends State<BookReadingTimeField> {
  final _day = TextEditingController();
  final _hours = TextEditingController();
  final _minutes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBookCubit, Book>(builder: (context, state) {
      return buildReadingTimeTextField(context, state);
    });
  }

  @override
  void dispose() {
    _day.dispose();
    _minutes.dispose();
    _hours.dispose();

    super.dispose();
  }

  Future<String?> buildShowDialog(BuildContext context) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text(LocaleKeys.set_reading_time.tr()),
            contentPadding: const EdgeInsets.symmetric(vertical: 25),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text(LocaleKeys.cancel),
              ),
              TextButton(
                onPressed: _changeReadingTime,
                child: Text(LocaleKeys.ok.tr()),
              ),
            ],
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: 70,
                      child: TextField(
                        selectionWidthStyle: BoxWidthStyle.tight,
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        controller: _day,
                        maxLines: 1,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.days.tr(),
                          border: const OutlineInputBorder(),
                          counterText: "",
                        ),
                      )),
                  SizedBox(
                      width: 70,
                      child: TextField(
                        selectionWidthStyle: BoxWidthStyle.tight,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        controller: _hours,
                        maxLines: 1,
                        maxLength: 2,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.hours.tr(),
                          border: const OutlineInputBorder(),
                          counterText: "",
                        ),
                      )),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      selectionWidthStyle: BoxWidthStyle.tight,
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      controller: _minutes,
                      maxLines: 1,
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.minutes.tr(),
                        border: const OutlineInputBorder(),
                        counterText: "",
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  void _changeReadingTime() {
    int days = int.tryParse(_day.value.text) ?? 0;
    int hours = int.tryParse(_hours.value.text) ?? 0;
    int mins = int.tryParse(_minutes.value.text) ?? 0;
    context
        .read<EditBookCubit>()
        .setReadingTime(ReadingTime.toMilliSeconds(days, hours, mins));
    Navigator.pop(context, 'OK');
  }

  void _setTextControllers(ReadingTime? readingTime) {
    if (readingTime == null) return;
    _day.text = readingTime.days.toString();
    _hours.text = readingTime.hours.toString();
    _minutes.text = readingTime.minutes.toString();
  }

  void _resetTime() {
    _day.clear();
    _hours.clear();
    _minutes.clear();
    context.read<EditBookCubit>().setReadingTime(null);
  }

  Widget buildReadingTimeTextField(BuildContext context, Book state) {
    String formattedText = state.readingTime != null
        ? state.readingTime.toString()
        : LocaleKeys.reading_time.tr();
    _setTextControllers(state.readingTime);
    return state.status != 0
        ? const SizedBox()
        : Column(children: [
      const SizedBox(height: 10),
      SizedBox(
        height: widget.defaultHeight,
        width: MediaQuery.of(context).size.width - 20,
        child: Stack(
          children: [
            InkWell(
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
              onTap: () => buildShowDialog(context),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.5),
                  border: Border.all(color: dividerColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.solidClock,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 15),
                        FittedBox(
                          child: Text(
                            formattedText,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (state.readingTime != null)
                      ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                    ),
                    onPressed: _resetTime,
                  ) : const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
