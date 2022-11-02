import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/ol_search_result.dart';

class BookCardExtra extends StatelessWidget {
  BookCardExtra({
    Key? key,
    required this.title,
    required this.author,
    required this.openLibraryKey,
    required this.onPressed,
    required this.doc,
  }) : super(key: key);

  final String title;
  final String author;
  final String? openLibraryKey;
  final Doc doc;
  final Function() onPressed;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/olid/$openLibraryKey-M.jpg';

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
                width: 120,
                child: (openLibraryKey != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: CachedNetworkImage(
                          imageUrl: coverUrl,
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
                      title,
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
                      author,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Theme.of(context).secondaryTextColor,
                      ),
                    ),
                    // Text(
                    //   'openLibraryKey: $openLibraryKey',
                    //   softWrap: true,
                    //   overflow: TextOverflow.clip,
                    //   style: TextStyle(
                    //     fontSize: 15,
                    //     letterSpacing: 1,
                    //     color: Theme.of(context).secondaryTextColor,
                    //   ),
                    // ),
                    // Text('type: ${doc.type}'),
                    // Text('numberOfPagesMedian: ${doc.numberOfPagesMedian}'),
                    // Text('firstPublishYear: ${doc.firstPublishYear}'),
                    // Text('subtitle: ${doc.subtitle}'),
                    // Text('ISBN count: ${doc.isbn?.length}'),
                    // Text('seed count: ${doc.seed?.length}'),
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
