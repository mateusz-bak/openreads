import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_event.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_finished_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_for_later_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_in_progress_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_state.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_unfinished_books_bloc.dart';
import 'package:openreads/logic/cubit/book_lists_order_cubit.dart';
import 'package:openreads/logic/cubit/books_tab_index_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

List<SortType> _getValidSortOptions(BookStatus bookStatus) {
  switch (bookStatus) {
    case BookStatus.read:
      return [
        SortType.byTitle,
        SortType.byAuthor,
        SortType.byRating,
        SortType.byPages,
        SortType.byStartDate,
        SortType.byFinishDate,
        SortType.byPublicationYear,
        SortType.byDateAdded,
        SortType.byDateModified,
      ];
    case BookStatus.inProgress:
      return [
        SortType.byTitle,
        SortType.byAuthor,
        SortType.byPages,
        SortType.byStartDate,
        SortType.byPublicationYear,
        SortType.byDateAdded,
        SortType.byDateModified,
      ];
    case BookStatus.forLater:
      return [
        SortType.byTitle,
        SortType.byAuthor,
        SortType.byPages,
        SortType.byPublicationYear,
        SortType.byDateAdded,
        SortType.byDateModified,
      ];
    case BookStatus.unfinished:
      return [
        SortType.byTitle,
        SortType.byAuthor,
        SortType.byPages,
        SortType.byStartDate,
        SortType.byPublicationYear,
        SortType.byDateAdded,
        SortType.byDateModified,
      ];
  }
}

String _getSortDropdownText(SortType sortType) {
  switch (sortType) {
    case SortType.byTitle:
      return LocaleKeys.title.tr();
    case SortType.byAuthor:
      return LocaleKeys.author.tr();
    case SortType.byRating:
      return LocaleKeys.rating.tr();
    case SortType.byPages:
      return LocaleKeys.pages_uppercase.tr();
    case SortType.byStartDate:
      return LocaleKeys.start_date.tr();
    case SortType.byFinishDate:
      return LocaleKeys.finish_date.tr();
    case SortType.byPublicationYear:
      return LocaleKeys.enter_publication_year.tr();
    case SortType.byDateAdded:
      return LocaleKeys.date_added.tr();
    case SortType.byDateModified:
      return LocaleKeys.date_modified.tr();
  }
}

