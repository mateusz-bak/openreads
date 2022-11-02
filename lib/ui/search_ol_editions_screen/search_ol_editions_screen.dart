import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:openreads/logic/bloc/open_library_editions_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/search_ol_editions_screen/widgets/widgets.dart';

class SearchOLEditionsScreen extends StatefulWidget {
  const SearchOLEditionsScreen({
    super.key,
    required this.editions,
    required this.title,
    required this.author,
    required this.pagesMedian,
    required this.isbn,
    required this.olid,
    required this.firstPublishYear,
  });

  final List<String> editions;
  final String title;
  final String author;
  final int? pagesMedian;
  final List<String>? isbn;
  final String? olid;
  final int? firstPublishYear;

  @override
  State<SearchOLEditionsScreen> createState() => _SearchOLEditionsScreenState();
}

class _SearchOLEditionsScreenState extends State<SearchOLEditionsScreen> {
  final openLibraryEditionResult = List<OLEditionResult>.empty(
    growable: true,
  );

  void _getEditions(BuildContext context) async {
    int i = 0;
    int waitDelay = 100;

    for (var _ in widget.editions) {
      if (!mounted) return;

      BlocProvider.of<OpenLibraryEditionsBloc>(context)
          .add(LoadApiEditionsEvent(
        widget.editions[i],
      ));

      await Future.delayed(Duration(milliseconds: waitDelay));

      i++;

      if (waitDelay < 500) {
        waitDelay += 50;
      }
    }
  }

  void _saveEdition({
    required double statusBarHeight,
    required OLEditionResult result,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddBook(
          topPadding: statusBarHeight,
          previousThemeData: Theme.of(context),
          book: Book(
              title: result.title!,
              author: widget.author,
              pages: result.numberOfPages,
              isbn: (result.isbn13 != null && result.isbn13!.isNotEmpty)
                  ? result.isbn13![0]
                  : (result.isbn10 != null && result.isbn10!.isNotEmpty)
                      ? result.isbn10![0]
                      : null,
              olid: (result.key != null)
                  ? result.key!.replaceAll('/books/', '')
                  : null,
              publicationYear: widget.firstPublishYear),
          fromOpenLibrary: true,
        );
      },
    );
  }

  void _saveNoEdition({
    required double statusBarHeight,
  }) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return AddBook(
            topPadding: statusBarHeight,
            previousThemeData: Theme.of(context),
            book: Book(
              title: widget.title,
              author: widget.author,
              pages: widget.pagesMedian,
              isbn: (widget.isbn != null && widget.isbn!.isNotEmpty)
                  ? widget.isbn![0]
                  : null,
              olid: (widget.olid != null)
                  ? widget.olid!.replaceAll('/works/', '')
                  : null,
              publicationYear: widget.firstPublishYear,
            ),
            fromOpenLibrary: true,
          );
        });
  }

  StreamBuilder<List<OLEditionResult>> _buildStreamBuilder(
    BuildContext context,
    double statusBarHeight,
  ) {
    return StreamBuilder<List<OLEditionResult>>(
      stream: BlocProvider.of<OpenLibraryEditionsBloc>(context).editionsList,
      builder: (context, AsyncSnapshot<List<OLEditionResult>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books'));
          }

          final filteredList = List<OLEditionResult>.empty(growable: true);
          for (var result in snapshot.data!) {
            if (result.covers != null &&
                result.covers!.isNotEmpty &&
                result.title != null) {
              filteredList.add(result);
            }
          }

          return Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MasonryGridView.count(
                        itemCount: filteredList.length,
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemBuilder: (context, index) {
                          return BookCardEdition(
                            title: filteredList[index].title!,
                            cover: filteredList[index].covers![0],
                            onPressed: () => _saveEdition(
                              statusBarHeight: statusBarHeight,
                              result: filteredList[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocProvider(
      create: (context) => OpenLibraryEditionsBloc(
        RepositoryProvider.of<OpenLibraryService>(context),
        RepositoryProvider.of<ConnectivityService>(context),
      ),
      child: Builder(builder: (context) {
        BlocProvider.of<OpenLibraryEditionsBloc>(context)
            .add(ReadyEditionsEvent());
        _getEditions(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Choose edition'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            scrolledUnderElevation: 0,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<OpenLibraryEditionsBloc, OpenLibraryEditionsState>(
                  builder: (context, state) {
                if (state is OpenLibraryEditionsLoadedState) {
                  return _buildStreamBuilder(context, statusBarHeight);
                }
                return const SizedBox();
              }),
              NoEditionsButton(
                onPressed: () => _saveNoEdition(
                  statusBarHeight: statusBarHeight,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
