import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SimiliarBooksScreen extends StatefulWidget {
  const SimiliarBooksScreen({
    super.key,
    this.tag,
    this.author,
  });

  final String? tag;
  final String? author;

  @override
  State<SimiliarBooksScreen> createState() => _SimiliarBooksScreenState();
}

class _SimiliarBooksScreenState extends State<SimiliarBooksScreen> {
  @override
  void initState() {
    if (widget.tag != null) {
      bookCubit.getBooksWithSameTag(widget.tag!);
    } else if (widget.author != null) {
      bookCubit.getBooksWithSameAuthor(widget.author!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.tag != null
                ? Text(
                    '${LocaleKeys.tags.plural(1).capitalize.tr()}: ',
                    style: const TextStyle(fontSize: 18),
                  )
                : widget.author != null
                    ? Text(
                        '${LocaleKeys.author.tr()}: ',
                        style: const TextStyle(fontSize: 18),
                      )
                    : const SizedBox(),
            Text(
              widget.tag != null
                  ? widget.tag!
                  : widget.author != null
                      ? widget.author!
                      : '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: widget.tag != null
              ? bookCubit.booksWithSameTag
              : bookCubit.booksWithSameAuthor,
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
          }),
    );
  }
}
