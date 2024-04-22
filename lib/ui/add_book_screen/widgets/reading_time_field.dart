import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/reading_time.dart';

class BookReadingTimeField extends StatefulWidget {
  const BookReadingTimeField({
    super.key,
    required this.defaultHeight,
    required this.changeReadingTime,
    required this.resetTime,
    required this.readingTime,
  });

  final double defaultHeight;
  final Function(String, String, String) changeReadingTime;
  final Function resetTime;
  final ReadingTime? readingTime;

  @override
  State<BookReadingTimeField> createState() => _BookReadingTimeField();
}

class _BookReadingTimeField extends State<BookReadingTimeField> {
  final _day = TextEditingController();
  final _hours = TextEditingController();
  final _minutes = TextEditingController();

  @override
  void initState() {
    _setTextControllers(widget.readingTime);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String formattedText = widget.readingTime != null
        ? widget.readingTime.toString()
        : LocaleKeys.set_custom_reading_time.tr();

    return Column(children: [
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: SizedBox(
          height: widget.defaultHeight,
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
                    (widget.readingTime != null)
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                            ),
                            onPressed: () {
                              _setTextControllers(null);

                              widget.resetTime();
                            },
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    _day.dispose();
    _minutes.dispose();
    _hours.dispose();

    super.dispose();
  }

  Future<String?> buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog.adaptive(
            title: Text(
              LocaleKeys.set_custom_reading_time.tr(),
              style: const TextStyle(fontSize: 20),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 25),
            actions: <Widget>[
              Platform.isIOS
                  ? CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: Text(LocaleKeys.cancel.tr()),
                    )
                  : FilledButton.tonal(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        )),
                      ),
                      child: Text(LocaleKeys.cancel.tr()),
                    ),
              Platform.isIOS
                  ? CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => widget.changeReadingTime(
                        _day.value.text,
                        _hours.value.text,
                        _minutes.value.text,
                      ),
                      child: Text(LocaleKeys.ok.tr()),
                    )
                  : FilledButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        )),
                      ),
                      onPressed: () => widget.changeReadingTime(
                        _day.value.text,
                        _hours.value.text,
                        _minutes.value.text,
                      ),
                      child: Text(LocaleKeys.ok.tr()),
                    ),
            ],
            content: Padding(
              padding: EdgeInsets.only(
                top: Platform.isIOS ? 20 : 0,
                bottom: Platform.isIOS ? 10 : 0,
              ),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTextField(
                      controller: _day,
                      maxLength: 5,
                      text: LocaleKeys.daysSetCustomTimeTitle.tr(),
                    ),
                    _buildTextField(
                      controller: _hours,
                      maxLength: 2,
                      text: LocaleKeys.hoursSetCustomTimeTitle.tr(),
                    ),
                    _buildTextField(
                      controller: _minutes,
                      maxLength: 2,
                      text: LocaleKeys.minutesSetCustomTimeTitle.tr(),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required int maxLength,
    required String text,
  }) {
    return SizedBox(
      width: 70,
      child: Platform.isIOS
          ? CupertinoTextField(
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
              controller: controller,
              maxLength: maxLength,
              placeholder: text,
            )
          : TextField(
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
              controller: controller,
              maxLength: maxLength,
              decoration: InputDecoration(
                labelText: text,
                border: const OutlineInputBorder(),
                counterText: "",
              ),
            ),
    );
  }

  void _setTextControllers(ReadingTime? readingTime) {
    if (readingTime == null) {
      _day.clear();
      _hours.clear();
      _minutes.clear();
    } else {
      _day.text = readingTime.days.toString();
      _hours.text = readingTime.hours.toString();
      _minutes.text = readingTime.minutes.toString();
    }
  }
}
