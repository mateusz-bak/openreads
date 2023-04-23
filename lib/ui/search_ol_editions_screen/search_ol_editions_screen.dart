import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_editions_screen/widgets/widgets.dart';

class SearchOLEditionsScreen extends StatefulWidget {
  const SearchOLEditionsScreen({
    super.key,
    required this.editions,
    required this.title,
    this.subtitle,
    required this.author,
    this.description,
    required this.pagesMedian,
    required this.isbn,
    required this.olid,
    required this.firstPublishYear,
    this.work,
  });

  final List<String> editions;
  final String title;
  final String? subtitle;
  final String author;
  final String? description;
  final int? pagesMedian;
  final List<String>? isbn;
  final String? olid;
  final int? firstPublishYear;
  final String? work;

  @override
  State<SearchOLEditionsScreen> createState() => _SearchOLEditionsScreenState();
}

class _SearchOLEditionsScreenState extends State<SearchOLEditionsScreen> {
  final sizeOfPage = 3;
  int skippedEditions = 0;
  Uint8List? editionCoverPreview;

  late int filteredResultsLength;

  final _pagingController = PagingController<int, OLEditionResult>(
    firstPageKey: 0,
    invisibleItemsThreshold: 12,
  );

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newResults = await _fetchResults(offset: pageKey);

      if (!mounted) return;

      if (pageKey >= widget.editions.length) {
        _pagingController.appendLastPage(newResults);
      } else {
        final nextPageKey = pageKey + 3;
        _pagingController.appendPage(newResults, nextPageKey);
      }
    } catch (error) {
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  Future<List<OLEditionResult>> _fetchResults({required int offset}) async {
    final results = List<OLEditionResult>.empty(growable: true);

    for (var i = 0; i < sizeOfPage && i < widget.editions.length; i++) {
      bool getEdition = true;

      while (getEdition) {
        if (offset + i + skippedEditions < widget.editions.length) {
          final newResult = await OpenLibraryService().getEdition(
            widget.editions[offset + i + skippedEditions],
          );

          if (newResult.covers != null && newResult.covers!.isNotEmpty) {
            results.add(newResult);
            getEdition = false;
          } else {
            skippedEditions += 1;
          }
        } else {
          getEdition = false;
        }
      }
    }

    return results;
  }

  void _saveEdition({
    required OLEditionResult result,
    required int? cover,
    String? work,
  }) {
    final book = Book(
      title: result.title!,
      subtitle: widget.subtitle,
      author: widget.author,
      description: widget.description,
      pages: result.numberOfPages,
      status: 0,
      favourite: false,
      isbn: (result.isbn13 != null && result.isbn13!.isNotEmpty)
          ? result.isbn13![0]
          : (result.isbn10 != null && result.isbn10!.isNotEmpty)
              ? result.isbn10![0]
              : null,
      olid: (result.key != null) ? result.key!.replaceAll('/books/', '') : null,
      publicationYear: widget.firstPublishYear,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(
          fromOpenLibrary: true,
          cover: cover,
          book: book,
          fromOpenLibraryEdition: true,
          work: work,
        ),
      ),
    );
  }

  @override
  void initState() {
    filteredResultsLength = widget.editions.length;

    if (widget.editions.isNotEmpty) {
      _pagingController.addPageRequestListener((pageKey) {
        _fetchPage(pageKey);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.choose_edition,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: PagedGridView(
                        pagingController: _pagingController,
                        showNewPageProgressIndicatorAsGridChild: false,
                        showNewPageErrorIndicatorAsGridChild: false,
                        showNoMoreItemsIndicatorAsGridChild: false,
                        builderDelegate:
                            PagedChildBuilderDelegate<OLEditionResult>(
                          firstPageProgressIndicatorBuilder: (_) => Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).colorScheme.primary,
                              size: 50,
                            ),
                          ),
                          newPageProgressIndicatorBuilder: (_) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Theme.of(context).colorScheme.primary,
                                size: 50,
                              ),
                            ),
                          ),
                          itemBuilder: (context, item, index) =>
                              BookCardOLEdition(
                            title: item.title!,
                            cover: item.covers![0],
                            onPressed: () => _saveEdition(
                              result: item,
                              cover: item.covers![0],
                              work: item.works![0].key,
                            ),
                          ),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 5 / 8.0,
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 225,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
