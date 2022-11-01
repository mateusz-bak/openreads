import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/bloc/open_library_editions_bloc.dart';
import 'package:openreads/model/open_library_edition_result.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/search_open_lib_editions_screen/widgets/widgets.dart';

class SearchOpenLibEditions extends StatefulWidget {
  const SearchOpenLibEditions({super.key, required this.editions});

  @override
  State<SearchOpenLibEditions> createState() => _SearchOpenLibEditionsState();

  final List<String> editions;
}

class _SearchOpenLibEditionsState extends State<SearchOpenLibEditions> {
  int offset = 0;

  final openLibraryEditionResult = List<OpenLibraryEditionResult>.empty(
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

      if (waitDelay < 2000) {
        waitDelay += 50;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Search Editions in Open Library'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            scrolledUnderElevation: 0,
          ),
          body: Column(
            children: [
              BlocBuilder<OpenLibraryEditionsBloc, OpenLibraryEditionsState>(
                  builder: (context, state) {
                if (state is OpenLibraryEditionsLoadedState) {
                  return StreamBuilder<List<OpenLibraryEditionResult>>(
                    stream: BlocProvider.of<OpenLibraryEditionsBloc>(context)
                        .editionsList,
                    builder: (context,
                        AsyncSnapshot<List<OpenLibraryEditionResult>>
                            snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No books'));
                        }
                        return Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  child: ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return BookCardEdition(
                                        result: snapshot.data![index],
                                        onPressed: () {},
                                      );
                                    },
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
                return const SizedBox();
              })
            ],
          ),
        );
      }),
    );
  }
}
