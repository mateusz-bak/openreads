import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';

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

String _getDropdownValue(SortState state) {
  if (state is AuthorAscSortState || state is AuthorDescSortState) {
    return sortOptions[1];
  } else if (state is RatingAscSortState || state is RatingDescSortState) {
    return sortOptions[2];
  } else if (state is PagesAscSortState || state is PagesDescSortState) {
    return sortOptions[3];
  } else if (state is StartDateAscSortState ||
      state is StartDateDescSortState) {
    return sortOptions[4];
  } else if (state is FinishDateAscSortState ||
      state is FinishDateDescSortState) {
    return sortOptions[5];
  } else {
    return sortOptions[0];
  }
}

Widget _getOrderButton(BuildContext context, SortState state) {
  if (state is TitleDescSortState ||
      state is AuthorDescSortState ||
      state is RatingDescSortState ||
      state is PagesDescSortState ||
      state is StartDateDescSortState ||
      state is FinishDateDescSortState) {
    return IconButton(
      icon: const Icon(Icons.arrow_downward),
      onPressed: () {
        if (state is TitleDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byTitle, true),
          );
        } else if (state is AuthorDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byAuthor, true),
          );
        } else if (state is RatingDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byRating, true),
          );
        } else if (state is PagesDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byPages, true),
          );
        } else if (state is StartDateDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byStartDate, true),
          );
        } else if (state is FinishDateDescSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byFinishDate, true),
          );
        }
      },
    );
  } else {
    return IconButton(
      icon: const Icon(Icons.arrow_upward),
      onPressed: () {
        if (state is TitleAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byTitle, false),
          );
        } else if (state is AuthorAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byAuthor, false),
          );
        } else if (state is RatingAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byRating, false),
          );
        } else if (state is PagesAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byPages, false),
          );
        } else if (state is StartDateAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byStartDate, false),
          );
        } else if (state is FinishDateAscSortState) {
          BlocProvider.of<SortBloc>(context).add(
            const ChangeSortEvent(SortType.byFinishDate, false),
          );
        }
      },
    );
  }
}

void _updateSort(BuildContext context, String? value, SortState state) {
  if (value == sortOptions[0]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byTitle, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byTitle, true),
      );
    }
  } else if (value == sortOptions[1]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byAuthor, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byAuthor, true),
      );
    }
  } else if (value == sortOptions[2]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byRating, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byRating, true),
      );
    }
  } else if (value == sortOptions[3]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byPages, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byPages, true),
      );
    }
  } else if (value == sortOptions[4]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byStartDate, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byStartDate, true),
      );
    }
  } else if (value == sortOptions[5]) {
    if (state is TitleDescSortState ||
        state is AuthorDescSortState ||
        state is RatingDescSortState ||
        state is PagesDescSortState ||
        state is StartDateDescSortState ||
        state is FinishDateDescSortState) {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byFinishDate, false),
      );
    } else {
      BlocProvider.of<SortBloc>(context).add(
        const ChangeSortEvent(SortType.byFinishDate, true),
      );
    }
  }
}

class _SortBottomSheetState extends State<SortBottomSheet> {
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
                'Sort finished books',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
                builder: (context, state) => Row(
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
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }
}
