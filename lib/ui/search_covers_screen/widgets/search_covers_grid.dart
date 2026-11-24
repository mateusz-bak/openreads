import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/generated/locale_keys.g.dart';

import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';

class SearchCoversGrid extends StatefulWidget {
  const SearchCoversGrid({
    super.key,
    required this.pagingController,
  });

  final PagingController<int, String> pagingController;

  @override
  State<SearchCoversGrid> createState() => _SearchCoversGridState();
}

class _SearchCoversGridState extends State<SearchCoversGrid> {
  // tiles rebuilt after scrolling keep their size instead of jumping
  final Map<String, double> _aspectRatios = {};

  void _rememberAspectRatio(String imageURL, ImageProvider imageProvider) {
    if (_aspectRatios.containsKey(imageURL)) return;

    final stream = imageProvider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      _aspectRatios[imageURL] = info.image.width / info.image.height;
      stream.removeListener(listener);
    });
    stream.addListener(listener);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        child: PagingListener(
          controller: widget.pagingController,
          builder: (context, state, fetchNextPage) => PagedMasonryGridView(
            state: state,
            fetchNextPage: fetchNextPage,
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
      firstPageErrorIndicatorBuilder: (_) => _buildError(
        onRetry: widget.pagingController.refresh,
      ),
      newPageErrorIndicatorBuilder: (_) => _buildError(
        onRetry: widget.pagingController.fetchNextPage,
      ),
      itemBuilder: (context, imageURL, _) => InkWell(
        onTap: () async {
          final file = await DefaultCacheManager().getSingleFile(imageURL);
          final bytes = await file.readAsBytes();

          _editSelectedCover(context: context, bytes: bytes);
        },
        borderRadius: BorderRadius.circular(cornerRadius),
        child: _aspectRatios.containsKey(imageURL)
            ? AspectRatio(
                aspectRatio: _aspectRatios[imageURL]!,
                child: _buildCover(imageURL),
              )
            : _buildCover(imageURL),
      ),
    );
  }

  Widget _buildCover(String imageURL) {
    final mediaQuery = MediaQuery.of(context);

    // full size covers fill the image cache and get reloaded after scrolling
    final tileWidth =
        (mediaQuery.size.width / 2 * mediaQuery.devicePixelRatio).round();

    return CachedNetworkImage(
      imageUrl: imageURL,
      memCacheWidth: tileWidth,
      imageBuilder: (context, imageProvider) {
        // imageBuilder gets the full size provider, resize it the same way
        final resizedImage = ResizeImage(imageProvider, width: tileWidth);

        _rememberAspectRatio(imageURL, resizedImage);

        return ClipRRect(
          borderRadius: BorderRadius.circular(cornerRadius),
          child: Image(image: resizedImage, fit: BoxFit.cover),
        );
      },
      errorWidget: (context, url, error) => const SizedBox(),
    );
  }

  Widget _buildError({required Function() onRetry}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.cover_search_error.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          FilledButton.tonal(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
            ),
            child: Text(LocaleKeys.try_again.tr()),
          ),
        ],
      ),
    );
  }
}
