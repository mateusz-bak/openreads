import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';

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
    this.showChangeStatus = false,
    this.changeStatusText,
    this.changeStatusAction,
    this.showRatingAndLike = false,
  }) : super(key: key);

  final IconData? statusIcon;
  final String statusText;
  final String? startDate;
  final String? finishDate;
  final int? rating;
  final Future<bool?> Function(bool)? onLikeTap;
  final bool isLiked;
  final bool showChangeStatus;
  final String? changeStatusText;
  final Function()? changeStatusAction;
  final bool showRatingAndLike;

  Widget _buildStartAndFinishDate(BuildContext context) {
    if (startDate != null && finishDate != null) {
      return Text(
        '$startDate - $finishDate',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    if (startDate == null && finishDate != null) {
      return Text(
        '${l10n.finished_on_date} $finishDate',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    if (startDate != null && finishDate == null) {
      return Text(
        '${l10n.started_on_date} $startDate',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildLikeButton(BuildContext context, bool isLiked) {
    return (isLiked)
        ? FaIcon(
            FontAwesomeIcons.solidHeart,
            size: 30,
            color: likeColor,
          )
        : const FaIcon(FontAwesomeIcons.heart, size: 30);
  }

  Widget _buildChangeStatusButton(BuildContext context) {
    return InkWell(
      onTap: changeStatusAction,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: dividerColor),
          color: Theme.of(context).colorScheme.secondary,
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
                const SizedBox(height: 22),
                Text(
                  changeStatusText!,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(cornerRadius),
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
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              statusText,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (showChangeStatus) ? 10 : 0),
                (showChangeStatus)
                    ? _buildChangeStatusButton(context)
                    : const SizedBox(),
              ],
            ),
            const SizedBox(height: 5),
            _buildStartAndFinishDate(context),
            SizedBox(height: (showRatingAndLike) ? 10 : 0),
            (showRatingAndLike)
                ? Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.your_rating,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRating(context),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10, top: 0),
                            child: LikeButton(
                              isLiked: isLiked,
                              onTap: onLikeTap,
                              size: 30,
                              circleColor: CircleColor(
                                start: ratingColor,
                                end: likeColor,
                              ),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: ratingColor,
                                dotSecondaryColor: likeColor,
                              ),
                              likeBuilder: (bool isLiked) {
                                _buildLikeButton(context, isLiked);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildRating(BuildContext context) {
    return BlocBuilder<RatingTypeBloc, RatingTypeState>(
      builder: (context, state) {
        if (state is RatingTypeBar) {
          return RatingBar.builder(
            initialRating: (rating != null) ? rating! / 10 : 0,
            allowHalfRating: true,
            unratedColor: Theme.of(context).scaffoldBackgroundColor,
            glow: false,
            itemSize: 40,
            ignoreGestures: true,
            itemBuilder: (context, _) => Icon(
              Icons.star_rounded,
              color: ratingColor,
            ),
            onRatingUpdate: (_) {},
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (rating == null) ? '0' : '${(rating! / 10)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.star_rounded,
                color: ratingColor,
                size: 32,
              ),
            ],
          );
        }
      },
    );
  }
}
