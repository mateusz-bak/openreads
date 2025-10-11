import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';

class NumberOfBooks extends StatelessWidget {
  const NumberOfBooks({
    super.key,
    required this.filteredBooksCount,
    required this.allBooksCount,
  });

  final int filteredBooksCount;
  final int allBooksCount;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<DisplayCubit, DisplayState>(builder: (context, state) {
        if (state.showNumberOfBooks == false) return const SizedBox(height: 20);

        return Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$filteredBooksCount ',
                style: const TextStyle(fontSize: 12),
              ),
              filteredBooksCount != allBooksCount
                  ? Text(
                      '($allBooksCount)',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(200),
                        fontSize: 12,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        );
      }),
    );
  }
}
