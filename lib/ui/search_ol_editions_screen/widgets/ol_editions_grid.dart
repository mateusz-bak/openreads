import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/search_ol_editions_screen/widgets/widgets.dart';

class OLEditionsGrid extends StatelessWidget {
  OLEditionsGrid({
    super.key,
    required this.editions,
    required this.saveEdition,
    required this.onlyEditionsWithCovers,
  });

  final List<String> editions;
  final bool onlyEditionsWithCovers;

  final Function({
    required OLEditionResult result,
    required int? cover,
    String? work,
  }) saveEdition;

  final sizeOfPage = 1;

  late final _pagingController = PagingController<int, OLEditionResult>(
    fetchPage: (pageKey) => _fetchPage(pageKey),
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
  );

  Future<List<OLEditionResult>> _fetchPage(int pageKey) async {
    try {
      List<OLEditionResult> newResults = await _fetchResults(
        offset: (pageKey - 1) * sizeOfPage,
      );

      // If first page is empty the package will abort further requests.
      // This is a workaround to fetch the next page if the first page is empty
      // without appending the first page to the list of results.
      while (newResults.isEmpty && pageKey < editions.length) {
        pageKey += sizeOfPage;
        newResults = await _fetchResults(offset: pageKey);
      }

      return newResults;
    } catch (error) {
      // TODO: Handle error and show message to user
      return [];
    }
  }

  Future<List<OLEditionResult>> _fetchResults({required int offset}) async {
    final results = <OLEditionResult>[];

    final keysToFetch = <String>[];
    for (var i = 0; i < sizeOfPage && (offset + i) < editions.length; i++) {
      keysToFetch.add(editions[offset + i]);
    }

    final fetchedResults = await Future.wait(
      keysToFetch.map((key) => OpenLibraryService().getEdition(key)),
    );

    for (final newResult in fetchedResults) {
      if (onlyEditionsWithCovers) {
        if (newResult.covers != null && newResult.covers!.isNotEmpty) {
          results.add(newResult);
        }
      } else {
        results.add(newResult);
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedGridView<int, OLEditionResult>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.all(10.0),
            showNewPageProgressIndicatorAsGridChild: false,
            showNewPageErrorIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            builderDelegate: PagedChildBuilderDelegate<OLEditionResult>(
              invisibleItemsThreshold: 12,
              firstPageProgressIndicatorBuilder: (_) => Center(
                child: Platform.isIOS
                    ? CupertinoActivityIndicator(
                        radius: 20,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).colorScheme.primary,
                        size: 50,
                      ),
              ),
              newPageProgressIndicatorBuilder: (_) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Platform.isIOS
                      ? CupertinoActivityIndicator(
                          radius: 20,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).colorScheme.primary,
                          size: 50,
                        ),
                ),
              ),
              itemBuilder: (context, item, index) => BookCardOLEdition(
                publishers: item.publishers,
                publicationDate: item.publishDate,
                title: item.title ?? '',
                pages: item.numberOfPages,
                cover: item.covers != null && item.covers!.isNotEmpty
                    ? item.covers![0]
                    : null,
                onPressed: () => saveEdition(
                  result: item,
                  cover: item.covers != null && item.covers!.isNotEmpty
                      ? item.covers![0]
                      : null,
                  work: item.works != null && item.works!.isNotEmpty
                      ? item.works![0].key
                      : null,
                ),
              ),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 5 / 8.0,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 225,
            ),
          ),
        ),
      ),
    );
  }
}
