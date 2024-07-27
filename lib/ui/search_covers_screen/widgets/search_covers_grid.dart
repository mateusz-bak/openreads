import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/helpers/helpers.dart';

import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';

class SearchCoversGrid extends StatefulWidget {
  const SearchCoversGrid({
    super.key,
    required this.query,
    required this.pagingController,
  });

  final String query;
  final PagingController<int, String> pagingController;

  @override
  State<SearchCoversGrid> createState() => _SearchCoversGridState();
}

class _SearchCoversGridState extends State<SearchCoversGrid> {
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

  Future<void> _fetchPage() async {
    try {
      await _getDuckDuckGoToken();
      final newItems = await _getImageResults();

      List<String> newImages = List<String>.empty(growable: true);
      for (var item in newItems['results']) {
        newImages.add(item['image']);
      }

      widget.pagingController.appendLastPage(newImages);
    } catch (error) {
      widget.pagingController.error = error;
    }
  }

  Future _getDuckDuckGoToken() async {
    final url = Uri.parse(Constants.duckDuckGoURL);
    final tokenResponse = await http.post(url, body: {'q': widget.query});

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
      'q': widget.query,
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

  void _editSelectedCover({
    required BuildContext context,
    required Uint8List? bytes,
  }) async {
    if (bytes == null) return;
    final croppedPhoto = await cropImage(context, bytes);

    if (croppedPhoto == null) return;
    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    await generateBlurHash(croppedPhotoBytes, context);

    context.read<EditBookCoverCubit>().setCover(croppedPhotoBytes);
    context.read<EditBookCubit>().setHasCover(true);

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    widget.pagingController.addPageRequestListener((_) {
      _fetchPage();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        child: PagedMasonryGridView(
          pagingController: widget.pagingController,
          padding: const EdgeInsets.all(10),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          gridDelegateBuilder: (context) =>
              const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          builderDelegate: _createBuilderDelegate(context),
        ),
      ),
    );
  }

  PagedChildBuilderDelegate<String> _createBuilderDelegate(
    BuildContext context,
  ) {
    return PagedChildBuilderDelegate<String>(
      firstPageProgressIndicatorBuilder: (_) => Center(
        child: Platform.isIOS
            ? CupertinoActivityIndicator(
                radius: 20,
                color: Theme.of(context).colorScheme.primary,
              )
            : LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.primary,
                size: 50,
              ),
      ),
      itemBuilder: (context, imageURL, _) => InkWell(
        onTap: () async {
          final file = await DefaultCacheManager().getSingleFile(imageURL);
          final bytes = await file.readAsBytes();

          _editSelectedCover(context: context, bytes: bytes);
        },
        borderRadius: BorderRadius.circular(cornerRadius),
        child: CachedNetworkImage(
          imageUrl: imageURL,
          imageBuilder: (context, imageProvider) => Padding(
            padding: const EdgeInsets.all(0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: Image(image: imageProvider),
            ),
          ),
          errorWidget: (context, url, error) => const SizedBox(),
        ),
      ),
    );
  }
}
