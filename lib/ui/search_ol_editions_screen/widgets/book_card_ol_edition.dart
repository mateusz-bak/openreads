import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';

class BookCardOLEdition extends StatelessWidget {
  BookCardOLEdition({
    Key? key,
    required this.title,
    required this.cover,
    required this.onPressed,
  }) : super(key: key);

  final String title;
  final int? cover;
  final Function() onPressed;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/id/$cover-M.jpg';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
              BorderRadius.circular(5),
        ),
        onTap: onPressed,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
              border: Border.all(color: Theme.of(context).dividerColor),
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
                                child: LoadingAnimationWidget.threeArchedCircle(
                                  color: Theme.of(context).primaryColor,
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
                        child: Center(
                          child: FittedBox(
                            child: Text(l10n.no_cover),
                          ),
                        ),
                      ),
              ],
            )),
      ),
    );
  }
}
