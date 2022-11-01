import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/open_library_edition_result.dart';

class BookCardEdition extends StatelessWidget {
  BookCardEdition({
    Key? key,
    required this.result,
    required this.onPressed,
  }) : super(key: key);

  final OpenLibraryEditionResult result;

  final Function() onPressed;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';

  late final String coverUrl = '${coverBaseUrl}b/id/${result.covers}-M.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Theme.of(context).outlineColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: (result.covers != null && result.covers!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://covers.openlibrary.org/b/id/${result.covers![0]}-M.jpg',
                          placeholder: (context, url) => Center(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(child: Text('No cover')),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      result.title.toString(),
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).mainTextColor,
                      ),
                    ),
                    Text(
                      (result.authors != null && result.authors!.isNotEmpty)
                          ? result.authors![0].key.toString()
                          : '',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Theme.of(context).secondaryTextColor,
                      ),
                    ),
                    Text('covers: ${result.covers}'),
                    Text('numberOfPages: ${result.numberOfPages}'),
                    Text('publishDate: ${result.publishDate}'),
                    Text('languages: ${result.languages?[0].key}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
