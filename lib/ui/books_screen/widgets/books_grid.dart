import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/book_screen.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';

class BooksGrid extends StatefulWidget {
  const BooksGrid({
    Key? key,
    required this.books,
    required this.listNumber,
    this.selectedBookIds,
    this.onBookSelected,
  }) : super(key: key);

  final List<Book> books;
  final int listNumber;
  final Set<int>? selectedBookIds;
  final Function(int id)? onBookSelected;

  @override
  State<BooksGrid> createState() => _BooksGridState();
}

class _BooksGridState extends State<BooksGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var multiSelectMode = widget.selectedBookIds?.isNotEmpty ?? false;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1 / 1.5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
      itemCount: widget.books.length,
      itemBuilder: (context, index) {
        final heroTag = 'tag_${widget.listNumber}_${widget.books[index].id}';
        Color color = multiSelectMode &&
                widget.selectedBookIds!.contains(widget.books[index].id)
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent;

        return Container(
            decoration: multiSelectMode
                ? BoxDecoration(border: Border.all(color: color, width: 4))
                : null,
            child: BookGridCard(
              book: widget.books[index],
              heroTag: heroTag,
              addBottomPadding: (widget.books.length == index + 1),
              onPressed: () {
                if (widget.books[index].id == null) return;
                if (multiSelectMode && widget.onBookSelected != null) {
                  widget.onBookSelected!(widget.books[index].id!);
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
              },
              onLongPressed: () {
                if (widget.books[index].id == null) return;
                if (widget.onBookSelected != null) {
                  widget.onBookSelected!(widget.books[index].id!);
                  return;
                }
              },
            ));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
