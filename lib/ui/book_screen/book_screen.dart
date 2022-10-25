import 'package:flutter/material.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({
    Key? key,
    required this.id,
    required this.heroTag,
  }) : super(key: key);

  final int id;
  final String heroTag;

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

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    bookCubit.getBook(id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        // surfaceTintColor: Colors.grey.shade400,
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
                            previousContext: context,
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
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Center(
                            child: CoverView(
                              onPressed: null,
                              heroTag: heroTag,
                              photoBytes: snapshot.data!.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    BookTitleDetail(
                      title: snapshot.data!.title.toString(),
                      author: snapshot.data!.author.toString(),
                      publicationYear:
                          snapshot.data!.publicationYear.toString(),
                    ),
                    const SizedBox(height: 10),
                    BookStatusDetail(
                      statusIcon: _decideStatusIcon(snapshot.data!.status),
                      statusText: _decideStatusText(snapshot.data!.status),
                      rating: snapshot.data!.rating,
                    ),
                    const SizedBox(height: 10),
                    //TODO: calculate reading time
                    const BookDetail(
                      title: 'Reading time',
                      text: '12 days 3 hours',
                    ),
                    const SizedBox(height: 10),
                    BookDetail(
                      title: 'Pages',
                      text: snapshot.data!.pages.toString(),
                    ),
                    const SizedBox(height: 10),
                    BookDetail(
                      title: 'ISBN',
                      text: snapshot.data!.isbn.toString(),
                    ),
                    const SizedBox(height: 10),
                    BookDetail(
                      title: 'Open Library ID',
                      text: snapshot.data!.olid.toString(),
                    ),
                    const SizedBox(height: 10),
                    //TODO: add tags
                    const BookDetail(
                      title: 'Tags',
                      text: '',
                    ),
                    const SizedBox(height: 10),
                    BookDetail(
                      title: 'My review',
                      text: snapshot.data!.myReview.toString(),
                    ),
                  ],
                ),
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
