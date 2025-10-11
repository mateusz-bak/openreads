import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksList extends StatefulWidget {
  const BooksList({
    super.key,
    required this.books,
    required this.listNumber,
    this.allBooksCount,
  });

  final List<Book> books;
  final int listNumber;
  final int? allBooksCount;

  @override
  State<BooksList> createState() => _BooksListState();
}

class _BooksListState extends State<BooksList>
    with AutomaticKeepAliveClientMixin {
  onPressed(int index, bool multiSelectMode, String heroTag) {
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
        widget.allBooksCount != null
            ? NumberOfBooks(
                filteredBooksCount: widget.books.length,
                allBooksCount: widget.allBooksCount!,
              )
            : const SliverToBoxAdapter(),
        BlocBuilder<SelectedBooksCubit, List<int>>(builder: (context, list) {
          return _buildList(list: list);
        }),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildList({
    required List<int> list,
  }) {
    bool multiSelectMode = list.isNotEmpty;

    const unselectedCardColor = null;
    final selectedCardColor = Theme.of(context).colorScheme.secondaryContainer;

    return SliverList.builder(
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final heroTag = 'tag_${widget.listNumber}_${widget.books[index].id}';
        Color? color = multiSelectMode && list.contains(widget.books[index].id)
            ? selectedCardColor
            : unselectedCardColor;
        return BlocBuilder<DisplayCubit, DisplayState>(
          builder: (context, state) {
            if (state.type == DisplayType.compactList) {
              return BookCardListCompact(
                book: widget.books[index],
                heroTag: heroTag,
                cardColor: color,
                addBottomPadding: (widget.books.length == index + 1),
                onPressed: () => onPressed(index, multiSelectMode, heroTag),
                onLongPressed: () => onLongPressed(index),
              );
            } else if (state.type == DisplayType.list) {
              return BookCardList(
                book: widget.books[index],
                heroTag: heroTag,
                cardColor: color,
                addBottomPadding: (widget.books.length == index + 1),
                onPressed: () => onPressed(index, multiSelectMode, heroTag),
                onLongPressed: () => onLongPressed(index),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
