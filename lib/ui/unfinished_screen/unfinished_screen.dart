import 'package:flutter/material.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class UnfinishedScreen extends StatelessWidget {
  const UnfinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bookCubit.getUnfinishedBooks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unfinished Books'),
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookCubit.unfinishedBooks,
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Text(
                    'You don\'t have any unfinished books',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }
            return BooksList(
              books: snapshot.data!,
              listNumber: 6,
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
