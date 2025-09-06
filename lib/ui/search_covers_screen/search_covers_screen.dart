import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:openreads/core/constants/constants.dart';
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
  Map<String, String?> params = {};
  Map<String, String> headers = {
    'authority': 'duckduckgo.com',
    'accept': 'application/json, text/javascript, */*; q=0.01',
    'sec-fetch-dest': 'empty',
    'x-requested-with': 'XMLHttpRequest',
    'user-agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-mode': 'cors',
    'referer': 'https://duckduckgo.com/',
    'accept-language': 'en-US,en;q=0.9',
  };

  late final PagingController<int, String> _pagingController = PagingController(
    fetchPage: (pageKey) => _fetchPage(pageKey),
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
  );

  late TextEditingController controller;
  String searchQuery = '';

  Future<List<String>> _fetchPage(int pageKey) async {
    try {
      await _getDuckDuckGoToken();
      final newItems = await _getImageResults();

      List<String> newImages = List<String>.empty(growable: true);
      for (var item in newItems['results']) {
        newImages.add(item['image']);
      }
      return newImages;
    } catch (error) {
      // TODO: Handle error and show message to user
      return [];
    }
  }

  Future _getDuckDuckGoToken() async {
    final url = Uri.parse(Constants.duckDuckGoURL);
    final tokenResponse = await http.post(url, body: {'q': searchQuery});

    final tokenMatch = RegExp(r'vqd=([\d-]+)\&').firstMatch(
      tokenResponse.body,
    );

    if (tokenMatch == null) {
      throw Exception('Token Parsing Failed !');
    }

    final token = tokenMatch.group(1);

    params = {
      'l': 'us-en',
      'o': 'json',
      'q': searchQuery,
      'vqd': token,
      'f': ',,,',
      'p': '1',
      'v7exp': 'a',
    };
  }

  Future<dynamic> _getImageResults() async {
    final requestUrl = Uri.parse(Constants.duckDuckGoImagesURL);

    final response = await http.get(
      requestUrl.replace(queryParameters: params),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

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
                });

                _pagingController.refresh();
              },
            ),
          ),
          SearchCoversGrid(pagingController: _pagingController),
        ],
      ),
    );
  }
}
