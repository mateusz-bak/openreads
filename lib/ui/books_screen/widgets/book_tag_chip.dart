import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/books_tab_index_cubit.dart';

class BooksTabChip extends StatefulWidget {
  const BooksTabChip({
    super.key,
    required this.index,
    required this.tabController,
    required this.title,
  });

  final int index;
  final TabController tabController;
  final String title;

  @override
  State<BooksTabChip> createState() => _BookTabChipState();
}

class _BookTabChipState extends State<BooksTabChip> {
  _scrollToChip(int index, BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      // Scrolls the chip into view when the tab changes
      if (widget.index == widget.tabController.index) {
        _scrollToChip(widget.index, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: BlocBuilder<BooksTabIndexCubit, int>(
        builder: (context, tabIndex) {
          final isSelected = tabIndex == widget.index;

          return FilterChip(
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            selected: isSelected,
            label: Text(
              widget.title,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : null,
              ),
            ),
            showCheckmark: false,
            onSelected: (bool _) {
              _scrollToChip(widget.index, context);
              BlocProvider.of<BooksTabIndexCubit>(context)
                  .setTabIndex(widget.index);
              widget.tabController.index = widget.index;
            },
          );
        },
      ),
    );
  }
}
