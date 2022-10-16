import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openreads/bloc/book_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/widgets/widgets.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    bookBloc.getAllBooks();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Openreads Flutter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 20,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return AddBook(
                    topPadding: statusBarHeight,
                  );
                });
          },
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
                      stream: bookBloc.allBooks,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Center(child: Text('No books'));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return BookCard(
                                title: snapshot.data![index].title.toString(),
                                author: snapshot.data![index].author.toString(),
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
                    ListView(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              AppBar().preferredSize.height +
                              10,
                          bottom: 70),
                      children: [],
                    ),
                    ListView(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              AppBar().preferredSize.height +
                              10,
                          bottom: 70),
                      children: [],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TabBar(
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.teal,
                    tabs: [
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
              ),
            ],
          )),
    );
  }
}
