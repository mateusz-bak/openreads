import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class CupertinoDatePickerBottomSheet extends StatefulWidget {
  const CupertinoDatePickerBottomSheet({
    super.key,
    required this.text,
    required this.onDateTimeChanged,
    required this.initialDate,
  });

  final String text;
  final Function(DateTime) onDateTimeChanged;
  final DateTime initialDate;

  @override
  State<CupertinoDatePickerBottomSheet> createState() =>
      _CupertinoDatePickerBottomSheetState();
}

class _CupertinoDatePickerBottomSheetState
    extends State<CupertinoDatePickerBottomSheet> {
  late DateTime selectedDate;

  @override
  void initState() {
    selectedDate = widget.initialDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: CupertinoDatePicker(
                initialDateTime: widget.initialDate,
                minimumDate: DateTime(1970),
                maximumDate: DateTime.now(),
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    selectedDate = newDateTime;
                  });

                  widget.onDateTimeChanged(selectedDate);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: CupertinoButton(
                onPressed: () {
                  widget.onDateTimeChanged(selectedDate);
                  Navigator.of(context).pop();
                },
                child: Center(child: Text(LocaleKeys.save.tr())),
              ),
            )
          ],
        ),
      ),
    );
  }
}
