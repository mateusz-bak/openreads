import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SimiliarBooksScreen extends StatefulWidget {
  const SimiliarBooksScreen({
    super.key,
    this.tag,
  });

  final String? tag;

  @override
  State<SimiliarBooksScreen> createState() => _SimiliarBooksScreenState();
}

class _SimiliarBooksScreenState extends State<SimiliarBooksScreen> {
  @override
  void initState() {
    if (widget.tag != null) {
      bookCubit.getBooksWithTag(widget.tag!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '${LocaleKeys.books_with_tag.tr()} ',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              widget.tag.toString(),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return StreamBuilder(
                stream: bookCubit.booksWithTag,
                builder: (context, AsyncSnapshot<List<Book>?> snapshot) {
                  if (snapshot.hasData) {
                    return BooksList(
                      books: snapshot.data!,
                      listNumber: 0,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      snapshot.error.toString(),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          }),
    );
  }
}
