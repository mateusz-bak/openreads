import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksList extends StatefulWidget {
  const BooksList({
    super.key,
    required this.books,
    required this.listNumber,
    this.selectedBookIds,
    this.onBookSelected,
    this.allBooksCount,
  });

  final List<Book> books;
  final int listNumber;
  final Set<int>? selectedBookIds;
  final Function(int id)? onBookSelected;
  final int? allBooksCount;

  @override
  State<BooksList> createState() => _BooksListState();
}

class _BooksListState extends State<BooksList>
    with AutomaticKeepAliveClientMixin {
  onPressed(int index, bool multiSelectMode, String heroTag) {
    if (widget.books[index].id == null) return;
    if (multiSelectMode && widget.onBookSelected != null) {
      widget.onBookSelected!(widget.books[index].id!);
      return;
    }

    context.read<CurrentBookCubit>().setBook(widget.books[index]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(
          id: widget.books[index].id!,
          heroTag: heroTag,
        ),
      ),
    );
  }

  onLongPressed(int index) {
    if (widget.books[index].id == null) return;
    if (widget.onBookSelected != null) {
      widget.onBookSelected!(widget.books[index].id!);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var multiSelectMode = widget.selectedBookIds?.isNotEmpty ?? false;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
        ),
        SliverToBoxAdapter(
          child: widget.allBooksCount != null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.books.length} ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '(${widget.allBooksCount})',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ),
        SliverList.builder(
          itemCount: widget.books.length,
          itemBuilder: (context, index) {
            final heroTag =
                'tag_${widget.listNumber}_${widget.books[index].id}';
            Color? color = multiSelectMode &&
                    widget.selectedBookIds!.contains(widget.books[index].id)
                ? Theme.of(context).colorScheme.tertiaryContainer
                : Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withAlpha(50);
            return BookCard(
              book: widget.books[index],
              heroTag: heroTag,
              cardColor: color,
              addBottomPadding: (widget.books.length == index + 1),
              onPressed: () => onPressed(index, multiSelectMode, heroTag),
              onLongPressed: () => onLongPressed(index),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
