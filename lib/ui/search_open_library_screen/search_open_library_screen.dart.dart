import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/logic/bloc/open_library_bloc.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_open_library_screen/widgets/widgets.dart';

class SearchOpenLibrary extends StatefulWidget {
  const SearchOpenLibrary({super.key});

  @override
  State<SearchOpenLibrary> createState() => _SearchOpenLibraryState();
}

class _SearchOpenLibraryState extends State<SearchOpenLibrary> {
  late TextEditingController _searchController;
  int offset = 0;

  void _startOpenLibrarySearch(bool nextPage) {
    if (_searchController.text.isEmpty) return;

    if (nextPage) {
      offset += 20;
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
  Widget build(BuildContext context) {
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
                      _startOpenLibrarySearch(false);
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
                                Text('numFound: ${state.numFound}'),
                                Text('numFoundExact: ${state.numFoundExact}'),
                              ],
                            ),
                            SizedBox(
                              height: 51,
                              child: ElevatedButton(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _startOpenLibrarySearch(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: const Text("Next page"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: state.docs!.length,
                            itemBuilder: (context, index) {
                              return BookCardExtra(
                                title: state.docs![index].title ?? '',
                                author:
                                    (state.docs![index].authorName != null &&
                                            state.docs![index].authorName!
                                                .isNotEmpty)
                                        ? state.docs![index].authorName![0]
                                        : '',
                                openLibraryKey:
                                    state.docs![index].coverEditionKey,
                                onPressed: () {},
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
