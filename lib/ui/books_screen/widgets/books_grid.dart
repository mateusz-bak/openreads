import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksGrid extends StatefulWidget {
  const BooksGrid({
    super.key,
    required this.books,
    required this.listNumber,
    this.selectedBookIds,
    this.onBookSelectedForMultiSelect,
    required this.allBooksCount,
  });

  final List<Book> books;
  final int listNumber;
  final Set<int>? selectedBookIds;
  final Function(int id)? onBookSelectedForMultiSelect;
  final int allBooksCount;

  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid>
    with AutomaticKeepAliveClientMixin {
  _onPressed(int index, bool multiSelectMode, String heroTag) {
    if (widget.books[index].id == null) return;
    if (multiSelectMode && widget.onBookSelectedForMultiSelect != null) {
      widget.onBookSelectedForMultiSelect!(widget.books[index].id!);
      return;
    }

    context.read<CurrentBookCubit>().setBook(widget.books[index]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookScreen(
          id: widget.books[index].id!,
          heroTag: heroTag,
        ),
      ),
    );
  }

  onLongPressed(int index) {
    if (widget.books[index].id == null) return;
    if (widget.onBookSelectedForMultiSelect != null) {
      widget.onBookSelectedForMultiSelect!(widget.books[index].id!);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var multiSelectMode = widget.selectedBookIds?.isNotEmpty ?? false;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.books.length} ',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '(${widget.allBooksCount})',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1 / 1.5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: widget.books.length,
            itemBuilder: (context, index) {
              final heroTag =
                  'tag_${widget.listNumber}_${widget.books[index].id}';
              Color borderColor = multiSelectMode &&
                      widget.selectedBookIds!.contains(widget.books[index].id)
                  ? Theme.of(context).colorScheme.tertiary
                  : Colors.transparent;
              final double borderWidth = multiSelectMode &&
                      widget.selectedBookIds!.contains(widget.books[index].id)
                  ? 3.0
                  : 0.0;

              return Container(
                  decoration: multiSelectMode
                      ? BoxDecoration(
                          border: Border.all(
                            color: borderColor,
                            width: borderWidth,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        )
                      : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BookGridCard(
                        book: widget.books[index],
                        heroTag: heroTag,
                        addBottomPadding: (widget.books.length == index + 1),
                        onPressed: () => _onPressed(
                          index,
                          multiSelectMode,
                          heroTag,
                        ),
                        onLongPressed: () => onLongPressed(index),
                      ),
                      multiSelectMode &&
                              widget.selectedBookIds!
                                  .contains(widget.books[index].id)
                          ? InkWell(
                              onTap: () => _onPressed(
                                index,
                                multiSelectMode,
                                heroTag,
                              ),
                              onLongPress: () => onLongPressed(index),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ));
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
