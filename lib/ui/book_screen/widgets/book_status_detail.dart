import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/reading_time.dart';

class BookStatusDetail extends StatelessWidget {
  const BookStatusDetail({
    super.key,
    required this.book,
    required this.statusIcon,
    required this.statusText,
    required this.onLikeTap,
    this.showChangeStatus = false,
    this.changeStatusText,
    this.changeStatusAction,
    this.showRatingAndLike = false,
  });

  final Book book;
  final IconData? statusIcon;
  final String statusText;
  final Function() onLikeTap;
  final bool showChangeStatus;
  final String? changeStatusText;
  final Function()? changeStatusAction;
  final bool showRatingAndLike;

  String _generateReadingTime({
    DateTime? startDate,
    DateTime? finishDate,
    required BuildContext context,
    ReadingTime? readingTime,
  }) {
    if (readingTime != null) return readingTime.toString();

    final diff = finishDate!.difference(startDate!).inDays +
        1; // should be at least 1 day

    return LocaleKeys.day.plural(diff).tr();
  }

  Widget _buildStartAndFinishDate(
    BuildContext context,
    DateTime? startDate,
    DateTime? finishDate,
  ) {
    final dateFormat = DateFormat.yMd(
      '${context.locale.languageCode}-${context.locale.countryCode}',
    );

    if (startDate != null && finishDate != null) {
      return Text(
        '${dateFormat.format(startDate)} - ${dateFormat.format(finishDate)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (startDate == null && finishDate != null) {
      return Text(
        '${LocaleKeys.finished_on_date.tr()} ${dateFormat.format(finishDate)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (startDate != null && finishDate == null) {
      return Text(
        '${LocaleKeys.started_on_date.tr()} ${dateFormat.format(startDate)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildLikeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 0),
      child: GestureDetector(
        onTap: onLikeTap,
        child: (book.favourite)
            ? FaIcon(
                FontAwesomeIcons.solidHeart,
                size: 30,
                color: likeColor,
              )
            : const FaIcon(FontAwesomeIcons.solidHeart, size: 30),
      ),
    );
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
            SizedBox(height: (showRatingAndLike) ? 10 : 0),
            (showRatingAndLike)
                ? Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            LocaleKeys.your_rating.tr(),
                            style: const TextStyle(
                              fontSize: 16,
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
                          _buildLikeButton(),
                        ],
                      ),
                    ],
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            // TODO implement with multiple readings
            // Row(
            //   children: [
            //     _buildStartAndFinishDate(
            //       context,
            //       book.startDate,
            //       book.finishDate,
            //     ),
            //     (book.startDate == null || book.finishDate == null)
            //         ? const SizedBox()
            //         : Text(' (${_generateReadingTime(
            //             finishDate: book.finishDate,
            //             startDate: book.startDate,
            //             readingTime: book.readingTime,
            //             context: context,
            //           )})'),
            //   ],
            // ),
            _buildAdditionalReadingDates(context)
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
            initialRating: (book.rating != null) ? book.rating! / 10 : 0,
            allowHalfRating: true,
            unratedColor: Theme.of(context).scaffoldBackgroundColor,
            glow: false,
            itemSize: 45,
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
                (book.rating == null) ? '0' : '${(book.rating! / 10)}',
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

  Widget _buildAdditionalReadingDates(BuildContext context) {
    // TODO implement with multiple readings
    // if (book.additionalReadings == null) return const SizedBox();
    // if (book.additionalReadings!.isEmpty) return const SizedBox();

    List<Widget> widgets = [];

    // TODO implement with multiple readings
    // final sortedAdditionalReadings = book.additionalReadings!
    //   ..sort((a, b) {
    //     if (a.finishDate == null && b.finishDate == null) {
    //       return 0;
    //     } else if (a.finishDate == null) {
    //       return 1;
    //     } else if (b.finishDate == null) {
    //       return -1;
    //     } else {
    //       return b.finishDate!.compareTo(a.finishDate!);
    //     }
    //   });

    // for (var reading in sortedAdditionalReadings) {
    //   widgets.add(
    //     Padding(
    //       padding: const EdgeInsets.only(top: 5),
    //       child: Row(
    //         children: [
    //           _buildStartAndFinishDate(
    //             context,
    //             reading.startDate,
    //             reading.finishDate,
    //           ),
    //           (reading.startDate == null || reading.finishDate == null)
    //               ? const SizedBox()
    //               : Text(' (${_generateReadingTime(
    //                   finishDate: reading.finishDate,
    //                   startDate: reading.startDate,
    //                   readingTime: reading.customReadingTime,
    //                   context: context,
    //                 )})'),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Column(children: widgets);
  }
}
