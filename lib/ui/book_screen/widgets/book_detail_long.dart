import 'package:flutter/material.dart';

import 'package:openreads/core/themes/app_theme.dart';

class BookDetailLong extends StatelessWidget {
  const BookDetailLong({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 0.5,
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
