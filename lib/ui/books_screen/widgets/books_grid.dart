import 'package:flutter/material.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksGrid extends StatefulWidget {
  const BooksGrid({
    Key? key,
    required this.books,
    required this.listNumber,
  }) : super(key: key);

  final List<Book> books;
  final int listNumber;

  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1 / 1.5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final heroTag = 'tag_${widget.listNumber}_${widget.books[index].id}';

        return BookGridCard(
          book: widget.books[index],
          heroTag: heroTag,
          addBottomPadding: (widget.books.length == index + 1),
          onPressed: () {
            if (widget.books[index].id == null) return;
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
