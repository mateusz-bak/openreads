import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class BookScreen extends StatelessWidget {
  BookScreen({
    Key? key,
    required this.id,
    required this.heroTag,
  }) : super(key: key);

  final int id;
  final String heroTag;
  Book? book;

  final moreButtonOptions = [
    'Edit',
  ];

  Future<bool?> _onLikeTap(isLiked) async {
    if (book == null) return isLiked;

    bookCubit.updateBook(Book(
      id: book!.id,
      title: book!.title,
      author: book!.author,
      status: book!.status,
      favourite: !isLiked,
      rating: book!.rating,
      startDate: book!.startDate,
      finishDate: book!.finishDate,
      pages: book!.pages,
      publicationYear: book!.publicationYear,
      isbn: book!.isbn,
      olid: book!.olid,
      tags: book!.tags,
      myReview: book!.myReview,
      cover: book!.cover,
      blurHash: book!.blurHash,
    ));

    return !isLiked;
  }

  _showDeleteDialog(BuildContext context, bool deleted) {
    if (book == null) return;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  Theme.of(context).extension<CustomBorder>()?.radius ??
                      BorderRadius.circular(5.0),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              deleted ? 'Delete this book?' : 'Restore this book?',
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        Theme.of(context).extension<CustomBorder>()?.radius ??
                            BorderRadius.circular(5.0),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "No",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _changeDeleteStatus(deleted);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        Theme.of(context).extension<CustomBorder>()?.radius ??
                            BorderRadius.circular(5.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Yes",
                    style: TextStyle(fontSize: 12),
                  ),
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
      cover: book!.cover,
      blurHash: book!.blurHash,
    ));

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

  String _decideStatusText(int? status) {
    if (status == 0) {
      return 'Done';
    } else if (status == 1) {
      return 'Reading';
    } else if (status == 2) {
      return 'For later';
    } else if (status == 3) {
      return 'Unfinished';
    } else {
      return '';
    }
  }

  String? _decideChangeStatusText(int? status) {
    if (status == 1) {
      return 'Finish';
    } else if (status == 2) {
      return 'Start';
    } else if (status == 3) {
      return 'Start';
    } else {
      return null;
    }
  }

  void _changeStatusAction(BuildContext context, int status) async {
    if (status == 1) {
      int? rating;

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius:
                  Theme.of(context).extension<CustomBorder>()?.radius ??
                      BorderRadius.circular(5.0),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: const Text(
              'Rate this book',
              style: TextStyle(fontSize: 18),
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
                  TextButton(
                    onPressed: () {
                      rating = null;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).mainTextColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
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
        finishDate: DateTime.now().toIso8601String(),
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        cover: book!.cover,
        blurHash: book!.blurHash,
      ));
    } else if (status == 2) {
      bookCubit.updateBook(Book(
        id: book!.id,
        title: book!.title,
        author: book!.author,
        status: 1,
        favourite: book!.favourite,
        rating: book!.rating,
        startDate: DateTime.now().toIso8601String(),
        finishDate: book!.finishDate,
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        cover: book!.cover,
        blurHash: book!.blurHash,
      ));
    } else if (status == 3) {
      bookCubit.updateBook(Book(
        id: book!.id,
        title: book!.title,
        author: book!.author,
        status: 1,
        favourite: book!.favourite,
        rating: book!.rating,
        startDate: book!.startDate,
        finishDate: book!.finishDate,
        pages: book!.pages,
        publicationYear: book!.publicationYear,
        isbn: book!.isbn,
        olid: book!.olid,
        tags: book!.tags,
        myReview: book!.myReview,
        cover: book!.cover,
        blurHash: book!.blurHash,
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
  }) {
    final diff = DateTime.parse(finishDate)
        .difference(DateTime.parse(startDate))
        .inDays
        .toString();

    return '$diff days';
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    bookCubit.getBook(id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          StreamBuilder<Book>(
              stream: bookCubit.book,
              builder: (context, AsyncSnapshot<Book> snapshot) {
                if (snapshot.hasData) {
                  moreButtonOptions.add(
                    snapshot.data?.deleted == true ? 'Restore' : 'Delete',
                  );

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
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return AddBook(
                                      topPadding: statusBarHeight,
                                      book: snapshot.data,
                                      previousThemeData: Theme.of(context),
                                      editingExistingBook: true,
                                    );
                                  });
                            } else if (choice == moreButtonOptions[1]) {
                              if (snapshot.data!.deleted == false) {
                                _showDeleteDialog(context, true);
                              } else {
                                _showDeleteDialog(context, false);
                              }
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
        child: StreamBuilder<Book>(
          stream: bookCubit.book,
          builder: (context, AsyncSnapshot<Book> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data == null) {
                return const Center(child: Text('Error getting the book'));
              }
              book = snapshot.data!;

              return Column(
                children: [
                  (snapshot.data!.cover == null)
                      ? const SizedBox()
                      : Center(
                          child: CoverView(
                            onPressed: null,
                            heroTag: heroTag,
                            photoBytes: snapshot.data!.cover,
                            blurHash: snapshot.data!.blurHash,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookTitleDetail(
                          title: snapshot.data!.title.toString(),
                          subtitle: snapshot.data!.subtitle,
                          author: snapshot.data!.author.toString(),
                          publicationYear:
                              (snapshot.data!.publicationYear ?? "").toString(),
                          tags: snapshot.data!.tags?.split('|||||'),
                        ),
                        const SizedBox(height: 10),
                        BookStatusDetail(
                          statusIcon: _decideStatusIcon(snapshot.data!.status),
                          statusText: _decideStatusText(snapshot.data!.status),
                          rating: snapshot.data!.rating,
                          startDate: _generateDate(snapshot.data!.startDate),
                          finishDate: _generateDate(snapshot.data!.finishDate),
                          onLikeTap: _onLikeTap,
                          isLiked: snapshot.data!.favourite,
                          showChangeStatus: (snapshot.data!.status == 1 ||
                              snapshot.data!.status == 2 ||
                              snapshot.data!.status == 3),
                          changeStatusText:
                              _decideChangeStatusText(snapshot.data!.status),
                          changeStatusAction: () {
                            _changeStatusAction(
                              context,
                              snapshot.data!.status,
                            );
                          },
                          showRatingAndLike: snapshot.data!.status == 0,
                        ),
                        SizedBox(
                          height: (snapshot.data!.finishDate != null &&
                                  snapshot.data!.startDate != null)
                              ? 10
                              : 0,
                        ),
                        (snapshot.data!.finishDate != null &&
                                snapshot.data!.startDate != null)
                            ? BookDetail(
                                title: 'Reading time',
                                text: _generateReadingTime(
                                  finishDate: snapshot.data!.finishDate!,
                                  startDate: snapshot.data!.startDate!,
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (snapshot.data!.pages != null) ? 10 : 0,
                        ),
                        (snapshot.data!.pages != null)
                            ? BookDetail(
                                title: 'Pages',
                                text: (snapshot.data!.pages ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (snapshot.data!.isbn != null) ? 10 : 0,
                        ),
                        (snapshot.data!.isbn != null)
                            ? BookDetail(
                                title: 'ISBN',
                                text: (snapshot.data!.isbn ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (snapshot.data!.olid != null) ? 10 : 0,
                        ),
                        (snapshot.data!.olid != null)
                            ? BookDetail(
                                title: 'Open Library ID',
                                text: (snapshot.data!.olid ?? "").toString(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: (snapshot.data!.myReview != null) ? 10 : 0,
                        ),
                        (snapshot.data!.myReview != null)
                            ? BookDetail(
                                title: 'My review',
                                text:
                                    (snapshot.data!.myReview ?? "").toString(),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 50.0),
                      ],
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
