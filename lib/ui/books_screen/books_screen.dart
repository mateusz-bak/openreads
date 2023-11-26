import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/display_bloc/display_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
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

import 'helper/multi_select_helper.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen>
    with AutomaticKeepAliveClientMixin {
  late List<String> moreButtonOptions;
  Set<int> selectedBookIds = {};

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
      list = _filterOutTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
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
      list = _filterOutTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
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
      list = _filterOutTags(
        list: list,
        tags: state.tags!,
        filterTagsAsAnd: state.filterTagsAsAnd,
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
      if (book.finishDate != null) {
        final year = book.finishDate!.year.toString();
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
        ? list.sort((a, b) => removeDiacritics(a.title.toString().toLowerCase())
            .compareTo(removeDiacritics(b.title.toString().toLowerCase())))
        : list.sort((b, a) =>
            removeDiacritics(a.author.toString().toLowerCase())
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
      int pagesSorting = removeDiacritics(a.pages!.toString().toLowerCase())
          .compareTo(removeDiacritics(b.pages!.toString().toLowerCase()));
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

    booksWithStartDate.sort((a, b) {
      int startDateSorting = (a.startDate!.millisecondsSinceEpoch)
          .compareTo(b.startDate!.millisecondsSinceEpoch);
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
      (book.finishDate != null)
          ? booksWithFinishDate.add(book)
          : booksWithoutFinishDate.add(book);
    }

    booksWithFinishDate.sort((a, b) {
      int finishDateSorting = (a.finishDate!.millisecondsSinceEpoch)
          .compareTo(b.finishDate!.millisecondsSinceEpoch);
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

  openSortFilterSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
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
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    moreButtonOptions = [
      LocaleKeys.sort_filter.tr(),
      LocaleKeys.statistics.tr(),
      LocaleKeys.settings.tr(),
    ];

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          AppTheme.init(state, context);

          return WillPopScope(
            child: Scaffold(
              appBar: selectedBookIds.isNotEmpty
                  ? _buildMultiSelectAppBar(context)
                  : _buildAppBar(context),
              floatingActionButton: selectedBookIds.isNotEmpty
                  ? _buildMultiSelectFAB(state)
                  : _buildFAB(context),
              body: _buildScaffoldBody(),
            ),
            onWillPop: () {
              if (selectedBookIds.isNotEmpty) {
                _resetMultiselectMode();
                return Future.value(false);
              }
              return Future.value(true);
            },
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

  Padding? _buildMultiSelectFAB(SetThemeState state) {
    return selectedBookIds.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: SpeedDial(
              spacing: 3,
              dialRoot: (ctx, open, toggleChildren) {
                return FloatingActionButton(
                    onPressed: toggleChildren, child: const Icon(Icons.create));
              },
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,
              children: [
                SpeedDialChild(
                    child: const Icon(Icons.menu_book_outlined),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    label: LocaleKeys.change_book_format.tr(),
                    onTap: () {
                      showEditBookTypeBottomSheet(context, selectedBookIds);
                    }),
              ],
            ))
        : null;
  }

  BlocBuilder<ThemeBloc, ThemeState> _buildScaffoldBody() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(
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
                SafeArea(
                  child: Builder(builder: (context) {
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: TabBar(
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
                    );
                  }),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _setEmptyBookForEditScreen() {
    context.read<EditBookCubit>().setBook(Book.empty());
  }

  Padding _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            elevation: 0,
            builder: (context) {
              return AddBookSheet(
                addManually: () async {
                  _setEmptyBookForEditScreen();

                  Navigator.pop(context);
                  await Future.delayed(const Duration(milliseconds: 100));
                  if (!mounted) return;

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddBookScreen(),
                    ),
                  );
                },
                searchInOpenLibrary: () async {
                  _setEmptyBookForEditScreen();

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
                  _setEmptyBookForEditScreen();

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
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Openreads',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchPage()),
          ),
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {
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
          },
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
                        onBookSelected: _onItemSelected,
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
                        onBookSelected: _onItemSelected,
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
                        onBookSelected: _onItemSelected,
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
