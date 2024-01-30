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

  onTap(BuildContext context, int heroKey) {
    context.read<CurrentBookCubit>().setBook(book!);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(
          id: book!.id!,
          heroTag: '${book?.id}-$heroKey',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroKey = Random().nextInt(1000000);

    return InkWell(
      borderRadius: BorderRadius.circular(cornerRadius),
      onTap: book != null && book!.id != null
          ? () => onTap(context, heroKey)
          : null,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  book != null && book!.getCoverFile() != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Hero(
                            tag: '${book?.id}-$heroKey',
                            child: Image.file(
                              book!.getCoverFile()!,
                              fit: BoxFit.cover,
                              width: 60,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
