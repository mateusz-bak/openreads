import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({
    super.key,
    required this.id,
    required this.heroTag,
  });

  final int id;
  final String heroTag;

  _onLikeTap(BuildContext context, Book book) {
    book = book.copyWith(favourite: book.favourite == true ? false : true);

    bookCubit.updateBook(book);
    context.read<CurrentBookCubit>().setBook(book);
  }

  IconData? _decideStatusIcon(BookStatus? status) {
    if (status == BookStatus.read) {
      return Icons.done;
    } else if (status == BookStatus.inProgress) {
      return Icons.autorenew;
    } else if (status == BookStatus.forLater) {
      return Icons.timelapse;
    } else if (status == BookStatus.unfinished) {
      return Icons.not_interested;
    } else {
      return null;
    }
  }

  String _decideStatusText(BookStatus? status, BuildContext context) {
    if (status == BookStatus.read) {
      return LocaleKeys.book_status_finished.tr();
    } else if (status == BookStatus.inProgress) {
      return LocaleKeys.book_status_in_progress.tr();
    } else if (status == BookStatus.forLater) {
      return LocaleKeys.book_status_for_later.tr();
    } else if (status == BookStatus.unfinished) {
      return LocaleKeys.book_status_unfinished.tr();
    } else {
      return '';
    }
  }

  String? _decideChangeStatusText(BookStatus? status, BuildContext context) {
    if (status == BookStatus.inProgress) {
      return LocaleKeys.finish_reading.tr();
    } else if (status == BookStatus.forLater) {
      return LocaleKeys.start_reading.tr();
    } else if (status == BookStatus.unfinished) {
      return LocaleKeys.start_reading.tr();
    } else {
      return null;
    }
  }

  Future<int?> _getQuickRating(BuildContext context) async {
    return await showDialog<int?>(
      context: context,
      builder: (BuildContext context) {
        return const QuickRatingDialog();
      },
    );
  }

  void _changeStatusAction(
    BuildContext context,
    BookStatus status,
    Book book,
  ) async {
    final dateNow = DateTime.now();
    final date = DateTime(dateNow.year, dateNow.month, dateNow.day);

    // finishing the book
    if (status == BookStatus.inProgress) {
      final rating = await _getQuickRating(context);

      book = book.copyWith(
        status: BookStatus.read,
        rating: rating,
        readings: book.readings.isNotEmpty
            ? (book.readings..[0] = book.readings[0].copyWith(finishDate: date))
            : [Reading(finishDate: date)],
      );

      bookCubit.updateBook(book);

      // starting the book
    } else if (status == BookStatus.forLater) {
      book = book.copyWith(
        status: BookStatus.inProgress,
        readings: book.readings.isNotEmpty
            ? (book.readings..[0] = book.readings[0].copyWith(startDate: date))
            : [Reading(startDate: date)],
      );

      bookCubit.updateBook(book);

      // starting the book
    } else if (status == BookStatus.unfinished) {
      book = book.copyWith(
        status: BookStatus.inProgress,
        readings: book.readings.isNotEmpty
            ? (book.readings..[0] = book.readings[0].copyWith(startDate: date))
            : [Reading(startDate: date)],
      );

      bookCubit.updateBook(book);
    }

    if (!context.mounted) return;
    context.read<CurrentBookCubit>().setBook(book);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SelectableRegion(
      selectionControls: materialTextSelectionControls,
      focusNode: FocusNode(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: const BookScreenAppBar(),
        body: BlocBuilder<CurrentBookCubit, Book>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  (state.hasCover == true)
                      ? Center(
                          child: CoverView(
                            heroTag: heroTag,
                            book: state,
                          ),
                        )
                      : SizedBox(
                          height: mediaQuery.padding.top +
                              AppBar().preferredSize.height,
                        ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookTitleDetail(
                          title: state.title.toString(),
                          subtitle: state.subtitle,
                          author: state.author.toString(),
                          publicationYear:
                              (state.publicationYear ?? "").toString(),
                          tags: state.tags?.split('|||||'),
                          bookType: state.bookFormat,
                        ),
                        const SizedBox(height: 5),
                        BookStatusDetail(
                          book: state,
                          statusIcon: _decideStatusIcon(state.status),
                          statusText: _decideStatusText(
                            state.status,
                            context,
                          ),
                          onLikeTap: () => _onLikeTap(context, state),
                          showChangeStatus:
                              (state.status == BookStatus.inProgress ||
                                  state.status == BookStatus.forLater ||
                                  state.status == BookStatus.unfinished),
                          changeStatusText: _decideChangeStatusText(
                            state.status,
                            context,
                          ),
                          changeStatusAction: () {
                            _changeStatusAction(
                              context,
                              state.status,
                              state,
                            );
                          },
                          showRatingAndLike: state.status == BookStatus.read,
                        ),
                        SizedBox(
                          height: (state.pages != null) ? 5 : 0,
                        ),
                        (state.pages != null)
                            ? BookDetail(
                                title: LocaleKeys.pages_uppercase.tr(),
                                text: (state.pages ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (state.description != null &&
                                  state.description!.isNotEmpty)
                              ? 5
                              : 0,
                        ),
                        (state.description != null &&
                                state.description!.isNotEmpty)
                            ? BookDetail(
                                title: LocaleKeys.description.tr(),
                                text: state.description!,
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (state.isbn != null) ? 5 : 0,
                        ),
                        (state.isbn != null)
                            ? BookDetail(
                                title: LocaleKeys.isbn.tr(),
                                text: (state.isbn ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (state.olid != null) ? 5 : 0,
                        ),
                        (state.olid != null)
                            ? BookDetail(
                                title: LocaleKeys.open_library_ID.tr(),
                                text: (state.olid ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (state.myReview != null &&
                                  state.myReview!.isNotEmpty)
                              ? 5
                              : 0,
                        ),
                        (state.myReview != null && state.myReview!.isNotEmpty)
                            ? BookDetail(
                                title: LocaleKeys.my_review.tr(),
                                text: state.myReview!,
                              )
                            : const SizedBox(),
                        SizedBox(
                          height:
                              (state.notes != null && state.notes!.isNotEmpty)
                                  ? 5
                                  : 0,
                        ),
                        (state.notes != null && state.notes!.isNotEmpty)
                            ? BookDetail(
                                title: LocaleKeys.notes.tr(),
                                text: state.notes!,
                              )
                            : const SizedBox(),
                        const SizedBox(height: 5),
                        BookDetailDateAddedUpdated(
                          dateAdded: state.dateAdded,
                          dateModified: state.dateModified,
                        ),
                        const SizedBox(height: 50.0),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
