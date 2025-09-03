import 'dart:io';

import 'package:diacritic/diacritic.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({super.key});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

final List<String> sortOptions = [
  LocaleKeys.title.tr(),
  LocaleKeys.author.tr(),
  LocaleKeys.rating.tr(),
  LocaleKeys.pages_uppercase.tr(),
  LocaleKeys.start_date.tr(),
  LocaleKeys.finish_date.tr(),
  LocaleKeys.enter_publication_year.tr(),
  LocaleKeys.date_added.tr(),
  LocaleKeys.date_modified.tr(),
];

final List<String> bookTypeOptions = [
  LocaleKeys.book_format_all.tr(),
  LocaleKeys.book_format_paperback_plural.tr(),
  LocaleKeys.book_format_hardcover_plural.tr(),
  LocaleKeys.book_format_ebook_plural.tr(),
  LocaleKeys.book_format_audiobook_plural.tr(),
];

String _getSortDropdownValue(SetSortState state) {
  if (state.sortType == SortType.byAuthor) {
    return sortOptions[1];
  } else if (state.sortType == SortType.byRating) {
    return sortOptions[2];
  } else if (state.sortType == SortType.byPages) {
    return sortOptions[3];
  } else if (state.sortType == SortType.byStartDate) {
    return sortOptions[4];
  } else if (state.sortType == SortType.byFinishDate) {
    return sortOptions[5];
  } else if (state.sortType == SortType.byPublicationYear) {
    return sortOptions[6];
  } else if (state.sortType == SortType.byDateAdded) {
    return sortOptions[7];
  } else if (state.sortType == SortType.byDateModified) {
    return sortOptions[8];
  } else {
    return sortOptions[0];
  }
}

String _getBookTypeDropdownValue(SetSortState state) {
  if (state.bookType == BookFormat.paperback) {
    return bookTypeOptions[1];
  } else if (state.bookType == BookFormat.hardcover) {
    return bookTypeOptions[2];
  } else if (state.bookType == BookFormat.ebook) {
    return bookTypeOptions[3];
  } else if (state.bookType == BookFormat.audiobook) {
    return bookTypeOptions[4];
  } else {
    return bookTypeOptions[0];
  }
}

Widget _getOrderButton(BuildContext context, SetSortState state) {
  return SizedBox(
    height: 40,
    width: 40,
    child: IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          sortType: state.sortType,
          isAsc: !state.isAsc,
          onlyFavourite: state.onlyFavourite,
          years: state.years,
          tags: state.tags,
          displayTags: state.displayTags,
          filterTagsAsAnd: state.filterTagsAsAnd,
          bookType: state.bookType,
          filterOutTags: state.filterOutTags,
        ),
      ),
    ),
  );
}

void _updateSort(BuildContext context, String? value, SetSortState state) {
  late SortType sortType;

  if (value == sortOptions[1]) {
    sortType = SortType.byAuthor;
  } else if (value == sortOptions[2]) {
    sortType = SortType.byRating;
  } else if (value == sortOptions[3]) {
    sortType = SortType.byPages;
  } else if (value == sortOptions[4]) {
    sortType = SortType.byStartDate;
  } else if (value == sortOptions[5]) {
    sortType = SortType.byFinishDate;
  } else if (value == sortOptions[6]) {
    sortType = SortType.byPublicationYear;
  } else if (value == sortOptions[7]) {
    sortType = SortType.byDateAdded;
  } else if (value == sortOptions[8]) {
    sortType = SortType.byDateModified;
  } else {
    sortType = SortType.byTitle;
  }

  BlocProvider.of<SortBloc>(context).add(
    ChangeSortEvent(
      sortType: sortType,
      isAsc: state.isAsc,
      onlyFavourite: state.onlyFavourite,
      years: state.years,
      tags: state.tags,
      displayTags: state.displayTags,
      filterTagsAsAnd: state.filterTagsAsAnd,
      bookType: state.bookType,
      filterOutTags: state.filterOutTags,
    ),
  );
}

