import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class ReadStats extends StatelessWidget {
  const ReadStats({
    Key? key,
    required this.title,
    required this.value,
    this.secondValue,
  }) : super(key: key);

  final String title;
  final String value;
  final String? secondValue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: Theme.of(context).outlineColor,
          width: 1,
        ),
      ),
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).mainTextColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).secondaryTextColor,
              ),
            ),
            (secondValue == null)
                ? const SizedBox()
                : Text(
                    secondValue!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).secondaryTextColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
