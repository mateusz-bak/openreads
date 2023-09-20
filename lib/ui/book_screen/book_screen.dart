import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({
    Key? key,
    required this.id,
    required this.heroTag,
  }) : super(key: key);

  final int id;
  final String heroTag;

  _onLikeTap(BuildContext context, Book book) {
    book = book.copyWith(favourite: book.favourite == true ? false : true);

    bookCubit.updateBook(book);
    context.read<CurrentBookCubit>().setBook(book);
  }

  _showDeleteRestoreDialog(
    BuildContext context,
    bool deleted,
    bool? deletePermanently,
    Book book,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            title: Text(
              deleted
                  ? deletePermanently == true
                      ? LocaleKeys.delete_perm_question.tr()
                      : LocaleKeys.delete_book_question.tr()
                  : LocaleKeys.restore_book_question.tr(),
              style: const TextStyle(fontSize: 18),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(LocaleKeys.no.tr()),
                ),
              ),
              FilledButton(
                onPressed: () {
                  if (deletePermanently == true) {
                    _deleteBookPermanently(book);
                  } else {
                    _changeDeleteStatus(deleted, book);
                  }

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(LocaleKeys.yes.tr()),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _changeDeleteStatus(bool deleted, Book book) async {
    await bookCubit.updateBook(book.copyWith(
      deleted: deleted,
    ));

    bookCubit.getDeletedBooks();
  }

  _deleteBookPermanently(Book book) async {
    if (book.id != null) {
      await bookCubit.deleteBook(book.id!);
    }

    bookCubit.getDeletedBooks();
  }

  IconData? _decideStatusIcon(int? status) {
    if (status == 0) {
      return Icons.done;
    } else if (status == 1) {
      return Icons.autorenew;
    } else if (status == 2) {
      return Icons.timelapse;
    } else if (status == 3) {
      return Icons.not_interested;
    } else {
      return null;
    }
  }

  String _decideStatusText(int? status, BuildContext context) {
    if (status == 0) {
      return LocaleKeys.book_status_finished.tr();
    } else if (status == 1) {
      return LocaleKeys.book_status_in_progress.tr();
    } else if (status == 2) {
      return LocaleKeys.book_status_for_later.tr();
    } else if (status == 3) {
      return LocaleKeys.book_status_unfinished.tr();
    } else {
      return '';
    }
  }

  String? _decideChangeStatusText(int? status, BuildContext context) {
    if (status == 1) {
      return LocaleKeys.finish_reading.tr();
    } else if (status == 2) {
      return LocaleKeys.start_reading.tr();
    } else if (status == 3) {
      return LocaleKeys.start_reading.tr();
    } else {
      return null;
    }
  }

  void _changeStatusAction(BuildContext context, int status, Book book) async {
    final dateNow = DateTime.now();
    final date = DateTime(dateNow.year, dateNow.month, dateNow.day);

    if (status == 1) {
      int? rating;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            title: Text(
              LocaleKeys.rate_book.tr(),
              style: const TextStyle(fontSize: 18),
            ),
            children: [
              QuickRating(
                onRatingUpdate: (double newRating) {
                  rating = (newRating * 10).toInt();
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      rating = null;
                      Navigator.of(context).pop();
                    },
                    child: Text(LocaleKeys.skip.tr()),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(LocaleKeys.save.tr()),
                  )
                ],
              )
            ],
          );
        },
      );
      book = book.copyWith(
        status: 0,
        rating: rating,
        finishDate: date,
      );

      bookCubit.updateBook(book);
    } else if (status == 2) {
      book = book.copyWith(
        status: 1,
        startDate: date,
      );

      bookCubit.updateBook(book);
    } else if (status == 3) {
      book = book.copyWith(
        status: 1,
        startDate: date,
      );

      bookCubit.updateBook(book);
    }

    if (!context.mounted) return;
    context.read<CurrentBookCubit>().setBook(book);
  }

  String? _generateDate(DateTime? date) {
    if (date == null) return null;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  String _generateReadingTime({
    required DateTime startDate,
    required DateTime finishDate,
    required BuildContext context,
  }) {
    final diff = finishDate.difference(startDate).inDays.toString();

    return '$diff ${LocaleKeys.days.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final moreButtonOptions = [
      LocaleKeys.edit_book.tr(),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<CurrentBookCubit, Book>(
            builder: (context, state) {
              if (moreButtonOptions.length == 1) {
                if (state.deleted == true) {
                  moreButtonOptions.add(LocaleKeys.restore_book.tr());
                  moreButtonOptions.add(LocaleKeys.delete_permanently.tr());
                } else {
                  moreButtonOptions.add(LocaleKeys.delete_book.tr());
                }
              }

              return PopupMenuButton<String>(
                onSelected: (_) {},
                itemBuilder: (_) {
                  return moreButtonOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                      onTap: () async {
                        context.read<EditBookCubit>().setBook(state);

                        await Future.delayed(const Duration(
                          milliseconds: 0,
                        ));
                        if (!context.mounted) return;

                        if (choice == moreButtonOptions[0]) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddBookScreen(
                                editingExistingBook: true,
                              ),
                            ),
                          );
                        } else if (choice == moreButtonOptions[1]) {
                          if (state.deleted == false) {
                            _showDeleteRestoreDialog(
                                context, true, null, state);
                          } else {
                            _showDeleteRestoreDialog(
                                context, false, null, state);
                          }
                        } else if (choice == moreButtonOptions[2]) {
                          _showDeleteRestoreDialog(context, true, true, state);
                        }
                      },
                    );
                  }).toList();
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CurrentBookCubit, Book>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                (state.hasCover == true)
                    ? Center(
                        child: CoverView(
                          onPressed: null,
                          heroTag: heroTag,
                          book: state,
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.all(5),
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
                        bookType: state.bookType,
                      ),
                      const SizedBox(height: 5),
                      BookStatusDetail(
                        statusIcon: _decideStatusIcon(state.status),
                        statusText: _decideStatusText(
                          state.status,
                          context,
                        ),
                        rating: state.rating,
                        startDate: _generateDate(state.startDate),
                        finishDate: _generateDate(state.finishDate),
                        onLikeTap: () => _onLikeTap(context, state),
                        isLiked: state.favourite,
                        showChangeStatus: (state.status == 1 ||
                            state.status == 2 ||
                            state.status == 3),
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
                        showRatingAndLike: state.status == 0,
                      ),
                      SizedBox(
                        height: (state.finishDate != null &&
                                state.startDate != null)
                            ? 5
                            : 0,
                      ),
                      (state.finishDate != null && state.startDate != null)
                          ? BookDetail(
                              title: LocaleKeys.reading_time.tr(),
                              text: _generateReadingTime(
                                finishDate: state.finishDate!,
                                startDate: state.startDate!,
                                context: context,
                              ),
                            )
                          : const SizedBox(),
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
                      const SizedBox(height: 50.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
