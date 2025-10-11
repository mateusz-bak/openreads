import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/model/book.dart';

class BookCardListCompact extends StatelessWidget {
  const BookCardListCompact({
    super.key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
    required this.addBottomPadding,
    this.onLongPressed,
    this.cardColor,
  });

  final Book book;
  final String heroTag;
  final bool addBottomPadding;
  final Function() onPressed;
  final Function()? onLongPressed;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    final coverFile = book.getCoverFile();

    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, addBottomPadding ? 90 : 5),
      child: Card.filled(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: cardColor,
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCover(coverFile),
                SizedBox(width: (coverFile != null) ? 15 : 0),
                _buildDetails(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildDetails(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  book.title,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              book.favourite
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FaIcon(
                        FontAwesomeIcons.solidHeart,
                        size: 14,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 10),
              _buildBookFormatIcon(context),
            ],
          ),
          Text(
            book.author,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          book.publicationYear != null
              ? Text(
                  book.publicationYear.toString(),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    letterSpacing: 0.05,
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              book.status == BookStatus.read
                  ? _buildRating(context)
                  : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookFormatIcon(BuildContext context) {
    return BlocBuilder<DisplayCubit, DisplayState>(builder: (context, state) {
      if (!state.bookFormatOnList) return const SizedBox();

      return FaIcon(
        book.bookFormat == BookFormat.audiobook
            ? FontAwesomeIcons.headphones
            : book.bookFormat == BookFormat.ebook
                ? FontAwesomeIcons.tabletScreenButton
                : FontAwesomeIcons.bookOpen,
        size: 14,
        color: Theme.of(context).colorScheme.primaryContainer,
      );
    });
  }

  SizedBox _buildCover(File? coverFile) {
    const coverWidth = 60.0;
    const coverHeight = coverWidth * 1.5;

    return SizedBox(
      width: (coverFile != null) ? coverWidth : 0,
      height: coverHeight,
      child: (coverFile != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Hero(
                tag: heroTag,
                child: Image.file(
                  coverFile,
                  width: coverWidth,
                  height: coverHeight,
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
            )
          : const SizedBox(),
    );
  }

  Widget _buildRating(BuildContext context) {
    return BlocBuilder<RatingTypeBloc, RatingTypeState>(
      builder: (context, state) {
        if (state is RatingTypeBar) {
          return RatingBar.builder(
            initialRating: (book.rating == null) ? 0 : (book.rating! / 10),
            allowHalfRating: true,
            unratedColor: Theme.of(context).colorScheme.surfaceContainerLow,
            glow: false,
            glowRadius: 1,
            itemSize: 16,
            ignoreGestures: true,
            itemPadding: const EdgeInsets.only(right: 3),
            itemBuilder: (context, _) => FaIcon(
              FontAwesomeIcons.solidStar,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            onRatingUpdate: (_) {},
          );
        } else {
          return Row(
            children: [
              Text(
                (book.rating == null) ? '0' : '${(book.rating! / 10)}',
              ),
              const SizedBox(width: 5),
              FaIcon(
                FontAwesomeIcons.solidStar,
                color: Theme.of(context).colorScheme.primaryContainer,
                size: 14,
              ),
            ],
          );
        }
      },
    );
  }
}
