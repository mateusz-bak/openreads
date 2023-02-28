import 'package:flutter/material.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bookCubit.getDeletedBooks();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.deleted_books,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookCubit.deletedBooks,
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Text(
                    l10n.no_deleted_books,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            return BooksList(
              books: snapshot.data!,
              listNumber: 5,
            );
          } else if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
