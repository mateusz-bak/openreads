import 'package:flutter/material.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BookGridCard extends StatelessWidget {
  const BookGridCard({
    super.key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
    required this.addBottomPadding,
    this.onLongPressed,
  });

  final Book book;
  final String heroTag;
  final bool addBottomPadding;
  final Function() onPressed;
  final Function()? onLongPressed;

  @override
  Widget build(BuildContext context) {
    final coverFile = book.getCoverFile();

    return InkWell(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: coverFile != null
              ? GridCardCover(
                  heroTag: heroTag,
                  file: coverFile,
                )
              : GridCardNoCover(book: book)),
    );
  }
}
