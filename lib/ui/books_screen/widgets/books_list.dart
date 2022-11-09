import 'package:flutter/material.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksList extends StatefulWidget {
  const BooksList({
    Key? key,
    required this.books,
  }) : super(key: key);

  final List<Book> books;

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
        return BookCard(
          book: widget.books[index],
          heroTag: "tag_$index",
          addBottomPadding: (widget.books.length == index + 1),
          onPressed: () {
            if (widget.books[index].id == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookScreen(
                  id: widget.books[index].id!,
                  heroTag: "tag_$index",
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
