import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bookCubit.getDeletedBooks();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.deleted_books,
          style: TextStyle(
            fontSize: 18,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
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
                    AppLocalizations.of(context)!.no_deleted_books,
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
              listNumber: 5,
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
