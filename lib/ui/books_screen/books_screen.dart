import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_screen/search_ol_screen.dart.dart';
import 'package:openreads/ui/settings_screen/settings_screen.dart';
import 'package:openreads/ui/statistics_screen/statistics_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with AutomaticKeepAliveClientMixin {
  List<Book> _sortList({
    required SortState state,
    required List<Book> list,
  }) {
    if (state is TitleSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByTitle(list: list, isAsc: state.isAsc);
    } else if (state is AuthorSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByAuthor(list: list, isAsc: state.isAsc);
    } else if (state is RatingSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByRating(list: list, isAsc: state.isAsc);
    } else if (state is PagesSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByPages(list: list, isAsc: state.isAsc);
    } else if (state is StartDateSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByStartDate(list: list, isAsc: state.isAsc);
    } else if (state is FinishDateSortState) {
      if (state.onlyFavourite) {
        list = _filterOutFav(list: list);
      }
      list = _sortByFinishDate(list: list, isAsc: state.isAsc);
    } else {
      list = _sortByTitle(list: list, isAsc: true);
    }

    return list;
  }

  List<Book> _filterOutFav({required List<Book> list}) {
    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.favourite) {
        filteredOut.add(book);
      }
    }

    return filteredOut;
  }

  List<Book> _sortByTitle({
    required List<Book> list,
    required bool isAsc,
  }) {
    isAsc
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
    isAsc
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

    isAsc
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

    isAsc
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

    isAsc
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

    isAsc
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
          children: const [
            Text(
              'Openreads',
              style: TextStyle(fontSize: 18),
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
          ),
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_applications),
          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchOLScreen(scan: true),
                      ),
                    );
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
                          return BlocBuilder<SortBloc, SortState>(
                            builder: (context, sortState) {
                              return BooksList(
                                books: _sortList(
                                  state: sortState,
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
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).mainTextColor,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
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
