import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookTitleDetail extends StatelessWidget {
  const BookTitleDetail({
    Key? key,
    required this.title,
    required this.author,
    required this.publicationYear,
  }) : super(key: key);

  final String title;
  final String author;
  final String publicationYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).mainTextColor,
            ),
          ),
          Text(
            author,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).secondaryTextColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            publicationYear,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
