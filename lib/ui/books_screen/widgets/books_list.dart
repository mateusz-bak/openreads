import 'package:flutter/material.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksList extends StatefulWidget {
  const BooksList({
    Key? key,
    required this.books,
    required this.listNumber,
    this.multiSelectMode =false,
    this.selectedBookIds,
    this.onBookSelected,
  }) : super(key: key);

  final List<Book> books;
  final int listNumber;
  final bool multiSelectMode;
  final Set<int>? selectedBookIds;
  final Function(int id)? onBookSelected;


  @override
  State<BooksList> createState() => _BooksListState();
}

class _BooksListState extends State<BooksList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final heroTag = 'tag_${widget.listNumber}_${widget.books[index].id}';
        Color? color = widget.multiSelectMode && widget.selectedBookIds!.contains(widget.books[index].id) ? Theme.of(context).colorScheme.secondaryContainer : null;
        return BookCard(
          book: widget.books[index],
          heroTag: heroTag,
          cardColor: color,
          addBottomPadding: (widget.books.length == index + 1),
          onPressed: () {
            if (widget.books[index].id == null) return;
            if (widget.multiSelectMode &&  widget.onBookSelected != null) {
              widget.onBookSelected!(widget.books[index].id!);
              return;
            }
            bookCubit.clearCurrentBook();
            bookCubit.getBook(widget.books[index].id!);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookScreen(
                  id: widget.books[index].id!,
                  heroTag: heroTag,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
