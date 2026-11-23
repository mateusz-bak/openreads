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

  // page keys are DuckDuckGo result offsets, the next one comes with each page
  late final PagingController<int, String> _pagingController = PagingController(
    fetchPage: (pageKey) => _fetchPage(pageKey),
    getNextPageKey: (state) => state.keys == null ? 0 : _nextOffset,
  );

  late TextEditingController controller;
  String searchQuery = '';

  // DuckDuckGo limits requests, so the token is reused for the same query
  String? _token;
  String? _tokenQuery;
  int? _nextOffset;

  Future<List<String>> _fetchPage(int pageKey) async {
    if (_token == null || _tokenQuery != searchQuery) {
      await _getDuckDuckGoToken();
    }

    final newItems = await _getImageResults(pageKey);

    _nextOffset = _getNextOffset(newItems['next']);

    final results = newItems['results'];
    if (results is! List) {
      throw Exception('Image search returned no results list');
    }

    List<String> newImages = List<String>.empty(growable: true);
    for (var item in results) {
      newImages.add(item['image']);
    }
    return newImages;
  }

  int? _getNextOffset(dynamic next) {
    if (next is! String) return null;

    final offset = Uri.parse(next).queryParameters['s'];
    return offset != null ? int.tryParse(offset) : null;
  }

  Future<void> _getDuckDuckGoToken() async {
    final url = Uri.parse(Constants.duckDuckGoURL);
    final tokenResponse = await http.post(url, body: {'q': searchQuery});

    if (tokenResponse.statusCode != 200) {
      throw Exception('Token request failed: ${tokenResponse.statusCode}');
    }

    final tokenMatch = RegExp(r'vqd=([\d-]+)\&').firstMatch(
      tokenResponse.body,
    );

    if (tokenMatch == null) {
      throw Exception('Token Parsing Failed !');
    }

    _token = tokenMatch.group(1);
    _tokenQuery = searchQuery;
  }

  Future<dynamic> _getImageResults(int offset) async {
    final requestUrl = Uri.parse(Constants.duckDuckGoImagesURL);

    params = {
      'l': 'us-en',
      'o': 'json',
      'q': _tokenQuery,
      'vqd': _token,
      'f': ',,,',
      'p': '1',
      's': '$offset',
      'v7exp': 'a',
    };

    final response = await http.get(
      requestUrl.replace(queryParameters: params),
      headers: headers,
    );

    // a blocked request does not return JSON, a new token may help next time
    if (response.statusCode != 200) {
      _token = null;
      throw Exception('Image search failed: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  @override
  initState() {
    super.initState();

    searchQuery =
        '${widget.book.title} ${widget.book.author} ${LocaleKeys.book_cover.tr()}';

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
          LocaleKeys.search_online_for_cover.tr(),
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
