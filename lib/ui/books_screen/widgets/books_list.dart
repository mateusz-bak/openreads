import 'package:flutter/material.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksList extends StatelessWidget {
  const BooksList({
    Key? key,
    required this.books,
  }) : super(key: key);

  final List<Book> books;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookCard(
          book: books[index],
          heroTag: "tag_$index",
          onPressed: () {
            if (books[index].id == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookScreen(
                        id: books[index].id!,
                        heroTag: "tag_$index",
                      )),
            );
          },
        );
      },
    );
  }
}
