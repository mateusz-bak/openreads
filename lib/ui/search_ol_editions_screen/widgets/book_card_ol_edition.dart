import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class BookCardOLEdition extends StatelessWidget {
  BookCardOLEdition({
    super.key,
    required this.title,
    required this.cover,
    required this.onPressed,
    required this.pages,
    this.publicationDate,
    this.publishers,
  });

  final String title;
  final int? cover;
  final int? pages;
  final Function() onPressed;
  final String? publicationDate;
  final List<String>? publishers;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/id/$cover-M.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: cover == null
                ? Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3)
                : null,
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              cover != null
                  ? Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: CachedNetworkImage(
                          imageUrl: coverUrl,
                          fadeInDuration: const Duration(milliseconds: 100),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholder: (context, url) => Center(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: Platform.isIOS
                                  ? CupertinoActivityIndicator(
                                      radius: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : LoadingAnimationWidget.threeArchedCircle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 24,
                                    ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 20,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                pages != null
                                    ? Text(
                                        '$pages ${LocaleKeys.pages_lowercase.tr()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(0.6),
                                        ),
                                      )
                                    : const SizedBox(),
                                publicationDate != null
                                    ? Text(publicationDate!)
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              (publishers != null && publishers!.isNotEmpty)
                  ? Text(
                      publishers![0],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.8),
                      ),
                    )
                  : const SizedBox.shrink(),
              publicationDate != null && cover != null
                  ? Text(
                      publicationDate!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.8),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
