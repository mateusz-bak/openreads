import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/book_format.dart';
import 'package:openreads/core/constants/enums/book_status.dart';
import 'package:openreads/core/constants/enums/sort_type.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/display_bloc/display_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_finished_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_for_later_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_in_progress_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_state.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_unfinished_books_bloc.dart';
import 'package:openreads/logic/cubit/book_lists_order_cubit.dart';
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
  late TabController _tabController;
  late ScrollController _chipScrollController;

  List<Book> _sortReadList({
    required SortState state,
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

    return _sort(list: list, sortType: state.sortType, isAsc: state.isAsc);
  }

  List<Book> _sortInProgressList({
    required SortState state,
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

    return _sort(list: list, sortType: state.sortType, isAsc: state.isAsc);
  }

  List<Book> _sortForLaterList({
    required SortState state,
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

    return _sort(list: list, sortType: state.sortType, isAsc: state.isAsc);
  }

  List<Book> _sortUnfinishedList({
    required SortState state,
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

    return _sort(list: list, sortType: state.sortType, isAsc: state.isAsc);
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

  List<Book> _sort({
    required List<Book> list,
    required SortType sortType,
    required bool isAsc,
  }) {
    switch (sortType) {
      case SortType.byTitle:
        return _sortByTitle(list: list, isAsc: isAsc);
      case SortType.byAuthor:
        return _sortByAuthor(list: list, isAsc: isAsc);
      case SortType.byRating:
        return _sortByRating(list: list, isAsc: isAsc);
      case SortType.byPages:
        return _sortByPages(list: list, isAsc: isAsc);
      case SortType.byStartDate:
        return _sortByStartDate(list: list, isAsc: isAsc);
      case SortType.byFinishDate:
        return _sortByFinishDate(list: list, isAsc: isAsc);
      case SortType.byPublicationYear:
        return _sortByPublicationYear(list: list, isAsc: isAsc);
      case SortType.byDateAdded:
        return _sortByDateAdded(list: list, isAsc: isAsc);
      case SortType.byDateModified:
        return _sortByDateModified(list: list, isAsc: isAsc);
    }
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
    _chipScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<BookListsOrderCubit, List<BookStatus>>(
      builder: (context, bookListsOrder) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            SingleChildScrollView(
              controller: _chipScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _buildTabChips(context, bookListsOrder),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: _buildTabs(context, bookListsOrder),
              ),
            ),
          ],
        );
      },
    );
  }

  BlocBuilder<SortFinishedBooksBloc, SortState> _buildFinishedBooksTabView() {
    return BlocBuilder<SortFinishedBooksBloc, SortState>(
      builder: (context, state) {
        return _buildBooksTabView(
          listNumber: 0,
          stream: bookCubit.finishedBooks,
          sortState: state,
          sorting: _sortReadList,
        );
      },
    );
  }

  BlocBuilder<SortInProgressBooksBloc, SortState>
      _buildInProgressBooksTabView() {
    return BlocBuilder<SortInProgressBooksBloc, SortState>(
      builder: (context, state) {
        return _buildBooksTabView(
          listNumber: 1,
          stream: bookCubit.inProgressBooks,
          sortState: state,
          sorting: _sortInProgressList,
        );
      },
    );
  }

  BlocBuilder<SortForLaterBooksBloc, SortState> _buildToReadBooksTabView() {
    return BlocBuilder<SortForLaterBooksBloc, SortState>(
      builder: (context, state) {
        return _buildBooksTabView(
          listNumber: 2,
          stream: bookCubit.toReadBooks,
          sortState: state,
          sorting: _sortForLaterList,
        );
      },
    );
  }

  BlocBuilder<SortUnfinishedBooksBloc, SortState>
      _buildUnfinishedBooksTabView() {
    return BlocBuilder<SortUnfinishedBooksBloc, SortState>(
      builder: (context, state) {
        return _buildBooksTabView(
          listNumber: 3,
          stream: bookCubit.unfinishedBooks,
          sortState: state,
          sorting: _sortUnfinishedList,
        );
      },
    );
  }

  StreamBuilder<List<Book>> _buildBooksTabView({
    required int listNumber,
    required Stream<List<Book>> stream,
    required SortState sortState,
    List<Book> Function({
      required SortState state,
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

          return BlocBuilder<DisplayBloc, DisplayState>(
            builder: (context, displayState) {
              if (displayState is GridDisplayState) {
                return BooksGrid(
                  books: sorting != null
                      ? sorting(
                          state: sortState,
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
                          state: sortState,
                          list: snapshot.data!,
                        )
                      : snapshot.data!,
                  listNumber: listNumber,
                  allBooksCount: snapshot.data!.length,
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<Widget> _buildTabChips(
    BuildContext context,
    List<BookStatus> bookListsOrder,
  ) {
    List<Widget> tabChips = [];
    int index = 0;

    for (var status in bookListsOrder) {
      switch (status) {
        case BookStatus.read:
          tabChips.add(BooksTabChip(
            index: index,
            tabController: _tabController,
            title: LocaleKeys.books_finished.tr(),
          ));
          break;
        case BookStatus.inProgress:
          tabChips.add(BooksTabChip(
            index: index,
            tabController: _tabController,
            title: LocaleKeys.books_in_progress.tr(),
          ));
          break;
        case BookStatus.forLater:
          tabChips.add(BooksTabChip(
            index: index,
            tabController: _tabController,
            title: LocaleKeys.books_for_later.tr(),
          ));
          break;
        case BookStatus.unfinished:
          tabChips.add(BooksTabChip(
            index: index,
            tabController: _tabController,
            title: LocaleKeys.books_unfinished.tr(),
          ));
          break;
      }

      index++;
    }

    tabChips.add(const SizedBox(width: 10));

    return tabChips;
  }

  List<Widget> _buildTabs(
    BuildContext context,
    List<BookStatus> bookListsOrder,
  ) {
    List<Widget> tabs = [];

    for (var status in bookListsOrder) {
      switch (status) {
        case BookStatus.read:
          tabs.add(_buildFinishedBooksTabView());
          break;
        case BookStatus.inProgress:
          tabs.add(_buildInProgressBooksTabView());
          break;
        case BookStatus.forLater:
          tabs.add(_buildToReadBooksTabView());
          break;
        case BookStatus.unfinished:
          tabs.add(_buildUnfinishedBooksTabView());
          break;
      }
    }

    return tabs;
  }
}
