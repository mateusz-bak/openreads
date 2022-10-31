import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookCardExtra extends StatelessWidget {
  BookCardExtra({
    Key? key,
    required this.title,
    required this.author,
    required this.openLibraryKey,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final String author;
  final String? openLibraryKey;
  final Function() onPressed;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';

  late final String coverUrl = '$coverBaseUrl/b/olid/$openLibraryKey-M.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: (openLibraryKey != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: CachedNetworkImage(
                          imageUrl: coverUrl,
                          placeholder: (context, url) => Center(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              width: 24,
                              height: 24,
                              child: const CircularProgressIndicator(),
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
                    Text(
                      'openLibraryKey: $openLibraryKey',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Theme.of(context).secondaryTextColor,
                      ),
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
