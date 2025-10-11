import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksGrid extends StatefulWidget {
  const BooksGrid({
    super.key,
    required this.books,
    required this.listNumber,
    required this.allBooksCount,
    required this.gridType,
    required this.gridSize,
    required this.titleOverCover,
  });

  final List<Book> books;
  final int listNumber;
  final int allBooksCount;
  final DisplayType gridType;
  final int gridSize;
  final bool titleOverCover;

  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid>
    with AutomaticKeepAliveClientMixin {
  _onPressed(int index, bool multiSelectMode, String heroTag) {
    if (widget.books[index].id == null) return;

    if (multiSelectMode) {
      context.read<SelectedBooksCubit>().onBookPressed(widget.books[index].id!);
      return;
    }

    context.read<CurrentBookCubit>().setBook(widget.books[index]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(heroTag: heroTag),
      ),
    );
  }

  onLongPressed(int index) {
    if (widget.books[index].id == null) return;

    context.read<SelectedBooksCubit>().onBookPressed(widget.books[index].id!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        NumberOfBooks(
          filteredBooksCount: widget.books.length,
          allBooksCount: widget.allBooksCount,
        ),
        BlocBuilder<SelectedBooksCubit, List<int>>(builder: (context, list) {
          return _buildGrid(list: list);
        }),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildGrid({
    required List<int> list,
  }) {
    bool multiSelectMode = list.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.gridSize,
          childAspectRatio: widget.gridType == DisplayType.detailedGrid &&
                  !widget.titleOverCover
              ? 1 / 1.7
              : 1 / 1.5,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final heroTag = 'tag_${widget.listNumber}_${widget.books[index].id}';
          Color borderColor =
              multiSelectMode && list.contains(widget.books[index].id)
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.transparent;
          final double borderWidth =
              multiSelectMode && list.contains(widget.books[index].id)
                  ? 3.0
                  : 0.0;

          return Container(
              decoration: multiSelectMode
                  ? BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCard(index, heroTag, multiSelectMode),
                  _buildMultiSelectOverlay(
                    multiSelectMode,
                    list,
                    index,
                    heroTag,
                  ),
                ],
              ));
        },
      ),
    );
  }

  Widget _buildMultiSelectOverlay(
    bool multiSelectMode,
    List<int> list,
    int index,
    String heroTag,
  ) {
    if (!multiSelectMode || !list.contains(widget.books[index].id)) {
      return const SizedBox();
    }

    return InkWell(
      onTap: () => _onPressed(
        index,
        multiSelectMode,
        heroTag,
      ),
      onLongPress: () => onLongPressed(index),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index, String heroTag, bool multiSelectMode) {
    return BlocBuilder<DisplayCubit, DisplayState>(
      builder: (context, state) {
        if (state.type == DisplayType.detailedGrid) {
          return BookCardGridDetailed(
            book: widget.books[index],
            heroTag: heroTag,
            addBottomPadding: (widget.books.length == index + 1),
            onPressed: () => _onPressed(
              index,
              multiSelectMode,
              heroTag,
            ),
            onLongPressed: () => onLongPressed(index),
          );
        } else {
          return BookCardGrid(
            book: widget.books[index],
            heroTag: heroTag,
            addBottomPadding: (widget.books.length == index + 1),
            onPressed: () => _onPressed(
              index,
              multiSelectMode,
              heroTag,
            ),
            onLongPressed: () => onLongPressed(index),
          );
        }
      },
    );
  }
}
