import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_finished_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_for_later_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_in_progress_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_state.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_unfinished_books_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

class BookCard extends StatefulWidget {
  const BookCard({
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
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  Widget _buildSortAttribute() {
    switch (widget.book.status) {
      case BookStatus.read:
        return BlocBuilder<SortFinishedBooksBloc, SortState>(
          builder: (_, state) => _buildSortAttributeContent(state.sortType),
        );
      case BookStatus.inProgress:
        return BlocBuilder<SortInProgressBooksBloc, SortState>(
          builder: (_, state) => _buildSortAttributeContent(state.sortType),
        );
      case BookStatus.forLater:
        return BlocBuilder<SortForLaterBooksBloc, SortState>(
          builder: (_, state) => _buildSortAttributeContent(state.sortType),
        );
      case BookStatus.unfinished:
        return BlocBuilder<SortUnfinishedBooksBloc, SortState>(
          builder: (_, state) => _buildSortAttributeContent(state.sortType),
        );
    }
  }

  Widget _buildSortAttributeContent(SortType sortType) {
    if (sortType == SortType.byPages) {
      return (widget.book.pages != null)
          ? _buildPagesAttribute()
          : const SizedBox();
    } else if (sortType == SortType.byStartDate) {
      final latestStartDate = getLatestStartDate(widget.book);

      return (latestStartDate != null)
          ? _buildDateAttribute(
              latestStartDate,
              LocaleKeys.started_on_date.tr(),
              false,
            )
          : const SizedBox();
    } else if (sortType == SortType.byFinishDate) {
      final latestFinishDate = getLatestFinishDate(widget.book);

      return (latestFinishDate != null)
          ? _buildDateAttribute(
              latestFinishDate,
              LocaleKeys.finished_on_date.tr(),
              false,
            )
          : const SizedBox();
    } else if (sortType == SortType.byDateAdded) {
      return _buildDateAttribute(
        widget.book.dateAdded,
        LocaleKeys.added_on.tr(),
        true,
      );
    } else if (sortType == SortType.byDateModified) {
      return _buildDateAttribute(
        widget.book.dateModified,
        LocaleKeys.modified_on.tr(),
        true,
      );
    } else if (sortType == SortType.byPublicationYear) {
      return (widget.book.publicationYear != null)
          ? _buildPublicationYearAttribute()
          : const SizedBox();
    }

    return const SizedBox();
  }

  Text _buildPagesAttribute() =>
      Text('${widget.book.pages} ${LocaleKeys.pages_lowercase.tr()}');

  Column _buildPublicationYearAttribute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          LocaleKeys.enter_publication_year.tr(),
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          widget.book.publicationYear.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Column _buildDateAttribute(
    DateTime date,
    String label,
    bool includeTime,
  ) {
    const timeTextStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        includeTime
            ? Text(
                '${dateFormat.format(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: timeTextStyle,
              )
            : Text(
                dateFormat.format(date),
                style: timeTextStyle,
              ),
      ],
    );
  }

  Widget _buildTags() {
    switch (widget.book.status) {
      case BookStatus.read:
        return BlocBuilder<SortFinishedBooksBloc, SortState>(
          builder: (_, state) => _buildTagsContent(state.displayTags),
        );
      case BookStatus.inProgress:
        return BlocBuilder<SortInProgressBooksBloc, SortState>(
          builder: (_, state) => _buildTagsContent(state.displayTags),
        );
      case BookStatus.forLater:
        return BlocBuilder<SortForLaterBooksBloc, SortState>(
          builder: (_, state) => _buildTagsContent(state.displayTags),
        );
      case BookStatus.unfinished:
        return BlocBuilder<SortUnfinishedBooksBloc, SortState>(
          builder: (_, state) => _buildTagsContent(state.displayTags),
        );
    }
  }

  Widget _buildTagsContent(bool displayTags) {
    if (displayTags) {
      return (widget.book.tags == null)
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    children: _generateTagChips(context: context),
                  ),
                ),
              ],
            );
    }

    return const SizedBox();
  }

  Widget _buildTagChip({
    required String tag,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        padding: const EdgeInsets.all(5),
        label: Text(
          tag,
          style: const TextStyle(fontSize: 12),
        ),
        onSelected: (_) {},
      ),
    );
  }

  List<Widget> _generateTagChips({required BuildContext context}) {
    final chips = List<Widget>.empty(growable: true);

    if (widget.book.tags == null) {
      return [];
    }

    final tags = widget.book.tags!.split('|||||');

    tags.sort((a, b) => removeDiacritics(a.toLowerCase())
        .compareTo(removeDiacritics(b.toLowerCase())));

    for (var tag in tags) {
      chips.add(_buildTagChip(
        tag: tag,
        context: context,
      ));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final coverFile = widget.book.getCoverFile();

    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, widget.addBottomPadding ? 90 : 5),
      child: Card.filled(
        color: widget.cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: InkWell(
            onTap: widget.onPressed,
            onLongPress: widget.onLongPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                  widget.book.title,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              widget.book.favourite
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: FaIcon(
                        FontAwesomeIcons.solidHeart,
                        size: 15,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(width: 10),
              FaIcon(
                widget.book.bookFormat == BookFormat.audiobook
                    ? FontAwesomeIcons.headphones
                    : widget.book.bookFormat == BookFormat.ebook
                        ? FontAwesomeIcons.tabletScreenButton
                        : FontAwesomeIcons.bookOpen,
                size: 15,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
          ),
          Text(
            widget.book.author,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          widget.book.publicationYear != null
              ? Text(
                  widget.book.publicationYear.toString(),
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 12,
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
              widget.book.status == BookStatus.read
                  ? _buildRating(context)
                  : const SizedBox(),
              _buildSortAttribute(),
            ],
          ),
          _buildTags(),
        ],
      ),
    );
  }

  SizedBox _buildCover(File? coverFile) {
    const coverWidth = 85.0;
    const coverHeight = coverWidth * 1.5;

    return SizedBox(
      width: (coverFile != null) ? coverWidth : 0,
      height: coverHeight,
      child: (coverFile != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Hero(
                tag: widget.heroTag,
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
            initialRating:
                (widget.book.rating == null) ? 0 : (widget.book.rating! / 10),
            allowHalfRating: true,
            unratedColor: Theme.of(context).colorScheme.surfaceContainerLow,
            glow: false,
            glowRadius: 1,
            itemSize: 18,
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
                (widget.book.rating == null)
                    ? '0'
                    : '${(widget.book.rating! / 10)}',
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