void _updateBookType(BuildContext context, String? value, SetSortState state) {
  BookFormat? bookType;

  if (value == bookTypeOptions[1]) {
    bookType = BookFormat.paperback;
  } else if (value == bookTypeOptions[2]) {
    bookType = BookFormat.hardcover;
  } else if (value == bookTypeOptions[3]) {
    bookType = BookFormat.ebook;
  } else if (value == bookTypeOptions[4]) {
    bookType = BookFormat.audiobook;
  } else {
    bookType = null;
  }

  BlocProvider.of<SortBloc>(context).add(
    ChangeSortEvent(
      sortType: state.sortType,
      isAsc: state.isAsc,
      onlyFavourite: state.onlyFavourite,
      years: state.years,
      tags: state.tags,
      displayTags: state.displayTags,
      filterTagsAsAnd: state.filterTagsAsAnd,
      bookType: bookType,
      filterOutTags: state.filterOutTags,
    ),
  );
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  Widget _getFavouriteSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return SizedBox(
      height: 40,
      child: Switch.adaptive(
        value: state.onlyFavourite,
        onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
          ChangeSortEvent(
            sortType: state.sortType,
            isAsc: state.isAsc,
            onlyFavourite: value,
            years: state.years,
            tags: state.tags,
            displayTags: state.displayTags,
            filterTagsAsAnd: state.filterTagsAsAnd,
            bookType: state.bookType,
            filterOutTags: state.filterOutTags,
          ),
        ),
      ),
    );
  }

  Widget _getTagsSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch.adaptive(
      value: state.displayTags,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          sortType: state.sortType,
          isAsc: state.isAsc,
          onlyFavourite: state.onlyFavourite,
          years: state.years,
          tags: state.tags,
          displayTags: value,
          filterTagsAsAnd: state.filterTagsAsAnd,
          bookType: state.bookType,
          filterOutTags: state.filterOutTags,
        ),
      ),
    );
  }

  Widget _getTagsAsAndSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch.adaptive(
      value: state.filterTagsAsAnd,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          sortType: state.sortType,
          isAsc: state.isAsc,
          onlyFavourite: state.onlyFavourite,
          years: state.years,
          tags: state.tags,
          displayTags: state.displayTags,
          filterTagsAsAnd: value,
          bookType: state.bookType,
          filterOutTags: false,
        ),
      ),
    );
  }

  Widget _getFilterOutTagsSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch.adaptive(
      value: state.filterOutTags,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          sortType: state.sortType,
          isAsc: state.isAsc,
          onlyFavourite: state.onlyFavourite,
          years: state.years,
          tags: state.tags,
          displayTags: state.displayTags,
          filterTagsAsAnd: false,
          bookType: state.bookType,
          filterOutTags: value,
        ),
      ),
    );
  }

  _onYearChipPressed({
    required bool selected,
    required List<String> selectedYearsList,
    required List<int> dbYears,
    required int dbYear,
    required SetSortState state,
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

    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(
        sortType: state.sortType,
        isAsc: state.isAsc,
        onlyFavourite: state.onlyFavourite,
        years: (selectedYearsList.isEmpty)
            ? null
            : selectedYearsList.join('|||||'),
        tags: state.tags,
        displayTags: state.displayTags,
        filterTagsAsAnd: state.filterTagsAsAnd,
        bookType: state.bookType,
        filterOutTags: state.filterOutTags,
      ),
    );
  }

  _onTagChipPressed({
    required bool selected,
    required List<String> selectedTagsList,
    required String dbTag,
    required SetSortState state,
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

    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(
        sortType: state.sortType,
        isAsc: state.isAsc,
        onlyFavourite: state.onlyFavourite,
        years: state.years,
        tags:
            (selectedTagsList.isEmpty) ? null : selectedTagsList.join('|||||'),
        displayTags: state.displayTags,
        filterTagsAsAnd: state.filterTagsAsAnd,
        bookType: state.bookType,
        filterOutTags: state.filterOutTags,
      ),
    );
  }

  List<Widget> _buildYearChips(
    SetSortState state,
    List<int> dbYears,
    String? selectedYears,
  ) {
    final chips = List<Widget>.empty(growable: true);
    final inactiveChips = List<Widget>.empty(growable: true);

    late List<String> selectedYearsList;

    final uniqueDbYears = List<int>.empty(growable: true);

    for (var dbYear in dbYears) {
      if (!uniqueDbYears.contains(dbYear)) {
        uniqueDbYears.add(dbYear);
      }
    }

    if (selectedYears != null) {
      selectedYearsList = selectedYears.split('|||||');
    } else {
      selectedYearsList = List<String>.empty(growable: true);
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
        onYearChipPressed: (bool selected) {
          _onYearChipPressed(
            dbYear: dbYear,
            dbYears: uniqueDbYears,
            selected: selected,
            selectedYearsList: selectedYearsList,
            state: state,
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

    // Last chip is to select all/none years
    chips.add(
      YearFilterChip(
        dbYear: null,
        selected: selectedYears == dbYears.join('|||||'),
        onYearChipPressed: (bool selected) {
          BlocProvider.of<SortBloc>(context).add(
            ChangeSortEvent(
              sortType: state.sortType,
              isAsc: state.isAsc,
              onlyFavourite: state.onlyFavourite,
              years: selectedYears == dbYears.join('|||||')
                  ? null
                  : dbYears.join('|||||'),
              tags: state.tags,
              displayTags: state.displayTags,
              filterTagsAsAnd: state.filterTagsAsAnd,
              bookType: state.bookType,
              filterOutTags: state.filterOutTags,
            ),
          );
        },
      ),
    );

    return chips;
  }

  List<Widget> _buildTagChips(
    SetSortState state,
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
            dbTag: dbTag,
            selected: selected,
            selectedTagsList: selectedTagsList,
            state: state,
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
        onTagChipPressed: (bool selected) {
          BlocProvider.of<SortBloc>(context).add(
            ChangeSortEvent(
              sortType: state.sortType,
              isAsc: state.isAsc,
              onlyFavourite: state.onlyFavourite,
              years: state.years,
              tags: selectedTags == dbTags.join('|||||')
                  ? null
                  : dbTags.join('|||||'),
              displayTags: state.displayTags,
              filterTagsAsAnd: state.filterTagsAsAnd,
              bookType: state.bookType,
              filterOutTags: state.filterOutTags,
            ),
          );
        },
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    LocaleKeys.sort_by.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildSortDropdown(),
                  const SizedBox(height: 5),
                  _buildOnlyFavouriteSwitch(),
                  const SizedBox(height: 5),
                  Text(
                    LocaleKeys.filter_by_book_format.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildBookTypeFilter(),
                  _buildFilterByFinishYears(),
                  _buildFilterByTags(),
                  _buildFilterTagsAsAnd(),
                  _buildFilterOutTags(),
                  const SizedBox(height: 5),
                  _buildDisplayTags(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<SortBloc, SortState> _buildDisplayTags() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<SortBloc>(context).add(
                      ChangeSortEvent(
                        sortType: state.sortType,
                        isAsc: state.isAsc,
                        onlyFavourite: state.onlyFavourite,
                        years: state.years,
                        tags: state.tags,
                        displayTags: !state.displayTags,
                        filterTagsAsAnd: state.filterTagsAsAnd,
                        bookType: state.bookType,
                        filterOutTags: state.filterOutTags,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: Border.all(
                        color: dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        _getTagsSwitch(context, state),
                        const SizedBox(width: 10),
                        Text(
                          LocaleKeys.display_tags.tr(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  BlocBuilder<SortBloc, SortState> _buildFilterOutTags() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<SortBloc>(context).add(
                      ChangeSortEvent(
                        sortType: state.sortType,
                        isAsc: state.isAsc,
                        onlyFavourite: state.onlyFavourite,
                        years: state.years,
                        tags: state.tags,
                        displayTags: state.displayTags,
                        filterTagsAsAnd: false,
                        bookType: state.bookType,
                        filterOutTags: !state.filterOutTags,
                      ),
                    );
                  },
                  child: _buildBooksExceptTags(context, state),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  BlocBuilder<SortBloc, SortState> _buildFilterTagsAsAnd() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<SortBloc>(context).add(
                      ChangeSortEvent(
                        sortType: state.sortType,
                        isAsc: state.isAsc,
                        onlyFavourite: state.onlyFavourite,
                        years: state.years,
                        tags: state.tags,
                        displayTags: state.displayTags,
                        filterTagsAsAnd: !state.filterTagsAsAnd,
                        bookType: state.bookType,
                        filterOutTags: state.filterOutTags,
                      ),
                    );
                  },
                  child: _buildOnlyBooksWithAllTags(context, state),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<String>> _buildFilterByTags() {
    return StreamBuilder<List<String>>(
      stream: bookCubit.tags,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          return BlocBuilder<SortBloc, SortState>(
            builder: (context, state) {
              if (state is SetSortState) {
                if (snapshot.data!.isEmpty && state.tags == null) {
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
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                cornerRadius,
                              ),
                              border: Border.all(
                                color: dividerColor,
                              ),
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
                                    state,
                                    snapshot.data!,
                                    state.tags,
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
              } else {
                return const SizedBox();
              }
            },
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

  StreamBuilder<List<int>> _buildFilterByFinishYears() {
    return StreamBuilder<List<int>>(
      stream: bookCubit.finishedYears,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          return BlocBuilder<SortBloc, SortState>(
            builder: (context, state) {
              if (state is SetSortState) {
                if (snapshot.data!.isEmpty && state.years == null) {
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
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                cornerRadius,
                              ),
                              border: Border.all(
                                color: dividerColor,
                              ),
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
                                    state,
                                    snapshot.data!,
                                    state.years,
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
              } else {
                return const SizedBox();
              }
            },
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

  BlocBuilder<SortBloc, SortState> _buildOnlyFavouriteSwitch() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    BlocProvider.of<SortBloc>(context).add(
                      ChangeSortEvent(
                        sortType: state.sortType,
                        isAsc: state.isAsc,
                        onlyFavourite: !state.onlyFavourite,
                        years: state.years,
                        tags: state.tags,
                        displayTags: state.displayTags,
                        filterTagsAsAnd: state.filterTagsAsAnd,
                        bookType: state.bookType,
                        filterOutTags: state.filterOutTags,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: Border.all(
                        color: dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        _getFavouriteSwitch(context, state),
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
        } else {
          return const SizedBox();
        }
      },
    );
  }

  BlocBuilder<SortBloc, SortState> _buildSortDropdown() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    isExpanded: true,
                    buttonStyleData: ButtonStyleData(
                      height: 42,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: dividerColor,
                        ),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(cornerRadius),
                      ),
                    ),
                    items: sortOptions
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: _getSortDropdownValue(state),
                    onChanged: (value) => _updateSort(
                      context,
                      value,
                      state,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(cornerRadius),
                  border: Border.all(
                    color: dividerColor,
                  ),
                ),
                child: _getOrderButton(context, state),
              )
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildBookTypeFilter() {
    return BlocBuilder<SortBloc, SortState>(
      builder: (context, state) {
        if (state is SetSortState) {
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              buttonStyleData: ButtonStyleData(
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: dividerColor,
                  ),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
              items: bookTypeOptions
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              value: _getBookTypeDropdownValue(state),
              onChanged: (value) => _updateBookType(
                context,
                value,
                state,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildOnlyBooksWithAllTags(BuildContext context, SetSortState state) {
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
                  _getTagsAsAndSwitch(context, state),
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

  Widget _buildBooksExceptTags(BuildContext context, SetSortState state) {
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
                  _getFilterOutTagsSwitch(context, state),
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
