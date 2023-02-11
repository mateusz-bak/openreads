import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(() {
      bookCubit.getSearchBooks(_searchController.text);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.search_in_books,
          style: TextStyle(
            fontSize: 18,
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: BookTextField(
              controller: _searchController,
              keyboardType: TextInputType.name,
              maxLength: 99,
              autofocus: true,
              textInputAction: TextInputAction.search,
              textCapitalization: TextCapitalization.words,
              onSubmitted: (text) {
                log(text);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: StreamBuilder<List<Book>>(
                stream: bookCubit.searchBooks,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final heroTag = 'tag_$index';

                        return BookCard(
                          book: snapshot.data![index],
                          heroTag: heroTag,
                          addBottomPadding:
                              (snapshot.data!.length == index + 1),
                          onPressed: () {
                            if (snapshot.data![index].id == null) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookScreen(
                                  id: snapshot.data![index].id!,
                                  heroTag: heroTag,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
