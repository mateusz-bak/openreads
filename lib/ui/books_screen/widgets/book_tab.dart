import 'package:flutter/material.dart';

class BookTab extends StatelessWidget {
  const BookTab({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
