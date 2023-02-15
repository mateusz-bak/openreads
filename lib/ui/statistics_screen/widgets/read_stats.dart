import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class ReadStats extends StatelessWidget {
  const ReadStats({
    Key? key,
    required this.title,
    required this.value,
    this.secondValue,
    this.iconData,
  }) : super(key: key);

  final String title;
  final String value;
  final String? secondValue;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            (iconData == null)
                ? Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        iconData,
                        size: 16,
                        color: ratingColor,
                      ),
                    ],
                  ),
            (secondValue == null)
                ? const SizedBox()
                : Text(
                    secondValue!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