String _getBookTypeDropdownText(BookFormat? bookFormat) {
  if (bookFormat == null) return LocaleKeys.book_format_all.tr();
  switch (bookFormat) {
    case BookFormat.paperback:
      return LocaleKeys.book_format_paperback_plural.tr();
    case BookFormat.hardcover:
      return LocaleKeys.book_format_hardcover_plural.tr();
    case BookFormat.ebook:
      return LocaleKeys.book_format_ebook_plural.tr();
    case BookFormat.audiobook:
      return LocaleKeys.book_format_audiobook_plural.tr();
  }
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  Bloc _getBlocProvider(BookStatus bookStatus) {
    switch (bookStatus) {
      case BookStatus.read:
        return BlocProvider.of<SortFinishedBooksBloc>(context);
      case BookStatus.inProgress:
        return BlocProvider.of<SortInProgressBooksBloc>(context);
      case BookStatus.forLater:
        return BlocProvider.of<SortForLaterBooksBloc>(context);
      case BookStatus.unfinished:
        return BlocProvider.of<SortUnfinishedBooksBloc>(context);
    }
  }

  Widget _getOrderButton(BookStatus bookStatus, SortState sortState) {
    return SizedBox(
      height: 40,
      width: 40,
      child: IconButton(
        icon: sortState.isAsc
            ? const FaIcon(FontAwesomeIcons.arrowUp, size: 18)
            : const FaIcon(FontAwesomeIcons.arrowDown, size: 18),
        onPressed: () =>
            _getBlocProvider(bookStatus).add(const ToggleOrderEvent()),
      ),
    );
  }

  _onYearChipPressed({
    required BookStatus bookStatus,
    required bool selected,
    required List<String> selectedYearsList,
    required int dbYear,
  }) {
    if (selectedYearsList.isNotEmpty && selectedYearsList[0] == '') {
      selectedYearsList.removeAt(0);
    }

    if (selected) {
      selectedYearsList.add(dbYear.toString());
    } else {
      bool deleteYear = true;
      while (deleteYear) {
        deleteYear = selectedYearsList.remove(dbYear.toString());
      }
    }

    _getBlocProvider(bookStatus).add(
      ChangeYearsEvent(
        selectedYearsList.isEmpty ? null : selectedYearsList.join('|||||'),
      ),
    );
  }

  _onTagChipPressed({
    required BookStatus bookStatus,
    required bool selected,
    required List<String> selectedTagsList,
    required String dbTag,
  }) {
    if (selectedTagsList.isNotEmpty && selectedTagsList[0] == '') {
      selectedTagsList.removeAt(0);
    }

    if (selected) {
      selectedTagsList.add(dbTag);
    } else {
      bool deleteYear = true;
      while (deleteYear) {
        deleteYear = selectedTagsList.remove(dbTag);
      }
    }

    _getBlocProvider(bookStatus).add(
      ChangeTagsEvent(
        selectedTagsList.isEmpty ? null : selectedTagsList.join('|||||'),
      ),
    );
  }

  List<Widget> _buildYearChips(
    BookStatus bookStatus,
    List<int> dbYears,
    String? selectedYears,
  ) {
    final chips = List<Widget>.empty(growable: true);
    final inactiveChips = List<Widget>.empty(growable: true);

    List<String> selectedYearsList = selectedYears != null
        ? selectedYears.split('|||||')
        : List<String>.empty(growable: true);

    final uniqueDbYears = List<int>.empty(growable: true);

    for (var dbYear in dbYears) {
      if (!uniqueDbYears.contains(dbYear)) {
        uniqueDbYears.add(dbYear);
      }
    }

    for (var selectedYear in selectedYearsList) {
      if (!uniqueDbYears.contains(int.parse(selectedYear))) {
        uniqueDbYears.add(int.parse(selectedYear));
      }
    }

    for (var dbYear in uniqueDbYears) {
      bool isSelected = selectedYearsList.contains(dbYear.toString());
      YearFilterChip chip = YearFilterChip(
        dbYear: dbYear,
        selected: isSelected,
        onYearChipPressed: (bool selected) => _onYearChipPressed(
          bookStatus: bookStatus,
          dbYear: dbYear,
          selected: selected,
          selectedYearsList: selectedYearsList,
        ),
      );

      if (isSelected) {
        chips.add(chip);
      } else {
        inactiveChips.add(chip);
      }
    }

    chips.addAll(inactiveChips);

    // Last chip is to select all/none years
    chips.add(
      YearFilterChip(
        dbYear: null,
        selected: selectedYears == dbYears.join('|||||'),
        onYearChipPressed: (_) => _getBlocProvider(bookStatus).add(
          ChangeYearsEvent(
            selectedYears == dbYears.join('|||||')
                ? null
                : dbYears.join('|||||'),
          ),
        ),
      ),
    );

    return chips;
  }

  List<Widget> _buildTagChips(
    BookStatus bookStatus,
    List<String> dbTags,
    String? selectedTags,
  ) {
    final chips = List<Widget>.empty(growable: true);
    final inactiveChips = List<Widget>.empty(growable: true);

    late List<String> selectedTagsList;

    if (selectedTags != null) {
      selectedTagsList = selectedTags.split('|||||');
    } else {
      selectedTagsList = List<String>.empty(growable: true);
    }

    selectedTagsList.sort((a, b) => removeDiacritics(a.toLowerCase())
        .compareTo(removeDiacritics(b.toLowerCase())));

    for (var selectedTag in selectedTagsList) {
      if (!dbTags.contains(selectedTag)) {
        dbTags.add(selectedTag);
      }
    }

    dbTags.sort((a, b) => removeDiacritics(a.toLowerCase())
        .compareTo(removeDiacritics(b.toLowerCase())));

    for (var dbTag in dbTags) {
      bool isSelected = selectedTagsList.contains(dbTag.toString());
      TagFilterChip chip = TagFilterChip(
        tag: dbTag,
        selected: isSelected,
        onTagChipPressed: (bool selected) {
          _onTagChipPressed(
            bookStatus: bookStatus,
            dbTag: dbTag,
            selected: selected,
            selectedTagsList: selectedTagsList,
          );
        },
      );

      if (isSelected) {
        chips.add(chip);
      } else {
        inactiveChips.add(chip);
      }
    }

    chips.addAll(inactiveChips);

    // Last chip is to select all/none tags
    chips.add(
      TagFilterChip(
        tag: null,
        selected: selectedTags == dbTags.join('|||||'),
        onTagChipPressed: (_) => _getBlocProvider(bookStatus).add(
          ChangeTagsEvent(
            selectedTags == dbTags.join('|||||') ? null : dbTags.join('|||||'),
          ),
        ),
      ),
    );

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: BlocBuilder<BookListsOrderCubit, List<BookStatus>>(
                builder: (context, bookStatusList) {
                  return BlocBuilder<BooksTabIndexCubit, int>(
                    builder: (context, tabIndex) {
                      switch (bookStatusList[tabIndex]) {
                        case BookStatus.read:
                          return BlocBuilder<SortFinishedBooksBloc, SortState>(
                            builder: (context, state) =>
                                _buildBody(BookStatus.read, state),
                          );
                        case BookStatus.inProgress:
                          return BlocBuilder<SortInProgressBooksBloc,
                              SortState>(
                            builder: (context, state) =>
                                _buildBody(BookStatus.inProgress, state),
                          );
                        case BookStatus.forLater:
                          return BlocBuilder<SortForLaterBooksBloc, SortState>(
                            builder: (context, state) =>
                                _buildBody(BookStatus.forLater, state),
                          );
                        case BookStatus.unfinished:
                          return BlocBuilder<SortUnfinishedBooksBloc,
                              SortState>(
                            builder: (context, state) =>
                                _buildBody(BookStatus.unfinished, state),
                          );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BookStatus bookStatus, SortState sortState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          LocaleKeys.sort_by.tr(),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        _buildSortDropdown(bookStatus, sortState),
        const SizedBox(height: 5),
        if (bookStatus == BookStatus.read)
          _buildOnlyFavouriteSwitch(bookStatus, sortState.onlyFavourite),
        const SizedBox(height: 5),
        Text(
          LocaleKeys.filter_by_book_format.tr(),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 5),
        _buildBookTypeFilter(bookStatus, sortState.bookType),
        if (bookStatus == BookStatus.read)
          _buildFilterByFinishYears(bookStatus, sortState.years),
        _buildFilterByTags(bookStatus, sortState.tags),
        _buildFilterTagsAsAnd(bookStatus, sortState.filterTagsAsAnd),
        _buildFilterOutTags(bookStatus, sortState.filterOutTags),
      ],
    );
  }

  Row _buildFilterOutTags(BookStatus bookStatus, bool filterOutTags) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _getBlocProvider(bookStatus)
                .add(ChangeFilterOutTags(!filterOutTags)),
            child: _buildBooksExceptTags(bookStatus, filterOutTags),
          ),
        ),
      ],
    );
  }

  Row _buildFilterTagsAsAnd(BookStatus bookStatus, bool filterTagsAsAnd) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _getBlocProvider(bookStatus)
                .add(ChangeFilterTagsAsAnd(!filterTagsAsAnd)),
            child: _buildOnlyBooksWithAllTags(bookStatus, filterTagsAsAnd),
          ),
        ),
      ],
    );
  }

  StreamBuilder<List<String>> _buildFilterByTags(
    BookStatus bookStatus,
    String? tags,
  ) {
    return StreamBuilder<List<String>>(
      stream: bookCubit.tags,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty && tags == null) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                LocaleKeys.filter_by_tags.tr(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        border: Border.all(color: dividerColor),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 2.5,
                          ),
                          child: Row(
                            children: _buildTagChips(
                              bookStatus,
                              snapshot.data!,
                              tags,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  StreamBuilder<List<int>> _buildFilterByFinishYears(
    BookStatus bookStatus,
    String? years,
  ) {
    return StreamBuilder<List<int>>(
      stream: bookCubit.finishedYears,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty && years == null) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                LocaleKeys.filter_by_finish_year.tr(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(cornerRadius),
                        border: Border.all(color: dividerColor),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 2.5,
                          ),
                          child: Row(
                            children: _buildYearChips(
                              bookStatus,
                              snapshot.data!,
                              years,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Row _buildOnlyFavouriteSwitch(BookStatus bookStatus, bool onlyFavourite) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _getBlocProvider(bookStatus)
                .add(ChangeOnlyFavouriteEvent(!onlyFavourite)),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 40,
                    child: Switch.adaptive(
                      value: onlyFavourite,
                      onChanged: (value) => _getBlocProvider(bookStatus).add(
                        ChangeOnlyFavouriteEvent(value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKeys.only_favourite.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _buildSortDropdown(BookStatus bookStatus, SortState sortState) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<SortType>(
              isExpanded: true,
              buttonStyleData: ButtonStyleData(
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: dividerColor),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
              items: _getValidSortOptions(bookStatus)
                  .map(
                    (item) => DropdownMenuItem<SortType>(
                      value: item,
                      child: Text(
                        _getSortDropdownText(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              value: sortState.sortType,
              onChanged: (value) => _getBlocProvider(bookStatus).add(
                ChangeSortTypeEvent(value ?? SortType.byTitle),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border.all(color: dividerColor),
          ),
          child: _getOrderButton(bookStatus, sortState),
        )
      ],
    );
  }

  Widget _buildBookTypeFilter(BookStatus bookStatus, BookFormat? bookFormat) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<BookFormat?>(
        isExpanded: true,
        buttonStyleData: ButtonStyleData(
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: dividerColor),
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
        ),
        items: [
          DropdownMenuItem<BookFormat?>(
            value: null,
            child: Text(
              _getBookTypeDropdownText(null),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...BookFormat.values.map(
            (item) => DropdownMenuItem<BookFormat>(
              value: item,
              child: Text(
                _getBookTypeDropdownText(item),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
        value: bookFormat,
        onChanged: (value) =>
            _getBlocProvider(bookStatus).add(ChangeBookTypeEvent(value)),
      ),
    );
  }

  Widget _buildOnlyBooksWithAllTags(
    BookStatus bookStatus,
    bool filterTagsAsAnd,
  ) {
    return StreamBuilder<List<String>>(
      stream: bookCubit.tags,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  Switch.adaptive(
                    value: filterTagsAsAnd,
                    onChanged: (value) => _getBlocProvider(bookStatus)
                        .add(ChangeFilterTagsAsAnd(value)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.only_books_with_all_tags.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const SizedBox();
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

  Widget _buildBooksExceptTags(BookStatus bookStatus, bool filterOutTags) {
    return StreamBuilder<List<String>>(
      stream: bookCubit.tags,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(cornerRadius),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  Switch.adaptive(
                    value: filterOutTags,
                    onChanged: (value) => _getBlocProvider(bookStatus).add(
                      ChangeFilterOutTags(value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      LocaleKeys.filter_out_selected_tags.tr(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
