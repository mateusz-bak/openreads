import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookStatusDetail extends StatelessWidget {
  const BookStatusDetail({
    Key? key,
    required this.statusIcon,
    required this.statusText,
    required this.rating,
  }) : super(key: key);

  final IconData? statusIcon;
  final String statusText;
  final int? rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            statusIcon,
                            size: 32,
                            color: Theme.of(context).mainTextColor,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            statusText,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).mainTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          //TODO: add start and finish dates
          const SizedBox(height: 5),
          Text(
            '12 feb 2022 - 03 mar 2022',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).secondaryTextColor,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Your rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          RatingBar.builder(
            initialRating: (rating != null) ? rating! / 10 : 0,
            allowHalfRating: true,
            unratedColor: Colors.black12,
            glow: false,
            itemSize: 48,
            ignoreGestures: true,
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: Theme.of(context).primaryColor,
            ),
            onRatingUpdate: (_) {},
          ),
        ],
      ),
    );
  }
}
