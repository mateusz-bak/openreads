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
  if (state is AuthorSortState) {
    return sortOptions[1];
  } else if (state is RatingSortState) {
    return sortOptions[2];
  } else if (state is PagesSortState) {
    return sortOptions[3];
  } else if (state is StartDateSortState) {
    return sortOptions[4];
  } else if (state is FinishDateSortState) {
    return sortOptions[5];
  } else {
    return sortOptions[0];
  }
}

Widget _getOrderButton(BuildContext context, SortState state) {
  if (state is TitleSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byTitle,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else if (state is AuthorSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byAuthor,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else if (state is RatingSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byRating,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else if (state is PagesSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byPages,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else if (state is StartDateSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byStartDate,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else if (state is FinishDateSortState) {
    return IconButton(
      icon: (state.isAsc)
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.arrow_downward),
      onPressed: () => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byFinishDate,
          !state.isAsc,
          state.onlyFavourite,
        ),
      ),
    );
  } else {
    return const SizedBox();
  }
}

Widget _getFavouriteSwitch(BuildContext context, SortState state) {
  if (state is TitleSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byTitle,
          state.isAsc,
          value,
        ),
      ),
    );
  } else if (state is AuthorSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byAuthor,
          state.isAsc,
          value,
        ),
      ),
    );
  } else if (state is RatingSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byRating,
          state.isAsc,
          value,
        ),
      ),
    );
  } else if (state is PagesSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byPages,
          state.isAsc,
          value,
        ),
      ),
    );
  } else if (state is StartDateSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byStartDate,
          state.isAsc,
          value,
        ),
      ),
    );
  } else if (state is FinishDateSortState) {
    return Switch(
      value: state.onlyFavourite,
      activeColor: Theme.of(context).primaryColor,
      onChanged: (value) => BlocProvider.of<SortBloc>(context).add(
        ChangeSortEvent(
          SortType.byFinishDate,
          state.isAsc,
          value,
        ),
      ),
    );
  } else {
    return const SizedBox();
  }
}

void _updateSort(BuildContext context, String? value, SortState state) {
  bool? isAsc;
  bool? onlyFavourite;

  if (state is TitleSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  } else if (state is AuthorSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  } else if (state is RatingSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  } else if (state is PagesSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  } else if (state is StartDateSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  } else if (state is FinishDateSortState) {
    isAsc = state.isAsc;
    onlyFavourite = state.onlyFavourite;
  }

  if (isAsc == null) return;
  if (onlyFavourite == null) return;

  if (value == sortOptions[0]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byTitle, isAsc, onlyFavourite),
    );
  } else if (value == sortOptions[1]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byAuthor, isAsc, onlyFavourite),
    );
  } else if (value == sortOptions[2]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byRating, isAsc, onlyFavourite),
    );
  } else if (value == sortOptions[3]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byPages, isAsc, onlyFavourite),
    );
  } else if (value == sortOptions[4]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byStartDate, isAsc, onlyFavourite),
    );
  } else if (value == sortOptions[5]) {
    BlocProvider.of<SortBloc>(context).add(
      ChangeSortEvent(SortType.byFinishDate, isAsc, onlyFavourite),
    );
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
                'Sort books',
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
              const SizedBox(height: 20),
              const Text(
                'Filter books',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<SortBloc, SortState>(
                builder: (context, state) => Row(
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
