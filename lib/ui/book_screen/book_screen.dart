import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class BookScreen extends StatelessWidget {
  BookScreen({
    Key? key,
    required this.id,
    required this.heroTag,
    required this.book,
  }) : super(key: key);

  final int id;
  final String heroTag;
  Book? book;

  _onLikeTap() {
    if (book == null) return;

    bookCubit.updateBook(Book(
      id: book!.id,
      title: book!.title,
      subtitle: book!.subtitle,
      author: book!.author,
      description: book!.description,
      status: book!.status,
      favourite: book?.favourite == true ? false : true,
      rating: book!.rating,
      startDate: book!.startDate,
      finishDate: book!.finishDate,
      pages: book!.pages,
      publicationYear: book!.publicationYear,
      isbn: book!.isbn,
      olid: book!.olid,
      tags: book!.tags,
      myReview: book!.myReview,
      blurHash: book!.blurHash,
      bookType: book!.bookType,
    ));
  }

  _showDeleteRestoreDialog(
      BuildContext context, bool deleted, bool? deletePermanently) {
    if (book == null) return;

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
                    _deleteBookPermanently();
                  } else {
                    _changeDeleteStatus(deleted);
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

  Future<void> _changeDeleteStatus(bool deleted) async {
    await bookCubit.updateBook(Book(
      id: book!.id,
      title: book!.title,
      subtitle: book!.subtitle,
      author: book!.author,
      status: book!.status,
      favourite: book!.favourite,
      deleted: deleted,
      rating: book!.rating,
      startDate: book!.startDate,
      finishDate: book!.finishDate,
      pages: book!.pages,
      publicationYear: book!.publicationYear,
      isbn: book!.isbn,
      olid: book!.olid,
      tags: book!.tags,
      myReview: book!.myReview,
      blurHash: book!.blurHash,
      bookType: book!.bookType,
    ));

    bookCubit.getDeletedBooks();
  }

  _deleteBookPermanently() async {
    if (book?.id != null) {
      await bookCubit.deleteBook(book!.id!);
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

  void _changeStatusAction(BuildContext context, int status) async {
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
              BookRatingBar(
                animDuration: const Duration(milliseconds: 250),
                status: 0,
                defaultHeight: 60.0,
                rating: 0.0,
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

      bookCubit.updateBook(Book(
        id: book!.id,
        title: book!.title,
        author: book!.author,
        status: 0,
        favourite: book!.favourite,
        rating: rating,
        startDate: book!.startDate,
        finishDate: date.toIso8601String(),
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        blurHash: book!.blurHash,
        bookType: book!.bookType,
      ));
    } else if (status == 2) {
      bookCubit.updateBook(Book(
        id: book!.id,
        title: book!.title,
        author: book!.author,
        status: 1,
        favourite: book!.favourite,
        rating: book!.rating,
        startDate: date.toIso8601String(),
        finishDate: book!.finishDate,
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        blurHash: book!.blurHash,
        bookType: book!.bookType,
      ));
    } else if (status == 3) {
      bookCubit.updateBook(Book(
        id: book!.id,
        title: book!.title,
        author: book!.author,
        status: 1,
        favourite: book!.favourite,
        rating: book!.rating,
        startDate: date.toIso8601String(),
        finishDate: book!.finishDate,
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        blurHash: book!.blurHash,
        bookType: book!.bookType,
      ));
    }
  }

  String? _generateDate(String? date) {
    if (date == null) return null;

    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(DateTime.parse(date));
  }

  String _generateReadingTime({
    required String startDate,
    required String finishDate,
    required BuildContext context,
  }) {
    final diff = DateTime.parse(finishDate)
        .difference(DateTime.parse(startDate))
        .inDays
        .toString();

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
          StreamBuilder<Book?>(
              stream: bookCubit.book,
              builder: (context, AsyncSnapshot<Book?> snapshot) {
                if (snapshot.hasData) {
                  if (moreButtonOptions.length == 1) {
                    if (snapshot.data?.deleted == true) {
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
                            await Future.delayed(const Duration(
                              milliseconds: 0,
                            ));

                            if (choice == moreButtonOptions[0]) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddBookScreen(
                                    book: snapshot.data,
                                    editingExistingBook: true,
                                  ),
                                ),
                              );
                            } else if (choice == moreButtonOptions[1]) {
                              if (snapshot.data!.deleted == false) {
                                _showDeleteRestoreDialog(context, true, null);
                              } else {
                                _showDeleteRestoreDialog(context, false, null);
                              }
                            } else if (choice == moreButtonOptions[2]) {
                              _showDeleteRestoreDialog(context, true, true);
                            }
                          },
                        );
                      }).toList();
                    },
                  );
                } else {
                  return const SizedBox();
                }
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (book != null)
                ? Center(
                    child: CoverView(
                      onPressed: null,
                      heroTag: heroTag,
                      book: book!,
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookTitleDetail(
                    title: book!.title.toString(),
                    subtitle: book!.subtitle,
                    author: book!.author.toString(),
                    publicationYear: (book!.publicationYear ?? "").toString(),
                    tags: book!.tags?.split('|||||'),
                    bookType: book!.bookType,
                  ),
                  const SizedBox(height: 5),
                  BookStatusDetail(
                    statusIcon: _decideStatusIcon(book!.status),
                    statusText: _decideStatusText(
                      book!.status,
                      context,
                    ),
                    rating: book!.rating,
                    startDate: _generateDate(book!.startDate),
                    finishDate: _generateDate(book!.finishDate),
                    onLikeTap: _onLikeTap,
                    isLiked: book!.favourite,
                    showChangeStatus: (book!.status == 1 ||
                        book!.status == 2 ||
                        book!.status == 3),
                    changeStatusText: _decideChangeStatusText(
                      book!.status,
                      context,
                    ),
                    changeStatusAction: () {
                      _changeStatusAction(
                        context,
                        book!.status,
                      );
                    },
                    showRatingAndLike: book!.status == 0,
                  ),
                  SizedBox(
                    height:
                        (book!.finishDate != null && book!.startDate != null)
                            ? 5
                            : 0,
                  ),
                  (book!.finishDate != null && book!.startDate != null)
                      ? BookDetail(
                          title: LocaleKeys.reading_time.tr(),
                          text: _generateReadingTime(
                            finishDate: book!.finishDate!,
                            startDate: book!.startDate!,
                            context: context,
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: (book!.pages != null) ? 5 : 0,
                  ),
                  (book!.pages != null)
                      ? BookDetail(
                          title: LocaleKeys.pages_uppercase.tr(),
                          text: (book!.pages ?? "").toString(),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: (book!.description != null &&
                            book!.description!.isNotEmpty)
                        ? 5
                        : 0,
                  ),
                  (book!.description != null && book!.description!.isNotEmpty)
                      ? BookDetail(
                          title: LocaleKeys.description.tr(),
                          text: book!.description!,
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: (book!.isbn != null) ? 5 : 0,
                  ),
                  (book!.isbn != null)
                      ? BookDetail(
                          title: LocaleKeys.isbn.tr(),
                          text: (book!.isbn ?? "").toString(),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: (book!.olid != null) ? 5 : 0,
                  ),
                  (book!.olid != null)
                      ? BookDetail(
                          title: LocaleKeys.open_library_ID.tr(),
                          text: (book!.olid ?? "").toString(),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height:
                        (book!.myReview != null && book!.myReview!.isNotEmpty)
                            ? 5
                            : 0,
                  ),
                  (book!.myReview != null && book!.myReview!.isNotEmpty)
                      ? BookDetail(
                          title: LocaleKeys.my_review.tr(),
                          text: book!.myReview!,
                        )
                      : const SizedBox(),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
