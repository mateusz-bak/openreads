import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

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
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
      );
    }

    if (startDate == null && finishDate != null) {
      return Text(
        '${l10n.finished_on_date} $finishDate',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
      );
    }

    if (startDate != null && finishDate == null) {
      return Text(
        '${l10n.started_on_date} $startDate',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).secondaryTextColor,
          fontFamily: context.read<ThemeBloc>().fontFamily,
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
            color: Theme.of(context).likeColor,
          )
        : FaIcon(
            FontAwesomeIcons.heart,
            size: 30,
            color: Theme.of(context).secondaryTextColor,
          );
  }

  Widget _buildChangeStatusButton(BuildContext context) {
    return InkWell(
      onTap: changeStatusAction,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
          border: Border.all(color: Theme.of(context).dividerColor),
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
                    fontFamily: context.read<ThemeBloc>().fontFamily,
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
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
                    borderRadius:
                        Theme.of(context).extension<CustomBorder>()?.radius,
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
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: context.read<ThemeBloc>().fontFamily,
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: context.read<ThemeBloc>().fontFamily,
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
                              start: Theme.of(context).ratingColor,
                              end: Theme.of(context).likeColor,
                            ),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Theme.of(context).ratingColor,
                              dotSecondaryColor: Theme.of(context).likeColor,
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
              color: Theme.of(context).ratingColor,
            ),
            onRatingUpdate: (_) {},
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (rating == null) ? '0' : '${(rating! / 10)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: context.read<ThemeBloc>().fontFamily,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.star_rounded,
                color: Theme.of(context).ratingColor,
                size: 32,
              ),
            ],
          );
        }
      },
    );
  }
}
