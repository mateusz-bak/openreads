import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/open_library_search_bloc/open_library_search_bloc.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_search_result.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/common/keyboard_dismissable.dart';
import 'package:openreads/ui/search_ol_editions_screen/search_ol_editions_screen.dart';
import 'package:openreads/ui/search_ol_screen/widgets/widgets.dart';

class SearchOLScreen extends StatefulWidget {
  const SearchOLScreen({
    super.key,
    this.scan = false,
    required this.status,
  });

  final bool scan;
  final BookStatus status;

  @override
  State<SearchOLScreen> createState() => _SearchOLScreenState();
}

class _SearchOLScreenState extends State<SearchOLScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  int offset = 0;
  final _pageSize = 10;
  String? _searchTerm;
  int? numberOfResults;
  ScanResult? scanResult;
  int searchTimestamp = 0;

  bool searchActivated = false;

  final _pagingController = PagingController<int, OLSearchResultDoc>(
    firstPageKey: 0,
  );

  void _saveNoEdition({
    required List<String> editions,
    required String title,
    String? subtitle,
    required String author,
    int? firstPublishYear,
    int? pagesMedian,
    int? cover,
    List<String>? isbn,
    String? olid,
  }) {
    final defaultBookFormat = context.read<DefaultBooksFormatCubit>().state;

    final book = Book(
      title: title,
      subtitle: subtitle,
      author: author,
      status: widget.status,
      favourite: false,
      pages: pagesMedian,
      isbn: (isbn != null && isbn.isNotEmpty) ? isbn[0] : null,
      olid: (olid != null) ? olid.replaceAll('/works/', '') : null,
      publicationYear: firstPublishYear,
      bookFormat: defaultBookFormat,
      readings: List<Reading>.empty(growable: true),
      tags: LocaleKeys.owned_book_tag.tr(),
      dateAdded: DateTime.now(),
      dateModified: DateTime.now(),
    );

    context.read<EditBookCubit>().setBook(book);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(
          fromOpenLibrary: true,
          coverOpenLibraryID: cover,
          work: olid,
        ),
      ),
    );
  }

  Future<void> _fetchPage(int pageKey) async {
    final searchTimestampSaved = DateTime.now().millisecondsSinceEpoch;
    searchTimestamp = searchTimestampSaved;

    try {
      if (_searchTerm == null) return;

      final newItems = await OpenLibraryService().getResults(
        query: _searchTerm!,
        offset: pageKey * _pageSize,
        limit: _pageSize,
        searchType: _getOLSearchTypeEnum(
          context.read<OpenLibrarySearchBloc>().state,
        ),
      );

      // Used to cancel the request if a new search is started
      // to avoid showing results from a previous search
      if (searchTimestamp != searchTimestampSaved) return;

      setState(() {
        numberOfResults = newItems.numFound;
      });

      final isLastPage = newItems.docs.length < _pageSize;

      if (isLastPage) {
        if (!mounted) return;
        _pagingController.appendLastPage(newItems.docs);
      } else {
        final nextPageKey = pageKey + newItems.docs.length;
        if (!mounted) return;
        _pagingController.appendPage(newItems.docs, nextPageKey);
      }
    } catch (error) {
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  void _startNewSearch() {
    if (_searchController.text.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      searchActivated = true;
    });

    _searchTerm = _searchController.text;
    _pagingController.refresh();
  }

  void _startScanner() async {
    context.read<OpenLibrarySearchBloc>().add(const OpenLibrarySearchSetISBN());

    var result = await BarcodeScanner.scan(
      options: ScanOptions(
        strings: {
          'cancel': LocaleKeys.cancel.tr(),
          'flash_on': LocaleKeys.flash_on.tr(),
          'flash_off': LocaleKeys.flash_off.tr(),
        },
      ),
    );

    if (result.type == ResultType.Barcode) {
      setState(() {
        searchActivated = true;
        _searchController.text = result.rawContent;
      });

      _searchTerm = result.rawContent;
      _pagingController.refresh();
    }
  }

  OLSearchType _getOLSearchTypeEnum(OpenLibrarySearchState state) {
    if (state is OpenLibrarySearchGeneral) {
      return OLSearchType.general;
    } else if (state is OpenLibrarySearchAuthor) {
      return OLSearchType.author;
    } else if (state is OpenLibrarySearchTitle) {
      return OLSearchType.title;
    } else if (state is OpenLibrarySearchISBN) {
      return OLSearchType.isbn;
    } else {
      return OLSearchType.general;
    }
  }

  _changeSearchType(OLSearchType? value) async {
    context.read<OpenLibrarySearchBloc>().add(
          value == OLSearchType.general
              ? const OpenLibrarySearchSetGeneral()
              : value == OLSearchType.author
                  ? const OpenLibrarySearchSetAuthor()
                  : value == OLSearchType.title
                      ? const OpenLibrarySearchSetTitle()
                      : value == OLSearchType.isbn
                          ? const OpenLibrarySearchSetISBN()
                          : const OpenLibrarySearchSetGeneral(),
        );

    // Delay for the state to be updated
    await Future.delayed(const Duration(milliseconds: 100));

    _startNewSearch();
  }

  // Used when search results are empty
  _addBookManually() {
    FocusManager.instance.primaryFocus?.unfocus();

    final searchType = _getOLSearchTypeEnum(
      context.read<OpenLibrarySearchBloc>().state,
    );

    final book = Book(
      title: searchType == OLSearchType.title ? _searchController.text : '',
      author: searchType == OLSearchType.author ? _searchController.text : '',
      status: BookStatus.read,
      isbn: searchType == OLSearchType.isbn ? _searchController.text : null,
      readings: List<Reading>.empty(growable: true),
      tags: 'owned',
      dateAdded: DateTime.now(),
      dateModified: DateTime.now(),
    );

    context.read<EditBookCubit>().setBook(book);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddBookScreen(fromOpenLibrary: true),
      ),
    );
  }

  _onChooseEditionPressed(OLSearchResultDoc item) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOLEditionsScreen(
          status: widget.status,
          editions: item.editionKey!,
          title: item.title!,
          subtitle: item.subtitle,
          author: (item.authorName != null && item.authorName!.isNotEmpty)
              ? item.authorName![0]
              : '',
          pagesMedian: item.medianPages,
          isbn: item.isbn,
          olid: item.key,
          firstPublishYear: item.firstPublishYear,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.scan) {
      _startScanner();
    }

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return KeyboardDismissible(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.add_search.tr(),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 10, 5),
              child: Row(
                children: [
                  Expanded(
                    child: BookTextField(
                      controller: _searchController,
                      keyboardType: TextInputType.name,
                      maxLength: 99,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _startNewSearch(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _startNewSearch,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                      ),
                      child: Text(
                        LocaleKeys.search.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: BlocBuilder<OpenLibrarySearchBloc, OpenLibrarySearchState>(
                builder: (context, state) {
                  return Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i != 0) const SizedBox(width: 5),
                        OLSearchRadio(
                          searchType: OLSearchType.values[i],
                          activeSearchType: _getOLSearchTypeEnum(state),
                          onChanged: _changeSearchType,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Divider(height: 3),
            ),
            (numberOfResults != null && numberOfResults! != 0)
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$numberOfResults ${LocaleKeys.results_lowercase.tr()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            Expanded(
              child: (!searchActivated)
                  ? const SizedBox()
                  : Scrollbar(
                      child: PagedListView<int, OLSearchResultDoc>(
                        pagingController: _pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<OLSearchResultDoc>(
                          firstPageProgressIndicatorBuilder: (_) => Center(
                            child: Platform.isIOS
                                ? CupertinoActivityIndicator(
                                    radius: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : LoadingAnimationWidget.staggeredDotsWave(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 42,
                                  ),
                          ),
                          newPageProgressIndicatorBuilder: (_) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Platform.isIOS
                                  ? CupertinoActivityIndicator(
                                      radius: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : LoadingAnimationWidget.staggeredDotsWave(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 42,
                                    ),
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (_) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(
                                    cornerRadius,
                                  ),
                                  onTap: _addBookManually,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          LocaleKeys.no_search_results.tr(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          LocaleKeys.click_to_add_book_manually
                                              .tr(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (context, item, index) =>
                              Builder(builder: (context) {
                            return BookCardOL(
                              title: item.title ?? '',
                              subtitle: item.subtitle,
                              author: (item.authorName != null &&
                                      item.authorName!.isNotEmpty)
                                  ? item.authorName![0]
                                  : '',
                              coverKey: item.coverEditionKey,
                              editions: item.editionKey,
                              pagesMedian: item.medianPages,
                              firstPublishYear: item.firstPublishYear,
                              onAddBookPressed: () => _saveNoEdition(
                                editions: item.editionKey!,
                                title: item.title ?? '',
                                subtitle: item.subtitle,
                                author: (item.authorName != null &&
                                        item.authorName!.isNotEmpty)
                                    ? item.authorName![0]
                                    : '',
                                pagesMedian: item.medianPages,
                                isbn: item.isbn,
                                olid: item.key,
                                firstPublishYear: item.firstPublishYear,
                                cover: item.coverI,
                              ),
                              onChooseEditionPressed: () =>
                                  _onChooseEditionPressed(item),
                            );
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
