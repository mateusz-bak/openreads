import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/sort_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_screen/search_ol_screen.dart.dart';
import 'package:openreads/ui/statistics_screen/statistics_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({
    Key? key,
    required this.appVersion,
  }) : super(key: key);

  final String appVersion;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with AutomaticKeepAliveClientMixin {
  List<Book> _sortList({
    required SortState sortState,
    required List<Book> list,
  }) {
    switch (sortState.sortType) {
      case SortType.byAuthor:
        list = _sortByAuthor(list: list, isAsc: sortState.isAsc);
        break;
      case SortType.byRating:
        list = _sortByRating(list: list, isAsc: sortState.isAsc);
        break;
      case SortType.byPages:
        list = _sortByPages(list: list, isAsc: sortState.isAsc);
        break;
      case SortType.byStartDate:
        list = _sortByStartDate(list: list, isAsc: sortState.isAsc);
        break;
      case SortType.byFinishDate:
        list = _sortByFinishDate(list: list, isAsc: sortState.isAsc);
        break;
      default:
        list = _sortByTitle(list: list, isAsc: sortState.isAsc);
        break;
    }

    return list;
  }

  List<Book> _sortByTitle({
    required List<Book> list,
    required bool isAsc,
  }) {
    !isAsc
        ? list.sort((a, b) {
            return a.title
                .toString()
                .toLowerCase()
                .compareTo(b.title.toString().toLowerCase());
          })
        : list.sort((b, a) {
            return a.author
                .toString()
                .toLowerCase()
                .compareTo(b.title.toString().toLowerCase());
          });

    return list;
  }

  List<Book> _sortByAuthor({
    required List<Book> list,
    required bool isAsc,
  }) {
    !isAsc
        ? list.sort((a, b) {
            return a.author
                .toString()
                .toLowerCase()
                .compareTo(b.author.toString().toLowerCase());
          })
        : list.sort((b, a) {
            return a.author
                .toString()
                .toLowerCase()
                .compareTo(b.author.toString().toLowerCase());
          });

    return list;
  }

  List<Book> _sortByRating({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksNotRated = List.empty(growable: true);
    List<Book> booksRated = List.empty(growable: true);

    for (Book book in list) {
      (book.rating != null) ? booksRated.add(book) : booksNotRated.add(book);
    }

    !isAsc
        ? booksRated.sort((a, b) {
            return a.rating!.compareTo(b.rating!);
          })
        : booksRated.sort((b, a) {
            return a.rating!.compareTo(b.rating!);
          });

    return booksRated + booksNotRated;
  }

  List<Book> _sortByPages({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksWithoutPages = List.empty(growable: true);
    List<Book> booksWithPages = List.empty(growable: true);

    for (Book book in list) {
      (book.pages != null)
          ? booksWithPages.add(book)
          : booksWithoutPages.add(book);
    }

    !isAsc
        ? booksWithPages.sort((a, b) {
            return a.pages!.compareTo(b.pages!);
          })
        : booksWithPages.sort((b, a) {
            return a.pages!.compareTo(b.pages!);
          });

    return booksWithPages + booksWithoutPages;
  }

  List<Book> _sortByStartDate({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksWithoutStartDate = List.empty(growable: true);
    List<Book> booksWithStartDate = List.empty(growable: true);

    for (Book book in list) {
      (book.startDate != null)
          ? booksWithStartDate.add(book)
          : booksWithoutStartDate.add(book);
    }

    !isAsc
        ? booksWithStartDate.sort((a, b) {
            return (DateTime.parse(a.startDate!).millisecondsSinceEpoch)
                .compareTo(DateTime.parse(b.startDate!).millisecondsSinceEpoch);
          })
        : booksWithStartDate.sort((b, a) {
            return (DateTime.parse(a.startDate!).millisecondsSinceEpoch)
                .compareTo(DateTime.parse(b.startDate!).millisecondsSinceEpoch);
          });

    return booksWithStartDate + booksWithoutStartDate;
  }

  List<Book> _sortByFinishDate({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksWithoutFinishDate = List.empty(growable: true);
    List<Book> booksWithFinishDate = List.empty(growable: true);

    for (Book book in list) {
      (book.finishDate != null)
          ? booksWithFinishDate.add(book)
          : booksWithoutFinishDate.add(book);
    }

    !isAsc
        ? booksWithFinishDate.sort((a, b) {
            return (DateTime.parse(a.finishDate!).millisecondsSinceEpoch)
                .compareTo(
                    DateTime.parse(b.finishDate!).millisecondsSinceEpoch);
          })
        : booksWithFinishDate.sort((b, a) {
            return (DateTime.parse(a.finishDate!).millisecondsSinceEpoch)
                .compareTo(
                    DateTime.parse(b.finishDate!).millisecondsSinceEpoch);
          });

    return booksWithFinishDate + booksWithoutFinishDate;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Openreads',
            ),
            const SizedBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                widget.appVersion,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return const SortBottomSheet();
                },
              );
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return AddBookSheet(
                  addManually: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;

                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return AddBook(
                            topPadding: statusBarHeight,
                            previousThemeData: Theme.of(context),
                          );
                        });
                  },
                  searchInOpenLibrary: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchOLScreen(),
                      ),
                    );
                  },
                  scanBarcode: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;
                  },
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.finishedBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BlocBuilder<SortCubit, SortState>(
                            builder: (context, sortState) {
                              return BooksList(
                                books: _sortList(
                                  sortState: sortState,
                                  list: snapshot.data!,
                                ),
                              );
                            },
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
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.inProgressBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BooksList(
                            books: snapshot.data!,
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
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.toReadBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BooksList(
                            books: snapshot.data!,
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
                  ],
                ),
              ),
              Container(
                color: Theme.of(context).backgroundColor,
                child: TabBar(
                  // labelColor: Theme.of(context).mainTextColor,
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  // unselectedLabelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).mainTextColor,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Theme.of(context).outlineColor,
                    ),
                    // color: Colors.greenAccent,
                  ),
                  tabs: const [
                    Tab(
                      child: Text('Finished'),
                    ),
                    Tab(
                      child: Text('In progress'),
                    ),
                    Tab(
                      child: Text('For later'),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
