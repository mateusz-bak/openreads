import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';

class BookCardGrid extends StatelessWidget {
  const BookCardGrid({
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

    return Card.filled(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPressed,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: coverFile != null
              ? _buildCardWithCover(
                  heroTag: heroTag,
                  file: coverFile,
                )
              : _buildCardWithoutCover(
                  book: book,
                  context: context,
                ),
        ),
      ),
    );
  }

  Widget _buildCardWithoutCover({
    required Book book,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  book.title,
                  softWrap: true,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  book.author,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithCover({required String heroTag, required File file}) {
    return Hero(
      tag: heroTag,
      child: Image.file(
        file,
        fit: BoxFit.cover,
        frameBuilder: (
          BuildContext context,
          Widget child,
          int? frame,
          bool wasSynchronouslyLoaded,
        ) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }
}
