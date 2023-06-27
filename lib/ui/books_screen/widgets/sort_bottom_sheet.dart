import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({
    Key? key,
  }) : super(key: key);

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
];

String _getDropdownValue(SetSortState state) {
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
  } else {
    return sortOptions[0];
  }
}

Widget _getOrderButton(BuildContext context, SetSortState state) {
  return IconButton(
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
    ),
  );
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  Widget _getFavouriteSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch(
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
        ),
      ),
    );
  }

  Widget _getTagsSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch(
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
        ),
      ),
    );
  }

  Widget _getTagsAsAndSwitch(
    BuildContext context,
    SetSortState state,
  ) {
    return Switch(
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
      ),
    );
  }

  List<Widget> _buildYearChips(
    SetSortState state,
    List<int> dbYears,
    String? selectedYears,
  ) {
    final chips = List<Widget>.empty(growable: true);

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
      late bool selected;

      if (selectedYearsList.contains(dbYear.toString())) {
        selected = true;
      } else {
        selected = false;
      }

      chips.add(YearFilterChip(
        dbYear: dbYear,
        selected: selected,
        onYearChipPressed: (bool selected) {
          _onYearChipPressed(
            dbYear: dbYear,
            dbYears: uniqueDbYears,
            selected: selected,
            selectedYearsList: selectedYearsList,
            state: state,
          );
        },
      ));
    }
    return chips;
  }

  List<Widget> _buildTagChips(
    SetSortState state,
    List<String> dbTags,
    String? selectedTags,
  ) {
    final chips = List<Widget>.empty(growable: true);

    late List<String> selectedTagsList;

    if (selectedTags != null) {
      selectedTagsList = selectedTags.split('|||||');
    } else {
      selectedTagsList = List<String>.empty(growable: true);
    }

    for (var selectedTag in selectedTagsList) {
      if (!dbTags.contains(selectedTag)) {
        dbTags.add(selectedTag);
      }
    }

    for (var dbTag in dbTags) {
      late bool selected;

      if (selectedTagsList.contains(dbTag.toString())) {
        selected = true;
      } else {
        selected = false;
      }

      chips.add(TagFilterChip(
        tag: dbTag,
        selected: selected,
        onTagChipPressed: (bool selected) {
          _onTagChipPressed(
            dbTag: dbTag,
            selected: selected,
            selectedTagsList: selectedTagsList,
            state: state,
          );
        },
      ));
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 5),
        Container(
          height: 3,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text(
                LocaleKeys.sort_by.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
                builder: (context, state) {
                  if (state is SetSortState) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: dividerColor,
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                  borderRadius:
                                      BorderRadius.circular(cornerRadius),
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
                              value: _getDropdownValue(state),
                              onChanged: (value) => _updateSort(
                                context,
                                value,
                                state,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
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
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
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
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(cornerRadius),
                                border: Border.all(
                                  color: dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _getFavouriteSwitch(context, state),
                                  const SizedBox(width: 10),
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
              ),
              StreamBuilder<List<int>>(
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
                              const SizedBox(height: 10),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        borderRadius:
                                            BorderRadius.circular(cornerRadius),
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
              ),
              StreamBuilder<List<String>>(
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
                              const SizedBox(height: 10),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        borderRadius: BorderRadius.circular(
                                          cornerRadius,
                                        ),
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
              ),
              BlocBuilder<SortBloc, SortState>(
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
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
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
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(cornerRadius),
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
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
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
}
