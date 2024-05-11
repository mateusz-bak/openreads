import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/display_bloc/display_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_screen/search_ol_screen.dart.dart';
import 'package:openreads/ui/search_page/search_page.dart';
import 'package:openreads/ui/settings_screen/settings_screen.dart';
import 'package:openreads/ui/statistics_screen/statistics_screen.dart';
import 'package:diacritic/diacritic.dart';
import 'package:openreads/ui/unfinished_screen/unfinished_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late List<String> moreButtonOptions;
  late double appBarHeight;
  Set<int> selectedBookIds = {};

  late TabController _tabController;

  _onItemSelected(int id) {
    setState(() {
      if (selectedBookIds.contains(id)) {
        selectedBookIds.remove(id);
      } else {
        selectedBookIds.add(id);
      }
    });
  }

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
      int ratingSorting = removeDiacritics(a.rating!.toString().toLowerCase())
          .compareTo(removeDiacritics(b.rating!.toString().toLowerCase()));
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

  void openSortFilterSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        builder: (_) {
          return const SortBottomSheet();
        },
      );
    } else if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return const SortBottomSheet();
        },
      );
    }
  }

  void goToStatisticsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StatisticsScreen(),
      ),
    );
  }

  void goToSettingsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void goToUnfinishedBooksScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnfinishedScreen(),
      ),
    );
  }

  BookStatus _getStatusForNewBook() {
    final inProgressIndex = readTabFirst ? 1 : 0;

    if (_tabController.index == inProgressIndex) {
      return BookStatus.inProgress;
    } else if (_tabController.index == 2) {
      return BookStatus.forLater;
    } else {
      return BookStatus.read;
    }
  }

  _setEmptyBookForEditScreen() {
    final status = _getStatusForNewBook();
    final defaultBookFormat = context.read<DefaultBooksFormatCubit>().state;

    context.read<EditBookCubit>().setBook(
          Book.empty(status: status, bookFormat: defaultBookFormat),
        );
  }

  _goToSearchPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  _changeBooksDisplayType() {
    final state = context.read<DisplayBloc>().state;

    if (state is GridDisplayState) {
      BlocProvider.of<DisplayBloc>(context).add(
        const ChangeDisplayEvent(displayAsGrid: false),
      );
    } else {
      BlocProvider.of<DisplayBloc>(context).add(
        const ChangeDisplayEvent(displayAsGrid: true),
      );
    }
  }

  _invokeThreeDotMenuOption(String choice) async {
    await Future.delayed(const Duration(milliseconds: 0));

    if (!mounted) return;

    if (choice == moreButtonOptions[0]) {
      openSortFilterSheet();
    } else if (choice == moreButtonOptions[1]) {
      goToStatisticsScreen();
    } else if (choice == moreButtonOptions[2]) {
      goToUnfinishedBooksScreen();
    } else if (choice == moreButtonOptions[3]) {
      goToSettingsScreen();
    }
  }

  _onFabPressed() {
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        builder: (_) {
          return AddBookSheet(
            addManually: _addBookManually,
            searchInOpenLibrary: _searchInOpenLibrary,
            scanBarcode: _scanBarcode,
          );
        },
      );
    } else if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return AddBookSheet(
            addManually: _addBookManually,
            searchInOpenLibrary: _searchInOpenLibrary,
            scanBarcode: _scanBarcode,
          );
        },
      );
    }
  }

  _addBookManually() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddBookScreen(),
      ),
    );
  }

  _searchInOpenLibrary() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOLScreen(
          status: _getStatusForNewBook(),
        ),
      ),
    );
  }

  _scanBarcode() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOLScreen(
          scan: true,
          status: _getStatusForNewBook(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    appBarHeight = AppBar().preferredSize.height;

    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    moreButtonOptions = [
      LocaleKeys.sort_filter.tr(),
      LocaleKeys.statistics.tr(),
      LocaleKeys.unfinished_books.tr(),
      LocaleKeys.settings.tr(),
    ];

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          AppTheme.init(state, context);

          return PopScope(
            canPop: selectedBookIds.isEmpty,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }

              _resetMultiselectMode();
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: true,
              appBar: selectedBookIds.isNotEmpty
                  ? _buildMultiSelectAppBar(context)
                  : _buildAppBar(context),
              floatingActionButton: selectedBookIds.isNotEmpty
                  ? _buildMultiSelectFAB(state)
                  : _buildFAB(context),
              body: _buildScaffoldBody(),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  AppBar _buildMultiSelectAppBar(BuildContext context) {
    return AppBar(
        title: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _resetMultiselectMode();
          },
        ),
        Text(
          '${LocaleKeys.selected.tr()} ${selectedBookIds.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ));
  }

  void _resetMultiselectMode() {
    setState(() {
      selectedBookIds = {};
    });
  }

  Widget? _buildMultiSelectFAB(SetThemeState state) {
    return selectedBookIds.isNotEmpty
        ? MultiSelectFAB(
            selectedBookIds: selectedBookIds,
            resetMultiselectMode: _resetMultiselectMode,
          )
        : null;
  }

  BlocBuilder<ThemeBloc, ThemeState> _buildScaffoldBody() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: state.readTabFirst
                      ? List.of([
                          _buildReadBooksTabView(),
                          _buildInProgressBooksTabView(),
                          _buildToReadBooksTabView(),
                        ])
                      : List.of([
                          _buildInProgressBooksTabView(),
                          _buildReadBooksTabView(),
                          _buildToReadBooksTabView(),
                        ]),
                ),
              ),
              Builder(builder: (context) {
                return Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    top: false,
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      tabs: state.readTabFirst
                          ? List.of([
                              BookTab(
                                text: LocaleKeys.books_finished.tr(),
                              ),
                              BookTab(
                                text: LocaleKeys.books_in_progress.tr(),
                              ),
                              BookTab(
                                text: LocaleKeys.books_for_later.tr(),
                              ),
                            ])
                          : List.of([
                              BookTab(
                                text: LocaleKeys.books_in_progress.tr(),
                              ),
                              BookTab(
                                text: LocaleKeys.books_finished.tr(),
                              ),
                              BookTab(
                                text: LocaleKeys.books_for_later.tr(),
                              ),
                            ]),
                    ),
                  ),
                );
              }),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Padding _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    AppBar appBar = AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      title: const Text(
        Constants.appName,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: _goToSearchPage,
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: _changeBooksDisplayType,
          icon: BlocBuilder<DisplayBloc, DisplayState>(
            builder: (context, state) {
              if (state is GridDisplayState) {
                return const Icon(Icons.list);
              } else {
                return const Icon(Icons.apps);
              }
            },
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (_) {},
          itemBuilder: (_) {
            return moreButtonOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(
                  choice,
                ),
                onTap: () => _invokeThreeDotMenuOption(choice),
              );
            }).toList();
          },
        ),
      ],
    );

    return Platform.isAndroid
        ? appBar
        : PreferredSize(
            preferredSize: Size(double.infinity, appBarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: appBar,
              ),
            ),
          );
  }

  StreamBuilder<List<Book>> _buildToReadBooksTabView() {
    return StreamBuilder<List<Book>>(
      stream: bookCubit.toReadBooks,
      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Text(
                  '${LocaleKeys.this_list_is_empty_1.tr()}\n${LocaleKeys.this_list_is_empty_2.tr()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                return BlocBuilder<DisplayBloc, DisplayState>(
                  builder: (context, displayState) {
                    if (displayState is GridDisplayState) {
                      return BooksGrid(
                        books: _sortForLaterList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 2,
                        selectedBookIds: selectedBookIds,
                        onBookSelectedForMultiSelect: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    } else {
                      return BooksList(
                        books: _sortForLaterList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 2,
                        selectedBookIds: selectedBookIds,
                        onBookSelected: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<Book>> _buildInProgressBooksTabView() {
    return StreamBuilder<List<Book>>(
      stream: bookCubit.inProgressBooks,
      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Text(
                  '${LocaleKeys.this_list_is_empty_1.tr()}\n${LocaleKeys.this_list_is_empty_2.tr()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                return BlocBuilder<DisplayBloc, DisplayState>(
                  builder: (context, displayState) {
                    if (displayState is GridDisplayState) {
                      return BooksGrid(
                        books: _sortInProgressList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 1,
                        selectedBookIds: selectedBookIds,
                        onBookSelectedForMultiSelect: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    } else {
                      return BooksList(
                        books: _sortInProgressList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 1,
                        selectedBookIds: selectedBookIds,
                        onBookSelected: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          );
        } else if (snapshot.hasError) {
          return Text(
            snapshot.error.toString(),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<Book>> _buildReadBooksTabView() {
    return StreamBuilder<List<Book>>(
      stream: bookCubit.finishedBooks,
      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Text(
                  '${LocaleKeys.this_list_is_empty_1.tr()}\n${LocaleKeys.this_list_is_empty_2.tr()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                return BlocBuilder<DisplayBloc, DisplayState>(
                  builder: (context, displayState) {
                    if (displayState is GridDisplayState) {
                      return BooksGrid(
                        books: _sortReadList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 0,
                        selectedBookIds: selectedBookIds,
                        onBookSelectedForMultiSelect: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    } else {
                      return BooksList(
                        books: _sortReadList(
                          state: state,
                          list: snapshot.data!,
                        ),
                        listNumber: 0,
                        selectedBookIds: selectedBookIds,
                        onBookSelected: _onItemSelected,
                        allBooksCount: snapshot.data!.length,
                      );
                    }
                  },
                );
              } else {
                return const SizedBox();
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
