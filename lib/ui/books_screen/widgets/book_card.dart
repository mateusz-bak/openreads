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
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
    required this.isLastItem,
    this.onLongPressed,
    this.isSelectable = false,
  });

  final Book book;
  final String heroTag;
  final bool isLastItem;
  final Function() onPressed;
  final Function()? onLongPressed;
  final bool isSelectable;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late File? coverFile;

  @override
  Widget build(BuildContext context) {
    coverFile = widget.book.getCoverFile();
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SelectedBooksCubit, List<int>>(
      builder: (context, selectedBooks) {
        final isSelected =
            widget.isSelectable && selectedBooks.contains(widget.book.id);

        return Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, widget.isLastItem ? 90 : 10),
          child: isDarkMode
              ? _buildDarkCard(isSelected)
              : _buildLightCard(isSelected),
        );
      },
    );
  }

  Widget _buildLightCard(bool isSelected) {
    return Card(
      shadowColor: Colors.black.withAlpha(40),
      elevation: 5,
      shape: cardShape,
      color: isSelected
          ? Theme.of(context).colorScheme.tertiaryContainer
          : lightCardColor,
      child: _buildCardContent(),
    );
  }

  Widget _buildDarkCard(bool isSelected) {
    return Card.filled(
      shape: cardShape,
      color: isSelected
          ? Theme.of(context).colorScheme.tertiaryContainer
          : darkCardColor,
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    return InkWell(
      onTap: widget.onPressed,
      onLongPress: widget.onLongPressed,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(),
            SizedBox(width: (coverFile != null) ? 15 : 0),
            _buildBookDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildSortAttribute() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          if (state.sortType == SortType.byPages) {
            return (widget.book.pages != null)
                ? _buildPagesAttribute()
                : const SizedBox();
          } else if (state.sortType == SortType.byStartDate) {
            final latestStartDate = getLatestStartDate(widget.book);

            return (latestStartDate != null)
                ? _buildDateAttribute(
                    latestStartDate,
                    LocaleKeys.started_on_date.tr(),
                    false,
                  )
                : const SizedBox();
          } else if (state.sortType == SortType.byFinishDate) {
            final latestFinishDate = getLatestFinishDate(widget.book);

            return (latestFinishDate != null)
                ? _buildDateAttribute(
                    latestFinishDate,
                    LocaleKeys.finished_on_date.tr(),
                    false,
                  )
                : const SizedBox();
          } else if (state.sortType == SortType.byDateAdded) {
            return _buildDateAttribute(
              widget.book.dateAdded,
              LocaleKeys.added_on.tr(),
              true,
            );
          } else if (state.sortType == SortType.byDateModified) {
            return _buildDateAttribute(
              widget.book.dateModified,
              LocaleKeys.modified_on.tr(),
              true,
            );
          } else if (state.sortType == SortType.byPublicationYear) {
            return (widget.book.publicationYear != null)
                ? _buildPublicationYearAttribute()
                : const SizedBox();
          }
        }

        return const SizedBox();
      },
    );
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
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          if (state.displayTags) {
            return (widget.book.tags == null)
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          children: _generateTagChips(
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  );
          }
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTagChip({
    required String tag,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        padding: const EdgeInsets.all(5),
        side: BorderSide(color: dividerColor, width: 1),
        label: Text(
          tag,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 12,
          ),
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

  Widget _buildRating(BuildContext context) {
    return BlocBuilder<RatingTypeBloc, RatingTypeState>(
      builder: (context, state) {
        if (state is RatingTypeBar) {
          return RatingBar.builder(
            initialRating:
                (widget.book.rating == null) ? 0 : (widget.book.rating! / 10),
            allowHalfRating: true,
            unratedColor: Theme.of(context).scaffoldBackgroundColor,
            glow: false,
            glowRadius: 1,
            itemSize: 18,
            ignoreGestures: true,
            itemPadding: const EdgeInsets.only(right: 3),
            itemBuilder: (context, _) => FaIcon(
              FontAwesomeIcons.solidStar,
              color: Theme.of(context).colorScheme.primary,
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
                color: ratingColor,
                size: 14,
              ),
            ],
          );
        }
      },
    );
  }

  SizedBox _buildCover() {
    const double coverWidth = 80;
    const double coverHeight = coverWidth * 1.4;

    return SizedBox(
      width: (coverFile != null) ? coverWidth : 0,
      height: coverHeight,
      child: (coverFile != null)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Hero(
                tag: widget.heroTag,
                child: Image.file(
                  coverFile!,
                  width: coverWidth,
                  height: coverHeight,
                  fit: BoxFit.cover,
                  frameBuilder: (
                    BuildContext context,
                    Widget child,
                    int? frame,
                    bool wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded) return child;

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
          : null,
    );
  }

  _buildBookDetails() {
    return Expanded(
      child: SizedBox(
        height: 70 * 1.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.book.title,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
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
                          color: likeColor,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(width: 15),
                FaIcon(
                  widget.book.bookFormat == BookFormat.audiobook
                      ? FontAwesomeIcons.headphones
                      : widget.book.bookFormat == BookFormat.ebook
                          ? FontAwesomeIcons.tabletScreenButton
                          : FontAwesomeIcons.bookOpen,
                  size: 15,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
            Text(
              widget.book.author,
              softWrap: true,
              overflow: TextOverflow.clip,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            // widget.book.publicationYear != null
            //     ? Text(
            //         widget.book.publicationYear.toString(),
            //         softWrap: true,
            //         overflow: TextOverflow.clip,
            //         style: TextStyle(
            //           fontSize: 12,
            //           color: Theme.of(context)
            //               .colorScheme
            //               .onSurface
            //               .withOpacity(0.6),
            //           letterSpacing: 0.05,
            //         ),
            //       )
            //     : const SizedBox(),
            // const SizedBox(height: 5),
            const Spacer(),
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
            // _buildTags(),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
