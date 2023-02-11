import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
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
        title: Text(
          l10n.unfinished_books,
          style: TextStyle(
            fontSize: 18,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
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
                    l10n.no_unfinished_books,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 16,
                      fontFamily: context.read<ThemeBloc>().fontFamily,
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
            return Text(
              snapshot.error.toString(),
              style: TextStyle(
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
