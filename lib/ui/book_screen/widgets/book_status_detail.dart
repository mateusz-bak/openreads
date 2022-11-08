import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookStatusDetail extends StatelessWidget {
  const BookStatusDetail({
    Key? key,
    required this.statusIcon,
    required this.statusText,
    required this.rating,
    required this.startDate,
    required this.finishDate,
    required this.onLikeTap,
    required this.isLiked,
  }) : super(key: key);

  final IconData? statusIcon;
  final String statusText;
  final String? startDate;
  final String? finishDate;
  final int? rating;
  final Future<bool?> Function(bool)? onLikeTap;
  final bool isLiked;

  Widget _buildStartAndFinishDate(BuildContext context) {
    if (startDate != null && finishDate != null) {
      return Text(
        '$startDate - $finishDate',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
        ),
      );
    }

    if (startDate == null && finishDate != null) {
      return Text(
        'Finished on $finishDate',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
        ),
      );
    }

    if (startDate != null && finishDate == null) {
      return Text(
        'Started on $startDate',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            statusIcon,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            statusText,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
          const SizedBox(height: 5),
          _buildStartAndFinishDate(context),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: (rating != null) ? rating! / 10 : 0,
                    allowHalfRating: true,
                    unratedColor: Theme.of(context).scaffoldBackgroundColor,
                    glow: false,
                    itemSize: 30,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => Icon(
                      Icons.star_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onRatingUpdate: (_) {},
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: LikeButton(
                  isLiked: isLiked,
                  onTap: onLikeTap,
                  size: 32,
                  circleColor: CircleColor(
                    start: Theme.of(context).mainTextColor,
                    end: Theme.of(context).primaryColor,
                  ),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: Theme.of(context).mainTextColor,
                    dotSecondaryColor: Theme.of(context).primaryColor,
                  ),
                  likeBuilder: (bool isLiked) {
                    return FaIcon(
                      FontAwesomeIcons.solidHeart,
                      size: 32,
                      color: isLiked
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).secondaryTextColor,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
