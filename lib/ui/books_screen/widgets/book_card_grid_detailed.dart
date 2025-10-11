import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/model/book.dart';

class BookCardGridDetailed extends StatelessWidget {
  const BookCardGridDetailed({
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPressed,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            children: [
              Expanded(
                child: coverFile != null
                    ? _buildCardWithCover(coverFile)
                    : _buildCardWithoutCover(context),
              ),
              _buildBottomTitle(),
              _buildBottomAuthor(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWithCover(File file) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
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
          ),
          _buildTitleOverlay(),
        ],
      ),
    );
  }

  Widget _buildBottomTitle() {
    return BlocBuilder<DisplayCubit, DisplayState>(builder: (context, state) {
      if (state.showTitleOverCover) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomAuthor() {
    return BlocBuilder<DisplayCubit, DisplayState>(builder: (context, state) {
      if (state.showTitleOverCover) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTitleOverlay() {
    return BlocBuilder<DisplayCubit, DisplayState>(
      builder: (context, state) {
        if (!state.showTitleOverCover) return const SizedBox.shrink();

        return Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(15),
                  Colors.black.withAlpha(100),
                  Colors.black.withAlpha(150),
                  Colors.black.withAlpha(220),
                ],
                stops: const [0.0, 0.1, 0.4, 1.0],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 10, 2, 5),
              child: Text(
                book.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardWithoutCover(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        _buildTitleOverlay(),
      ],
    );
  }
}
