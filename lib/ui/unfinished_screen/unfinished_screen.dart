import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class UnfinishedScreen extends StatelessWidget {
  const UnfinishedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bookCubit.getUnfinishedBooks();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.unfinished_books.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookCubit.unfinishedBooks,
        builder: (context, AsyncSnapshot<List<Book>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Text(
                    LocaleKeys.no_unfinished_books.tr(),
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
              listNumber: 6,
              allBooksCount: null,
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
