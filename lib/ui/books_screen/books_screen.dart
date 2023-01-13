import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';
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
  final moreButtonOptions = [
    'Sort / filter',
    'Statistics',
    'Settings',
  ];

  List<Book> _sortList({
    required SetSortState state,
    required List<Book> list,
  }) {
    if (state.onlyFavourite) {
      list = _filterOutFav(list: list);
    }

    if (state.years != null) {
      list = _filterOutYears(list: list, years: state.years!);
    }

    if (state.tags != null) {
      list = _filterOutTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
      );
    }

    switch (state.sortType) {
      case SortType.byAuthor:
        list = _sortByAuthor(list: list, isAsc: state.isAsc);
        break;
      case SortType.byRating:
        list = _sortByRating(list: list, isAsc: state.isAsc);
        break;
      case SortType.byPages:
        list = _sortByPages(list: list, isAsc: state.isAsc);
        break;
      case SortType.byStartDate:
        list = _sortByStartDate(list: list, isAsc: state.isAsc);
        break;
      case SortType.byFinishDate:
        list = _sortByFinishDate(list: list, isAsc: state.isAsc);
        break;
      default:
        list = _sortByTitle(list: list, isAsc: state.isAsc);
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

  List<Book> _filterOutYears({
    required List<Book> list,
    required String years,
  }) {
    final yearsList = years.split(('|||||'));

    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.finishDate != null) {
        final year = DateTime.parse(book.finishDate!).year.toString();
        if (yearsList.contains(year)) {
          filteredOut.add(book);
        }
      }
    }

    return filteredOut;
  }

  List<Book> _filterOutTags({
    required List<Book> list,
    required String tags,
    required bool filterTagsAsAnd,
  }) {
    if (filterTagsAsAnd) {
      return _filterOutTagsModeAnd(list, tags);
    } else {
      return _filterOutTagsModeOr(list, tags);
    }
  }

  List<Book> _filterOutTagsModeOr(
    List<Book> list,
    String tags,
  ) {
    final tagsList = tags.split(('|||||'));

    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.tags != null) {
        final bookTags = book.tags!.split(('|||||'));

        bool addThisBookToList = false;

        for (var bookTag in bookTags) {
          if (tagsList.contains(bookTag)) {
            addThisBookToList = true;
          }
        }

        if (addThisBookToList) {
          filteredOut.add(book);
        }
      }
    }

    return filteredOut;
  }

  List<Book> _filterOutTagsModeAnd(
    List<Book> list,
    String tags,
  ) {
    final tagsList = tags.split(('|||||'));

    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.tags != null) {
        final bookTags = book.tags!.split(('|||||'));

        bool addThisBookToList = true;

        for (var tagFromList in tagsList) {
          if (!bookTags.contains(tagFromList)) {
            addThisBookToList = false;
          }
        }

        if (addThisBookToList) {
          filteredOut.add(book);
        }
      }
    }

    return filteredOut;
  }

  List<Book> _sortByTitle({
    required List<Book> list,
    required bool isAsc,
  }) {
    isAsc
        ? list.sort((a, b) => a.title
            .toString()
            .toLowerCase()
            .compareTo(b.title.toString().toLowerCase()))
        : list.sort((b, a) => a.author
            .toString()
            .toLowerCase()
            .compareTo(b.title.toString().toLowerCase()));

    return list;
  }

  List<Book> _sortByAuthor({
    required List<Book> list,
    required bool isAsc,
  }) {
    isAsc
        ? list.sort((a, b) => a.author
            .toString()
            .toLowerCase()
            .compareTo(b.author.toString().toLowerCase()))
        : list.sort((b, a) => a.author
            .toString()
            .toLowerCase()
            .compareTo(b.author.toString().toLowerCase()));

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
        ? booksRated.sort((a, b) => a.rating!.compareTo(b.rating!))
        : booksRated.sort((b, a) => a.rating!.compareTo(b.rating!));

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
        ? booksWithPages.sort((a, b) => a.pages!.compareTo(b.pages!))
        : booksWithPages.sort((b, a) => a.pages!.compareTo(b.pages!));

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
        ? booksWithStartDate.sort((a, b) =>
            (DateTime.parse(a.startDate!).millisecondsSinceEpoch)
                .compareTo(DateTime.parse(b.startDate!).millisecondsSinceEpoch))
        : booksWithStartDate.sort((b, a) => (DateTime.parse(a.startDate!)
                .millisecondsSinceEpoch)
            .compareTo(DateTime.parse(b.startDate!).millisecondsSinceEpoch));

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
        ? booksWithFinishDate.sort((a, b) => (DateTime.parse(a.finishDate!)
                .millisecondsSinceEpoch)
            .compareTo(DateTime.parse(b.finishDate!).millisecondsSinceEpoch))
        : booksWithFinishDate.sort((b, a) => (DateTime.parse(a.finishDate!)
                .millisecondsSinceEpoch)
            .compareTo(DateTime.parse(b.finishDate!).millisecondsSinceEpoch));

    return booksWithFinishDate + booksWithoutFinishDate;
  }

  openSortFilterSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const SortBottomSheet();
      },
    );
  }

  goToStatisticsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatisticsScreen(),
      ),
    );
  }

  goToSettingsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
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
        title: const Text(
          'Openreads',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (_) {
              return moreButtonOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 0));

                    if (!mounted) return;

                    if (choice == moreButtonOptions[0]) {
                      openSortFilterSheet();
                    } else if (choice == moreButtonOptions[1]) {
                      goToStatisticsScreen();
                    } else if (choice == moreButtonOptions[2]) {
                      goToSettingsScreen();
                    }
                  },
                );
              }).toList();
            },
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
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Text(
                                  'Your read books list is currently empty. Click the "+" button below to add a new one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                          return BlocBuilder<SortBloc, SortState>(
                            builder: (context, state) {
                              if (state is SetSortState) {
                                return BooksList(
                                  books: _sortList(
                                    state: state,
                                    list: snapshot.data!,
                                  ),
                                  listNumber: 0,
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.inProgressBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Text(
                                  'Your in progress books list is currently empty. Click the "+" button below to add a new one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                          return BooksList(
                            books: snapshot.data!,
                            listNumber: 1,
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.toReadBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Text(
                                  'Your for later books list is currently empty. Click the "+" button below to add a new one.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    letterSpacing: 1.5,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                          return BooksList(
                            books: snapshot.data!,
                            listNumber: 2,
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Builder(builder: (context) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).mainTextColor,
                    indicator: CustomTabIndicator(themeData: Theme.of(context)),
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 30),
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
                );
              }),
            ],
          )),
    );
  }
}
