import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/ol_search_result.dart';

class BookCardOL extends StatelessWidget {
  BookCardOL({
    Key? key,
    required this.title,
    required this.author,
    required this.openLibraryKey,
    required this.onChooseEditionPressed,
    required this.onAddBookPressed,
    required this.doc,
    required this.editions,
    required this.pagesMedian,
    required this.firstPublishYear,
  }) : super(key: key);

  final String title;
  final String author;
  final String? openLibraryKey;
  final OLSearchResultDoc doc;
  final Function() onChooseEditionPressed;
  final Function() onAddBookPressed;
  final List<String>? editions;
  final int? pagesMedian;
  final int? firstPublishYear;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/olid/$openLibraryKey-M.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: IntrinsicHeight(
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
                          borderRadius: Theme.of(context)
                              .extension<CustomBorder>()
                              ?.radius,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        SizedBox(
                          height: ((editions != null && editions!.isNotEmpty) ||
                                  pagesMedian != null ||
                                  firstPublishYear != null)
                              ? 10
                              : 0,
                        ),
                        Row(
                          children: [
                            (editions != null && editions!.isNotEmpty)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${editions!.length}',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).mainTextColor,
                                        ),
                                      ),
                                      Text(
                                        'editions',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
                                          color: Theme.of(context)
                                              .secondaryTextColor,
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(width: 10),
                            (pagesMedian != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$pagesMedian',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).mainTextColor,
                                        ),
                                      ),
                                      Text(
                                        'pages',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
                                          color: Theme.of(context)
                                              .secondaryTextColor,
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(width: 10),
                            (pagesMedian != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$firstPublishYear',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).mainTextColor,
                                        ),
                                      ),
                                      Text(
                                        'published',
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
                                          color: Theme.of(context)
                                              .secondaryTextColor,
                                        ),
                                      )
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: ((editions != null && editions!.isNotEmpty) ||
                                  pagesMedian != null ||
                                  firstPublishYear != null)
                              ? 10
                              : 0,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              (editions != null && editions!.isNotEmpty)
                                  ? ElevatedButton(
                                      onPressed: onChooseEditionPressed,
                                      style: TextButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          side: BorderSide(
                                            color:
                                                Theme.of(context).dividerColor,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Choose edition",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              Padding(
                                padding: EdgeInsets.only(
                                  left:
                                      (editions != null && editions!.isNotEmpty)
                                          ? 10
                                          : 0,
                                ),
                                child: ElevatedButton(
                                  onPressed: onAddBookPressed,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  child: const Text(
                                    "Add book",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
