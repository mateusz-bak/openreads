import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/open_library_search_bloc/open_library_search_bloc.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/default_book_tags_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/ol_edition_result.dart';
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
  bool _searchingISBN = false;
  bool _searchingISBNError = false;

  late final _pagingController = PagingController<int, OLSearchResultDoc>(
    fetchPage: (pageKey) => _fetchPage(pageKey),
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
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
    final defaultTags = context.read<DefaultBookTagsCubit>().state;

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
      tags: defaultTags.isNotEmpty ? defaultTags.join('|||||') : null,
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

  void _saveEdition({
    required OLEditionResult result,
    required int? cover,
    String? work,
    String? authors,
  }) {
    if (!mounted) return;

    final defaultBookFormat = context.read<DefaultBooksFormatCubit>().state;
    final defaultTags = context.read<DefaultBookTagsCubit>().state;

    final addDate = DateTime.now();

    final book = Book(
      title: result.title!,
      subtitle: result.subtitle,
      author: authors ?? '',
      pages: result.numberOfPages,
      status: widget.status,
      favourite: false,
      isbn: (result.isbn13 != null && result.isbn13!.isNotEmpty)
          ? result.isbn13![0]
          : (result.isbn10 != null && result.isbn10!.isNotEmpty)
              ? result.isbn10![0]
              : null,
      olid: (result.key != null) ? result.key!.replaceAll('/books/', '') : null,
      publicationYear: int.tryParse(result.publishDate ?? ''),
      bookFormat: result.physicalFormat ?? defaultBookFormat,
      readings: List<Reading>.empty(growable: true),
      tags: defaultTags.isNotEmpty == true ? defaultTags.join('|||||') : null,
      dateAdded: addDate,
      dateModified: addDate,
    );

    context.read<EditBookCubit>().setBook(book);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(
          fromOpenLibrary: true,
          fromOpenLibraryEdition: true,
          work: work,
          coverOpenLibraryID: cover,
        ),
      ),
    );
  }

  Future<List<OLSearchResultDoc>> _fetchPage(int pageKey) async {
    final searchTimestampSaved = DateTime.now().millisecondsSinceEpoch;
    searchTimestamp = searchTimestampSaved;

    try {
      if (_searchTerm == null) return [];

      final newItems = await OpenLibraryService().getResults(
        query: _searchTerm!,
        offset: (pageKey - 1) * _pageSize,
        limit: _pageSize,
        searchType: _getOLSearchTypeEnum(
          context.read<OpenLibrarySearchBloc>().state,
        ),
      );

      // Used to cancel the request if a new search is startedpageKey
      // to avoid showing results from a previous search
      if (searchTimestamp != searchTimestampSaved) return [];

      setState(() {
        numberOfResults = newItems.numFound;
      });

      return newItems.docs;
    } catch (error) {
      // TODO: Handle error and show message to user
      return [];
    }
  }

  void _startNewSearch() {
    if (_searchController.text.isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _searchingISBNError = false;
      _searchingISBN = false;
      searchActivated = true;
    });

    if (context.read<OpenLibrarySearchBloc>().state is OpenLibrarySearchISBN) {
      final isbn = _searchController.text.replaceAll('-', '').trim();
      _searchByISBN(isbn);
    } else {
      _searchTerm = _searchController.text;

      _pagingController.refresh();
    }
  }

  void _searchByISBN(String isbn) async {
    setState(() {
      _searchingISBNError = false;
      _searchingISBN = true;
    });
    final edition = await OpenLibraryService().getEditionByISBN(isbn: isbn);

    final authors = List<String>.empty(growable: true);
    for (final author in edition?.authors ?? []) {
      final authorResult =
          await OpenLibraryService().getAuthor(key: author.key);

      if (authorResult?.name != null) {
        authors.add(authorResult!.name!);
      }
    }

    if (edition != null) {
      setState(() {
        searchActivated = false;
      });

      _saveEdition(
        result: edition,
        cover: edition.covers != null && edition.covers!.isNotEmpty
            ? edition.covers![0]
            : null,
        work: edition.works != null && edition.works!.isNotEmpty
            ? edition.works![0].key
            : null,
        authors: authors.join(', '),
      );
    } else {
      setState(() {
        _searchingISBN = false;
        _searchingISBNError = true;
      });
    }
  }

  void _startScanner() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    FocusManager.instance.primaryFocus?.unfocus();
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
        _searchingISBNError = false;
        searchActivated = true;
        _searchController.text = result.rawContent;
      });

      _searchTerm = result.rawContent;
      // _pagingController.refresh();
      _searchByISBN(result.rawContent);
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
    final openLibrarySearchBloc = context.read<OpenLibrarySearchBloc>();

    switch (value) {
      case OLSearchType.author:
        openLibrarySearchBloc.add(const OpenLibrarySearchSetAuthor());
        break;
      case OLSearchType.title:
        openLibrarySearchBloc.add(const OpenLibrarySearchSetTitle());
        break;
      case OLSearchType.isbn:
        openLibrarySearchBloc.add(const OpenLibrarySearchSetISBN());
        break;
      default:
        openLibrarySearchBloc.add(const OpenLibrarySearchSetGeneral());
        break;
    }

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
          actions: [
            IconButton(
              onPressed: _startScanner,
              icon: const FaIcon(FontAwesomeIcons.camera, size: 18),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchField(context),
            _buildSearchTypesRadio(),
            _buildDivider(),
            _buildNumberOfResults(),
            (searchActivated)
                ? Expanded(
                    child: _searchingISBN
                        ? _buildFirstPageProgressIndicator(context)
                        : _searchingISBNError
                            ? _buildNoItemsFoundIndicator()
                            : _buildSearchResults(),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Scrollbar _buildSearchResults() {
    return Scrollbar(
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, OLSearchResultDoc>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<OLSearchResultDoc>(
            firstPageProgressIndicatorBuilder: (_) =>
                _buildFirstPageProgressIndicator(context),
            newPageProgressIndicatorBuilder: (_) =>
                _buildNewPageProgressIndicator(context),
            noItemsFoundIndicatorBuilder: (_) => _buildNoItemsFoundIndicator(),
            itemBuilder: (context, item, index) => _buildResultCard(item),
          ),
        ),
      ),
    );
  }

  Center _buildFirstPageProgressIndicator(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator(
              radius: 20,
              color: Theme.of(context).colorScheme.primary,
            )
          : LoadingAnimationWidget.staggeredDotsWave(
              color: Theme.of(context).colorScheme.primary,
              size: 42,
            ),
    );
  }

  Builder _buildResultCard(OLSearchResultDoc item) {
    return Builder(builder: (context) {
      return BookCardOL(
        title: item.title ?? '',
        subtitle: item.subtitle,
        author: (item.authorName != null && item.authorName!.isNotEmpty)
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
          author: (item.authorName != null && item.authorName!.isNotEmpty)
              ? item.authorName![0]
              : '',
          pagesMedian: item.medianPages,
          isbn: item.isbn,
          olid: item.key,
          firstPublishYear: item.firstPublishYear,
          cover: item.coverI,
        ),
        onChooseEditionPressed: () => _onChooseEditionPressed(item),
      );
    });
  }

  Center _buildNoItemsFoundIndicator() {
    return Center(
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
                    LocaleKeys.click_to_add_book_manually.tr(),
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
    );
  }

  Center _buildNewPageProgressIndicator(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Platform.isIOS
            ? CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            : LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 42,
              ),
      ),
    );
  }

  SingleChildRenderObjectWidget _buildNumberOfResults() {
    return (numberOfResults != null && numberOfResults! != 0)
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
        : const SizedBox();
  }

  Padding _buildDivider() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Divider(height: 3),
    );
  }

  Align _buildSearchTypesRadio() {
    return Align(
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
    );
  }

  Padding _buildSearchField(BuildContext context) {
    return Padding(
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
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
              child: Text(
                LocaleKeys.search.tr(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
