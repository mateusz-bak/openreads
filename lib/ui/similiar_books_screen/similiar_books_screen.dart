import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
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
                ? const SizedBox()
                : widget.author != null
                    ? Text(
                        '${LocaleKeys.author.tr()}: ',
                        style: const TextStyle(fontSize: 18),
                      )
                    : const SizedBox(),
            widget.tag != null
                ? _buildTag(widget.tag!)
                : widget.author != null
                    ? Text(
                        widget.author!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    : const SizedBox(),
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

  Widget _buildTag(String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(
          color: dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          overflow: TextOverflow.fade,
          softWrap: true,
          maxLines: 5,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        clipBehavior: Clip.none,
        onSelected: (_) {},
      ),
    );
  }
}
