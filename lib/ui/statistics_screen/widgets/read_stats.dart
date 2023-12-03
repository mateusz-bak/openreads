import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';

class ReadStats extends StatelessWidget {
  const ReadStats({
    super.key,
    required this.title,
    required this.value,
    this.secondValue,
    this.iconData,
    this.book,
  });

  final String title;
  final String value;
  final String? secondValue;
  final IconData? iconData;
  final Book? book;

  onTap(BuildContext context) {
    context.read<CurrentBookCubit>().setBook(book!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(
          id: book!.id!,
          heroTag: Random().nextInt(1000000).toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(cornerRadius),
      onTap: book != null && book!.id != null ? () => onTap(context) : null,
      child: Card(
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
      ),
    );
  }
}
