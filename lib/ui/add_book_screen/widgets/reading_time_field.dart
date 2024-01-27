import 'package:easy_localization/easy_localization.dart';
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
  Widget build(BuildContext context) {
    String formattedText = widget.readingTime != null
        ? widget.readingTime.toString()
        : LocaleKeys.set_custom_reading_time.tr();

    _setTextControllers(widget.readingTime);

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
                            onPressed: () => widget.resetTime(),
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
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: Text(LocaleKeys.set_custom_reading_time.tr(),
                style: const TextStyle(fontSize: 20)),
            contentPadding: const EdgeInsets.symmetric(vertical: 25),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed: () => widget.changeReadingTime(
                  _day.value.text,
                  _hours.value.text,
                  _minutes.value.text,
                ),
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
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        controller: _day,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.day_title.tr(),
                          border: const OutlineInputBorder(),
                          counterText: "",
                        ),
                      )),
                  SizedBox(
                      width: 70,
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        controller: _hours,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 2,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.hour_title.tr(),
                          border: const OutlineInputBorder(),
                          counterText: "",
                        ),
                      )),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _minutes,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 2,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.minute_title.tr(),
                        border: const OutlineInputBorder(),
                        counterText: "",
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  void _setTextControllers(ReadingTime? readingTime) {
    if (readingTime == null) return;
    _day.text = readingTime.days.toString();
    _hours.text = readingTime.hours.toString();
    _minutes.text = readingTime.minutes.toString();
  }
}
