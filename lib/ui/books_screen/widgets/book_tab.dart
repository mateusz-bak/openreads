import 'package:flutter/material.dart';

class BookTab extends StatelessWidget {
  const BookTab({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(text),
    );
  }
}
