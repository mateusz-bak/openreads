import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/ui/search_covers_screen/widgets/widgets.dart';

class SearchCoversScreen extends StatefulWidget {
  const SearchCoversScreen({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  State<SearchCoversScreen> createState() => _SearchCoversScreenState();
}

class _SearchCoversScreenState extends State<SearchCoversScreen> {
  final PagingController<int, String> _pagingController =
      PagingController(firstPageKey: 0);

  late TextEditingController controller;
  String searchQuery = '';

  @override
  initState() {
    super.initState();

    searchQuery =
        '${widget.book.title} ${widget.book.author} ${LocaleKeys.bookCover.tr()}';

    controller = TextEditingController(text: searchQuery);

    controller.addListener(() {
      setState(() {
        if (searchQuery == controller.text) return;

        searchQuery = controller.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.searchOnlineForCover.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BookTextField(
              controller: controller,
              keyboardType: TextInputType.text,
              maxLength: 256,
              onSubmitted: (_) {
                setState(() {
                  searchQuery = controller.text;
                  _pagingController.refresh();
                });
              },
            ),
          ),
          SearchCoversGrid(
            pagingController: _pagingController,
            query: searchQuery,
          ),
        ],
      ),
    );
  }
}
