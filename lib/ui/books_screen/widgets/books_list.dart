import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
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
  onPressed(int index, String heroTag) {
    final book = widget.books[index];
    if (book.id == null) return;

    if (context.read<SelectedBooksCubit>().state.isNotEmpty) {
      context.read<SelectedBooksCubit>().onBookPressed(book.id!);
      return;
    }

    context.read<CurrentBookCubit>().setBook(book);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(heroTag: heroTag),
      ),
    );
  }

  onLongPressed(int index) {
    final bookID = widget.books[index].id;
    if (bookID == null) return;

    context.read<SelectedBooksCubit>().onBookPressed(bookID);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
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

            return BookCard(
              book: widget.books[index],
              heroTag: heroTag,
              isLastItem: (widget.books.length == index + 1),
              onPressed: () => onPressed(index, heroTag),
              onLongPressed: () => onLongPressed(index),
              isSelectable: true,
            );
          },
        ),
      ],
    );
  }
}
