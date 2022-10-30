import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/sort_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/books_screen/widgets/widgets.dart';
import 'package:openreads/ui/statistics_screen/statistics_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({
    Key? key,
    required this.appVersion,
  }) : super(key: key);

  final String appVersion;

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Openreads',
            ),
            const SizedBox(width: 15),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                widget.appVersion,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return const SortBottomSheet();
                  });
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const StatisticsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded),
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return AddBook(
                    topPadding: statusBarHeight,
                    previousThemeData: Theme.of(context),
                  );
                });
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.finishedBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BlocBuilder<SortCubit, SortState>(
                            builder: (context, sortState) {
                              switch (sortState.sortType) {
                                case SortType.byAuthor:
                                  sortState.ascending
                                      ? snapshot.data!.sort((a, b) {
                                          return a.author
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(b.author
                                                  .toString()
                                                  .toLowerCase());
                                        })
                                      : snapshot.data!.sort((b, a) {
                                          return a.author
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(b.author
                                                  .toString()
                                                  .toLowerCase());
                                        });
                                  break;
                                case SortType.byRating:
                                  break;
                                case SortType.byPages:
                                  break;
                                default:
                                  sortState.ascending
                                      ? snapshot.data!.sort((a, b) {
                                          return a.title
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(b.title
                                                  .toString()
                                                  .toLowerCase());
                                        })
                                      : snapshot.data!.sort((b, a) {
                                          return a.author
                                              .toString()
                                              .toLowerCase()
                                              .compareTo(b.title
                                                  .toString()
                                                  .toLowerCase());
                                        });

                                  break;
                              }
                              return BooksList(
                                books: snapshot.data!,
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.inProgressBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BooksList(
                            books: snapshot.data!,
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    StreamBuilder<List<Book>>(
                      stream: bookCubit.toReadBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }
                          return BooksList(
                            books: snapshot.data!,
                          );
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              Container(
                color: Theme.of(context).backgroundColor,
                child: TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(
                      child: Text('Finished'),
                    ),
                    Tab(
                      child: Text('In progress'),
                    ),
                    Tab(
                      child: Text('For later'),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
