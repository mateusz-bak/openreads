import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class SimiliarBooksScreen extends StatefulWidget {
  const SimiliarBooksScreen({
    super.key,
    this.tag,
    this.author,
    this.publisher,
  });

  final String? tag;
  final String? author;
  final String? publisher;

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
    } else if (widget.publisher != null) {
      bookCubit.getBooksWithSamePublisher(widget.publisher!);
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
                    : widget.publisher != null
                        ? Text(
                            '${LocaleKeys.publisher.tr()}: ',
                            style: const TextStyle(fontSize: 18),
                          )
                        : const SizedBox(),
            widget.tag != null
                ? _buildTag(widget.tag!)
                : widget.author != null
                    ? Flexible(
                        child: Text(
                          widget.author!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : widget.publisher != null
                        ? Flexible(
                            child: Text(
                              widget.publisher!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox(),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: widget.tag != null
              ? bookCubit.booksWithSameTag
              : widget.author != null
                  ? bookCubit.booksWithSameAuthor
                  : bookCubit.booksWithSamePublisher,
          builder: (context, AsyncSnapshot<List<Book>?> snapshot) {
            if (snapshot.hasData) {
              return BlocBuilder<DisplayCubit, DisplayState>(
                builder: (context, displayState) {
                  if (displayState.type == DisplayType.grid ||
                      displayState.type == DisplayType.detailedGrid) {
                    return BooksGrid(
                      books: snapshot.data!,
                      listNumber: 0,
                      allBooksCount: snapshot.data!.length,
                      gridType: displayState.type,
                      gridSize: displayState.gridSize,
                      titleOverCover: displayState.showTitleOverCover,
                    );
                  }

                  return BooksList(
                    books: snapshot.data!,
                    listNumber: 0,
                    selectedTag: widget.tag,
                  );
                },
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
        label: Text(
          tag,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
        clipBehavior: Clip.none,
        onSelected: (_) {},
      ),
    );
  }
}
