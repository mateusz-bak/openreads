import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookDetail extends StatelessWidget {
  const BookDetail({
    Key? key,
    required this.title,
    required this.text,
  }) : super(key: key);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).mainTextColor,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
