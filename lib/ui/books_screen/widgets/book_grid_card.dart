import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';

class BookGridCard extends StatelessWidget {
  const BookGridCard({
    Key? key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
    required this.addBottomPadding,
    this.onLongPressed,
  }) : super(key: key);

  final Book book;
  final String heroTag;
  final bool addBottomPadding;
  final Function() onPressed;
  final Function()? onLongPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      onLongPress: onLongPressed,
      child: book.cover != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Hero(
                tag: heroTag,
                child: Image.memory(
                  book.cover!,
                  fit: BoxFit.fitWidth,
                ),
              ),
            )
          : Card(
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: dividerColor, width: 1),
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      book.author,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
