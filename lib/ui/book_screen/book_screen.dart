import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      // tags: _tags,
      myReview: book!.myReview,
      cover: book!.cover,
      blurHash: book!.blurHash,
    ));

    return !isLiked;
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
                  if (snapshot.data == null) {
                    return const Center(child: Text('Error getting the book'));
                  }
                }
                return IconButton(
                  onPressed: () {
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
                  },
                  icon: const Icon(Icons.edit),
                );
              }),
          IconButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await bookCubit.deleteBook(id);
              navigator.pop();
            },
            icon: const Icon(Icons.delete),
          ),
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
                          author: snapshot.data!.author.toString(),
                          publicationYear:
                              (snapshot.data!.publicationYear ?? "").toString(),
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
                        // const SizedBox(height: 10),
                        //TODO: add tags
                        // const BookDetail(
                        //   title: 'Tags',
                        //   text: '',
                        // ),
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
