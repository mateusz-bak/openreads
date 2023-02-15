import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/model/ol_search_result.dart';

class BookCardOL extends StatelessWidget {
  BookCardOL({
    Key? key,
    required this.title,
    required this.subtitle,
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
  final String? subtitle;
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
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: dividerColor),
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
                                color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                        child: Center(
                          child: Text(l10n.no_cover),
                        ),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle != null
                            ? Text(
                                subtitle!,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(fontSize: 13),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 5),
                        Text(
                          author,
                          softWrap: true,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontSize: 14),
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        l10n.editions_lowercase,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        l10n.pages_lowercase,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        l10n.published_lowercase,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          letterSpacing: 1,
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              cornerRadius),
                                          side: BorderSide(
                                            color: dividerColor,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.choose_edition,
                                        style: const TextStyle(fontSize: 12),
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
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(cornerRadius),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.add_book,
                                    style: const TextStyle(fontSize: 12),
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
