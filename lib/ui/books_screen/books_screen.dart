import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/book_format.dart';
import 'package:openreads/core/constants/enums/sort_type.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/display_bloc/display_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  int _booksTabIndex = 0;

  late TabController _tabController;
  late ScrollController _chipScrollController;

  List<Book> _sortReadList({
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
      list = _filterTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
        filterOutSelectedTags: state.filterOutTags,
      );
    }

    if (state.bookType != null) {
      list = _filterOutBookTypes(list, state.bookType!);
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
      case SortType.byPublicationYear:
        list = _sortByPublicationYear(list: list, isAsc: state.isAsc);
        break;
      case SortType.byDateAdded:
        list = _sortByDateAdded(list: list, isAsc: state.isAsc);
        break;
      case SortType.byDateModified:
        list = _sortByDateModified(list: list, isAsc: state.isAsc);
        break;

      default:
        list = _sortByTitle(list: list, isAsc: state.isAsc);
    }

    return list;
  }

  List<Book> _sortInProgressList({
    required SetSortState state,
    required List<Book> list,
  }) {
    if (state.tags != null) {
      list = _filterTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
        filterOutSelectedTags: state.filterOutTags,
      );
    }

    if (state.bookType != null) {
      list = _filterOutBookTypes(list, state.bookType!);
    }

    switch (state.sortType) {
      case SortType.byAuthor:
        list = _sortByAuthor(list: list, isAsc: state.isAsc);
        break;

      case SortType.byPages:
        list = _sortByPages(list: list, isAsc: state.isAsc);
        break;
      case SortType.byStartDate:
        list = _sortByStartDate(list: list, isAsc: state.isAsc);
        break;
      default:
        list = _sortByTitle(list: list, isAsc: state.isAsc);
    }

    return list;
  }

  List<Book> _sortForLaterList({
    required SetSortState state,
    required List<Book> list,
  }) {
    if (state.tags != null) {
      list = _filterTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
        filterOutSelectedTags: state.filterOutTags,
      );
    }

    if (state.bookType != null) {
      list = _filterOutBookTypes(list, state.bookType!);
    }

    switch (state.sortType) {
      case SortType.byAuthor:
        list = _sortByAuthor(list: list, isAsc: state.isAsc);
        break;

      case SortType.byPages:
        list = _sortByPages(list: list, isAsc: state.isAsc);
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
      for (final reading in book.readings) {
        if (reading.finishDate != null) {
          final year = reading.finishDate!.year.toString();
          if (yearsList.contains(year)) {
            if (!filteredOut.contains(book)) {
              filteredOut.add(book);
            }
          }
        }
      }
    }

    return filteredOut;
  }

  List<Book> _filterTags({
    required List<Book> list,
    required String tags,
    required bool filterTagsAsAnd,
    required bool filterOutSelectedTags,
  }) {
    if (filterOutSelectedTags) {
      return _filterOutSelectedTags(list, tags);
    } else {
      if (filterTagsAsAnd) {
        return _filterTagsModeAnd(list, tags);
      } else {
        return _filterTagsModeOr(list, tags);
      }
    }
  }

  List<Book> _filterTagsModeOr(
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

  List<Book> _filterOutBookTypes(
    List<Book> list,
    BookFormat bookType,
  ) {
    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.bookFormat == bookType) {
        filteredOut.add(book);
      }
    }

    return filteredOut;
  }

  List<Book> _filterTagsModeAnd(
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

  // Return list of books that do not have selected tags
  List<Book> _filterOutSelectedTags(
    List<Book> list,
    String tags,
  ) {
    final tagsList = tags.split(('|||||'));

    final filteredOut = List<Book>.empty(growable: true);

    for (var book in list) {
      if (book.tags == null) {
        filteredOut.add(book);
      } else {
        final bookTags = book.tags!.split(('|||||'));

        bool addThisBookToList = true;

        for (var tagFromList in tagsList) {
          if (bookTags.contains(tagFromList)) {
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
        ? list.sort((a, b) => removeDiacritics(a.title.toString().toLowerCase())
            .compareTo(removeDiacritics(b.title.toString().toLowerCase())))
        : list.sort((b, a) => removeDiacritics(a.title.toString().toLowerCase())
            .compareTo(removeDiacritics(b.title.toString().toLowerCase())));
    // no secondary sorting

    return list;
  }

  List<Book> _sortByAuthor({
    required List<Book> list,
    required bool isAsc,
  }) {
    list.sort((a, b) {
      int authorSorting = removeDiacritics(a.author.toString().toLowerCase())
          .compareTo(removeDiacritics(b.author.toString().toLowerCase()));
      if (!isAsc) {
        authorSorting *= -1;
      } // descending
      if (authorSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return authorSorting;
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

    booksRated.sort((a, b) {
      int ratingSorting = a.rating!.compareTo(b.rating!);
      if (!isAsc) {
        ratingSorting *= -1;
      } // descending
      if (ratingSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return ratingSorting;
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

    booksWithPages.sort((a, b) {
      int pagesSorting = a.pages!.compareTo(b.pages!);
      if (!isAsc) {
        pagesSorting *= -1;
      } // descending
      if (pagesSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return pagesSorting;
    });

    return booksWithPages + booksWithoutPages;
  }

  List<Book> _sortByDateAdded({
    required List<Book> list,
    required bool isAsc,
  }) {
    list.sort((a, b) {
      int dateAddedSorting = a.dateAdded.millisecondsSinceEpoch
          .compareTo(b.dateAdded.millisecondsSinceEpoch);

      if (!isAsc) {
        dateAddedSorting *= -1;
      } // descending
      if (dateAddedSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return dateAddedSorting;
    });

    return list;
  }

  List<Book> _sortByDateModified({
    required List<Book> list,
    required bool isAsc,
  }) {
    list.sort((a, b) {
      int dateModifiedSorting = a.dateModified.millisecondsSinceEpoch
          .compareTo(b.dateModified.millisecondsSinceEpoch);

      if (!isAsc) {
        dateModifiedSorting *= -1;
      } // descending
      if (dateModifiedSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return dateModifiedSorting;
    });

    return list;
  }

  List<Book> _sortByStartDate({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksWithoutStartDate = List.empty(growable: true);
    List<Book> booksWithStartDate = List.empty(growable: true);

    for (Book book in list) {
      bool hasStartDate = false;

      for (final reading in book.readings) {
        if (reading.startDate != null) {
          hasStartDate = true;
        }
      }

      hasStartDate
          ? booksWithStartDate.add(book)
          : booksWithoutStartDate.add(book);
    }

    booksWithStartDate.sort((a, b) {
      final bookALatestStartDate = getLatestStartDate(a);
      final bookBLatestStartDate = getLatestStartDate(b);

      int startDateSorting = (bookALatestStartDate!.millisecondsSinceEpoch)
          .compareTo(bookBLatestStartDate!.millisecondsSinceEpoch);

      if (!isAsc) {
        startDateSorting *= -1;
      } // descending
      if (startDateSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return startDateSorting;
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
      bool hasFinishDate = false;

      for (final reading in book.readings) {
        if (reading.finishDate != null) {
          hasFinishDate = true;
        }
      }

      hasFinishDate
          ? booksWithFinishDate.add(book)
          : booksWithoutFinishDate.add(book);
    }

    booksWithFinishDate.sort((a, b) {
      final bookALatestFinishDate = getLatestFinishDate(a);
      final bookBLatestFinishDate = getLatestFinishDate(b);

      int finishDateSorting = (bookALatestFinishDate!.millisecondsSinceEpoch)
          .compareTo(bookBLatestFinishDate!.millisecondsSinceEpoch);

      if (!isAsc) {
        finishDateSorting *= -1;
      } // descending
      if (finishDateSorting == 0) {
        // secondary sorting, by release date
        int releaseSorting = 0;
        if ((a.publicationYear != null) && (b.publicationYear != null)) {
          releaseSorting = a.publicationYear!.compareTo(b.publicationYear!);
          if (!isAsc) {
            releaseSorting *= -1;
          }
        }
        if (releaseSorting == 0) {
          // tertiary sorting, by title
          int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
              .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
          if (!isAsc) {
            titleSorting *= -1;
          }
          return titleSorting;
        }
        return releaseSorting;
      }
      return finishDateSorting;
    });

    return booksWithFinishDate + booksWithoutFinishDate;
  }

  List<Book> _sortByPublicationYear({
    required List<Book> list,
    required bool isAsc,
  }) {
    List<Book> booksWithoutPublicationDate = List.empty(growable: true);
    List<Book> booksWithPublicationDate = List.empty(growable: true);

    for (Book book in list) {
      (book.publicationYear != null)
          ? booksWithPublicationDate.add(book)
          : booksWithoutPublicationDate.add(book);
    }

    booksWithPublicationDate.sort((a, b) {
      int publicationYearSorting =
          a.publicationYear!.compareTo(b.publicationYear!);
      if (!isAsc) {
        publicationYearSorting *= -1;
      }

      if (publicationYearSorting == 0) {
        int titleSorting = removeDiacritics(a.title.toString().toLowerCase())
            .compareTo(removeDiacritics(b.title.toString().toLowerCase()));
        if (!isAsc) {
          titleSorting *= -1;
        }
        return titleSorting;
      }
      return publicationYearSorting;
    });

    return booksWithPublicationDate + booksWithoutPublicationDate;
  }

  _changeTab(int index, SetThemeState state) {
    setState(() {
      _booksTabIndex = index;
    });

    if (index == 0) {
      _tabController.index = state.readTabFirst ? 0 : 1;
    } else if (index == 1) {
      _tabController.index = state.readTabFirst ? 1 : 0;
    } else if (index == 2) {
      _tabController.index = 2;
    } else if (index == 3) {
      _tabController.index = 3;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    _chipScrollController = ScrollController();

    // Selects the chip when the tab changes
    // Not needed when NeverScrollableScrollPhysics
    // _tabController.addListener(() {
    //   setState(() {
    //     _booksTabIndex = _tabController.index;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              SingleChildScrollView(
                controller: _chipScrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BooksTabChip(
                      selected: _booksTabIndex == 0,
                      setThemeState: state,
                      index: 0,
                      changeTab: _changeTab,
                      tabController: _tabController,
                      title: LocaleKeys.finished_books.tr(),
                    ),
                    BooksTabChip(
                      selected: _booksTabIndex == 1,
                      setThemeState: state,
                      index: 1,
                      changeTab: _changeTab,
                      tabController: _tabController,
                      title: LocaleKeys.books_in_progress.tr(),
                    ),
                    BooksTabChip(
                      selected: _booksTabIndex == 2,
                      setThemeState: state,
                      index: 2,
                      changeTab: _changeTab,
                      tabController: _tabController,
                      title: LocaleKeys.books_for_later.tr(),
                    ),
                    BooksTabChip(
                      selected: _booksTabIndex == 3,
                      setThemeState: state,
                      index: 3,
                      changeTab: _changeTab,
                      tabController: _tabController,
                      title: LocaleKeys.books_unfinished.tr(),
                    ),
                    const SizedBox(width: 8)
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  // TODO: decide if we want to keep NeverScrollableScrollPhysics
                  physics: const NeverScrollableScrollPhysics(),
                  children: state.readTabFirst
                      ? List.of([
                          _buildFinishedBooksTabView(),
                          _buildInProgressBooksTabView(),
                          _buildToReadBooksTabView(),
                          _buildUnfinishedBooksTabView(),
                        ])
                      : List.of([
                          _buildInProgressBooksTabView(),
                          _buildFinishedBooksTabView(),
                          _buildToReadBooksTabView(),
                          _buildUnfinishedBooksTabView(),
                        ]),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  StreamBuilder<List<Book>> _buildFinishedBooksTabView() {
    return _buildBooksTabView(
      listNumber: 0,
      stream: bookCubit.finishedBooks,
      sorting: _sortReadList,
    );
  }

  StreamBuilder<List<Book>> _buildInProgressBooksTabView() {
    return _buildBooksTabView(
      listNumber: 1,
      stream: bookCubit.inProgressBooks,
      sorting: _sortInProgressList,
    );
  }

  StreamBuilder<List<Book>> _buildToReadBooksTabView() {
    return _buildBooksTabView(
      listNumber: 2,
      stream: bookCubit.toReadBooks,
      sorting: _sortForLaterList,
    );
  }

  StreamBuilder<List<Book>> _buildUnfinishedBooksTabView() {
    bookCubit.getUnfinishedBooks();

    //TODO: sort unfinished book by date of modification
    return _buildBooksTabView(
      listNumber: 3,
      stream: bookCubit.unfinishedBooks,
      sorting: null,
    );
  }

  StreamBuilder<List<Book>> _buildBooksTabView({
    required int listNumber,
    required Stream<List<Book>> stream,
    required List<Book> Function({
      required SetSortState state,
      required List<Book> list,
    })? sorting,
  }) {
    return StreamBuilder<List<Book>>(
      stream: stream,
      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const ThisListIsEmpty();
          }

          return BlocBuilder<SortBloc, SortState>(
            builder: (context, state) {
              if (state is SetSortState) {
                return BlocBuilder<DisplayBloc, DisplayState>(
                  builder: (context, displayState) {
                    if (displayState is GridDisplayState) {
                      return BooksGrid(
                        books: sorting != null
                            ? sorting(
                                state: state,
                                list: snapshot.data!,
                              )
                            : snapshot.data!,
                        listNumber: listNumber,
                        allBooksCount: snapshot.data!.length,
                      );
                    } else {
                      return BooksList(
                        books: sorting != null
                            ? sorting(
                                state: state,
                                list: snapshot.data!,
                              )
                            : snapshot.data!,
                        listNumber: listNumber,
                        allBooksCount: snapshot.data!.length,
                      );
                    }
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          );
        } else if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
