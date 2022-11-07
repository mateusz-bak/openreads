import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_search_result.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_ol_editions_screen/search_ol_editions_screen.dart';
import 'package:openreads/ui/search_ol_screen/widgets/widgets.dart';

class SearchOLScreen extends StatefulWidget {
  const SearchOLScreen({super.key});

  @override
  State<SearchOLScreen> createState() => _SearchOLScreenState();
}

class _SearchOLScreenState extends State<SearchOLScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  int offset = 0;
  late double statusBarHeight;

  void _startOpenLibrarySearch({bool? nextPage, bool? previousPage}) {
    if (_searchController.text.isEmpty) return;

    if (nextPage == true) {
      offset += 20;
    } else if (previousPage == true) {
      offset -= 20;

      if (offset < 0) {
        offset = 0;
      }
    } else {
      offset = 0;
    }

    BlocProvider.of<OpenLibBloc>(context).add(LoadApiEvent(
      _searchController.text,
      offset,
    ));
  }

  void _saveNoEdition({
    required double statusBarHeight,
    required List<String> editions,
    required String title,
    required String author,
    int? firstPublishYear,
    int? pagesMedian,
    List<String>? isbn,
    String? olid,
  }) {
    final book = Book(
      title: title,
      author: author,
      status: 0,
      favourite: false,
      pages: pagesMedian,
      isbn: (isbn != null && isbn.isNotEmpty) ? isbn[0] : null,
      olid: (olid != null) ? olid.replaceAll('/works/', '') : null,
      publicationYear: firstPublishYear,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddBook(
        topPadding: statusBarHeight,
        previousThemeData: Theme.of(context),
        fromOpenLibrary: true,
        book: book,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<OpenLibBloc>(context).add(ReadyEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search in Open Library',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Row(
              children: [
                Expanded(
                  child: BookTextField(
                    controller: _searchController,
                    keyboardType: TextInputType.name,
                    maxLength: 99,
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 51,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _startOpenLibrarySearch();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<OpenLibBloc, OpenLibState>(builder: (context, state) {
            if (state is OpenLibLoadingState) {
              return Expanded(
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
            } else if (state is OpenLibLoadedState) {
              if (state.docs != null) {
                final filteredResults = List<Doc>.empty(growable: true);

                for (var result in state.docs!) {
                  if (result.title != null &&
                      result.authorName != null &&
                      result.authorName!.isNotEmpty) {
                    filteredResults.add(result);
                  }
                }

                return Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 10, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.numFound} results',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: filteredResults.length,
                            itemBuilder: (context, index) {
                              final doc = filteredResults[index];
                              return BookCardOL(
                                title: doc.title!,
                                author: doc.authorName![0],
                                openLibraryKey: doc.coverEditionKey,
                                doc: doc,
                                editions: doc.seed,
                                pagesMedian: doc.numberOfPagesMedian,
                                firstPublishYear: doc.firstPublishYear,
                                onAddBookPressed: () => _saveNoEdition(
                                  statusBarHeight: statusBarHeight,
                                  editions: doc.seed!,
                                  title: doc.title!,
                                  author: doc.authorName![0],
                                  pagesMedian: doc.numberOfPagesMedian,
                                  isbn: doc.isbn,
                                  olid: doc.key,
                                  firstPublishYear: doc.firstPublishYear,
                                ),
                                onChooseEditionPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchOLEditionsScreen(
                                        editions: doc.seed!,
                                        title: doc.title!,
                                        author: doc.authorName![0],
                                        pagesMedian: doc.numberOfPagesMedian,
                                        isbn: doc.isbn,
                                        olid: doc.key,
                                        firstPublishYear: doc.firstPublishYear,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('No books found');
              }
            }
            return const SizedBox();
          })
        ],
      ),
    );
  }
}
