import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    Key? key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
    required this.addBottomPadding,
  }) : super(key: key);

  final Book book;
  final String heroTag;
  final bool addBottomPadding;
  final Function() onPressed;

  Widget _buildSortAttribute() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          if (state.sortType == SortType.byPages) {
            return (book.pages != null)
                ? Text(
                    '${book.pages} pages',
                    style: TextStyle(
                      fontFamily: context.read<ThemeBloc>().fontFamily,
                    ),
                  )
                : const SizedBox();
          } else if (state.sortType == SortType.byStartDate) {
            return (book.startDate != null)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Started on',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: context.read<ThemeBloc>().fontFamily,
                        ),
                      ),
                      Text(
                        '${_generateDate(book.startDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: context.read<ThemeBloc>().fontFamily,
                        ),
                      ),
                    ],
                  )
                : const SizedBox();
          } else if (state.sortType == SortType.byFinishDate) {
            return (book.finishDate != null)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Finished on',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: context.read<ThemeBloc>().fontFamily,
                        ),
                      ),
                      Text(
                        '${_generateDate(book.finishDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: context.read<ThemeBloc>().fontFamily,
                        ),
                      ),
                    ],
                  )
                : const SizedBox();
          }
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTags() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          if (state.displayTags) {
            return (book.tags == null)
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
    required bool selected,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilterChip(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(5),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).mainTextColor,
            fontSize: 12,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
        ),
        checkmarkColor: Colors.white,
        selected: selected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (_) {},
      ),
    );
  }

  List<Widget> _generateTagChips({required BuildContext context}) {
    final chips = List<Widget>.empty(growable: true);

    if (book.tags == null) {
      return [];
    }

    for (var tag in book.tags!.split('|||||')) {
      chips.add(_buildTagChip(
        tag: tag,
        selected: false,
        context: context,
      ));
    }

    return chips;
  }

  String? _generateDate(String? date) {
    if (date == null) return null;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, addBottomPadding ? 90 : 15),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: (book.cover != null) ? 60 : 0,
                child: (book.cover != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Hero(
                          tag: heroTag,
                          child: Image.memory(
                            book.cover!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              SizedBox(width: (book.cover != null) ? 20 : 0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      book.title,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).mainTextColor,
                        fontFamily: context.read<ThemeBloc>().fontFamily,
                      ),
                    ),
                    Text(
                      book.author,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Theme.of(context).secondaryTextColor,
                        fontFamily: context.read<ThemeBloc>().fontFamily,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            book.favourite
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: FaIcon(
                                      FontAwesomeIcons.solidHeart,
                                      size: 18,
                                      color: Theme.of(context).likeColor,
                                    ),
                                  )
                                : const SizedBox(),
                            book.status == 0
                                ? _buildRating(context)
                                : const SizedBox(),
                          ],
                        ),
                        _buildSortAttribute(),
                      ],
                    ),
                    _buildTags(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    return BlocBuilder<RatingTypeBloc, RatingTypeState>(
      builder: (context, state) {
        if (state is RatingTypeBar) {
          return RatingBar.builder(
            initialRating: (book.rating == null) ? 0 : (book.rating! / 10),
            allowHalfRating: true,
            unratedColor: Theme.of(context).scaffoldBackgroundColor,
            glow: false,
            glowRadius: 1,
            itemSize: 24,
            ignoreGestures: true,
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: Theme.of(context).ratingColor,
            ),
            onRatingUpdate: (_) {},
          );
        } else {
          return Row(
            children: [
              Text(
                (book.rating == null) ? '0' : '${(book.rating! / 10)}',
                style: TextStyle(
                  fontFamily: context.read<ThemeBloc>().fontFamily,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.star_rounded,
                color: Theme.of(context).ratingColor,
                size: 20,
              ),
            ],
          );
        }
      },
    );
  }
}
