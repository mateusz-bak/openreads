import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/logic/bloc/open_library_bloc.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_open_lib_editions_screen/search_open_lib_editions_screen.dart';
import 'package:openreads/ui/search_open_library_screen/widgets/widgets.dart';

class SearchOpenLibrary extends StatefulWidget {
  const SearchOpenLibrary({super.key});

  @override
  State<SearchOpenLibrary> createState() => _SearchOpenLibraryState();
}

class _SearchOpenLibraryState extends State<SearchOpenLibrary>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;
  int offset = 0;

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

    BlocProvider.of<OpenLibraryBloc>(context).add(LoadApiEvent(
      _searchController.text,
      offset,
    ));
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    BlocProvider.of<OpenLibraryBloc>(context).add(ReadyEvent());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search in Open Library'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                    child: const Text("Search"),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<OpenLibraryBloc, OpenLibraryState>(
              builder: (context, state) {
            if (state is OpenLibraryLoadingState) {
              return Expanded(
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                ),
              );
            } else if (state is OpenLibraryLoadedState) {
              if (state.docs != null) {
                return Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${offset + 20}/${state.numFound}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                (offset != 0)
                                    ? SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            _startOpenLibrarySearch(
                                                previousPage: true);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          child: const Text("Previous page"),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(width: 10),
                                SizedBox(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      _startOpenLibrarySearch(nextPage: true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    child: const Text("Next page"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: state.docs!.length,
                            itemBuilder: (context, index) {
                              final doc = state.docs![index];
                              return BookCardExtra(
                                title: doc.title ?? '',
                                author: (doc.authorName != null &&
                                        doc.authorName!.isNotEmpty)
                                    ? doc.authorName![0]
                                    : '',
                                openLibraryKey: doc.coverEditionKey,
                                doc: doc,
                                onPressed: () {
                                  if (doc.seed == null) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchOpenLibEditions(
                                              editions: doc.seed!),
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
