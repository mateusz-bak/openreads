import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';

class SortBottomSheet extends StatefulWidget {
  const SortBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

List<String> sortOptions = [
  'Title',
  'Author',
  'Rating',
  'Pages',
  'Start date',
  'Finish date',
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
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          sortType: state.sortType,
          isAsc: state.isAsc,
          onlyFavourite: value,
          years: state.years,
        ),
      ),
    );
  }

  List<Widget> _buildChips(
    SetSortState state,
    List<int>? dbYears,
    String? selectedYears,
  ) {
    if (dbYears == null || dbYears.isEmpty) return [];

    final chips = List<Widget>.empty(growable: true);
    late List<String> selectedYearsList;

    if (selectedYears == null) {
      selectedYearsList = List<String>.empty(growable: true);
    } else {
      selectedYears = selectedYears.replaceFirst('[', '').replaceFirst(']', '');

      if (selectedYears.isNotEmpty && selectedYears[0] == ',') {
        selectedYears = selectedYears.replaceFirst(',', '');
      }

      selectedYears = selectedYears.replaceAll(' ', '');
      selectedYearsList = selectedYears.split(',');

      if (selectedYearsList.isNotEmpty && selectedYearsList[0] == ',') {
        selectedYearsList.removeAt(0);
      }
    }

    for (var dbYear in dbYears) {
      late bool selected;

      if (selectedYearsList.contains(dbYear.toString())) {
        selected = true;
      } else {
        selected = false;
      }

      chips.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: FilterChip(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          side: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          label: Text(
            dbYear.toString(),
          ),
          selected: selected,
          selectedColor: Theme.of(context).primaryColor,
          onSelected: (bool selected) {
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
                    : selectedYearsList.toString(),
              ),
            );
          },
        ),
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
        Container(
          height: 3,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Text(
                'Sort books',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
                builder: (context, state) {
                  if (state is SetSortState) {
                    return Row(
                      children: [
                        Expanded(
                          child: CustomDropdownButton2(
                            hint: 'Select Item',
                            buttonHeight: 50,
                            dropdownItems: sortOptions,
                            value: _getDropdownValue(state),
                            buttonDecoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (value) => _updateSort(
                              context,
                              value,
                              state,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
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
              const SizedBox(height: 20),
              const Text(
                'Filter books',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _getFavouriteSwitch(context, state),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Only favourite',
                                    style: TextStyle(fontSize: 16),
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
              const SizedBox(height: 10),
              const Text(
                'Finish years',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              StreamBuilder<List<int>>(
                stream: bookCubit.finishedYears,
                builder: (context, AsyncSnapshot<List<int>> snapshot) {
                  if (snapshot.hasData) {
                    return BlocBuilder<SortBloc, SortState>(
                      builder: (context, state) {
                        if (state is SetSortState) {
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).backgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
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
                                        children: _buildChips(
                                          state,
                                          snapshot.data,
                                          state.years,
                                        ),
                                      ),
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
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
}
