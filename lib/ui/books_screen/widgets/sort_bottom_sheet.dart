import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/sort_cubit.dart';

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

String _getDropdownValue(SortType sortType) {
  switch (sortType) {
    case SortType.byAuthor:
      return sortOptions[1];
    case SortType.byRating:
      return sortOptions[2];
    case SortType.byPages:
      return sortOptions[3];
    case SortType.byStartDate:
      return sortOptions[4];
    case SortType.byFinishDate:
      return sortOptions[5];
    default:
      return sortOptions[0];
  }
}

void _updateSort(BuildContext context, String? value) {
  if (value == sortOptions[0]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byTitle);
  } else if (value == sortOptions[1]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byAuthor);
  } else if (value == sortOptions[2]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byRating);
  } else if (value == sortOptions[3]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byPages);
  } else if (value == sortOptions[4]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byStartDate);
  } else if (value == sortOptions[5]) {
    context.read<SortCubit>().updateSortMode(sortType: SortType.byFinishDate);
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
              const SizedBox(height: 5),
              BlocBuilder<SortCubit, SortState>(
                builder: (context, sortState) => Row(
                  children: [
                    CustomDropdownButton2(
                      hint: 'Select Item',
                      buttonHeight: 50,
                      dropdownItems: sortOptions,
                      value: _getDropdownValue(sortState.sortType),
                      buttonDecoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).secondaryTextColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (value) => _updateSort(context, value),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(context).secondaryTextColor,
                        ),
                      ),
                      child: (sortState.isAsc)
                          ? IconButton(
                              onPressed: () => context
                                  .read<SortCubit>()
                                  .updateSortOrder(false),
                              icon: const Icon(Icons.arrow_downward),
                            )
                          : IconButton(
                              onPressed: () => context
                                  .read<SortCubit>()
                                  .updateSortOrder(true),
                              icon: const Icon(Icons.arrow_upward),
                            ),
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
