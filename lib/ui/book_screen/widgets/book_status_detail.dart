import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/reading_time.dart';

class BookStatusDetail extends StatefulWidget {
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

  @override
  State<BookStatusDetail> createState() => _BookStatusDetailState();
}

class _BookStatusDetailState extends State<BookStatusDetail> {
  String _generateReadingTime({
    DateTime? startDate,
    DateTime? finishDate,
    required BuildContext context,
    ReadingTime? readingTime,
  }) {
    if (readingTime != null) return '($readingTime)';

    if (startDate == null || finishDate == null) return '';

    final diff = finishDate.difference(startDate).inDays + 1;

    return '(${LocaleKeys.day.plural(diff).tr()})';
  }

  Widget _buildLikeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 0),
      child: GestureDetector(
        onTap: widget.onLikeTap,
        child: (widget.book.favourite)
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
      onTap: widget.changeStatusAction,
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
                  widget.changeStatusText!,
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
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
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
                              widget.statusIcon,
                              size: 24,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              widget.statusText,
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
                SizedBox(width: (widget.showChangeStatus) ? 10 : 0),
                (widget.showChangeStatus)
                    ? _buildChangeStatusButton(context)
                    : const SizedBox(),
              ],
            ),
            _generateHowManyTimesRead(context),
            SizedBox(height: (widget.showRatingAndLike) ? 10 : 0),
            (widget.showRatingAndLike)
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
            ..._buildStartAndFinishDates(context),
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
            initialRating:
                (widget.book.rating != null) ? widget.book.rating! / 10 : 0,
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
                (widget.book.rating == null)
                    ? '0'
                    : '${(widget.book.rating! / 10)}',
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

  List<Widget> _buildStartAndFinishDates(BuildContext context) {
    final widgets = <Widget>[];

    for (final reading in widget.book.readings) {
      late Widget widget;
      final startDate = reading.startDate;
      final finishDate = reading.finishDate;
      final readingTime = reading.customReadingTime;

      if (startDate != null && finishDate != null) {
        widget = _buildStartAndFinishDate(
          startDate,
          finishDate,
          readingTime,
          context,
        );
      } else if (startDate == null && finishDate != null) {
        widget = _buildOnlyFinishDate(
          finishDate,
          readingTime,
          context,
        );
      } else if (startDate != null && finishDate == null) {
        widget = _buildOnlyStartDate(
          startDate,
          context,
        );
      } else {
        widget = const SizedBox();
      }

      widgets.add(
        SizedBox(
          child: Row(
            children: [
              Expanded(child: widget),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildStartAndFinishDate(
    DateTime startDate,
    DateTime finishDate,
    ReadingTime? readingTime,
    BuildContext context,
  ) {
    final readingTimeText = ' ${_generateReadingTime(
      startDate: startDate,
      finishDate: finishDate,
      context: context,
      readingTime: readingTime,
    )}';

    return RichText(
      selectionRegistrar: SelectionContainer.maybeOf(context),
      selectionColor: ThemeGetters.getSelectionColor(context),
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text:
                '${dateFormat.format(startDate)} - ${dateFormat.format(finishDate)}',
          ),
          TextSpan(
            text: readingTimeText,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlyFinishDate(
    DateTime finishDate,
    ReadingTime? readingTime,
    BuildContext context,
  ) {
    final readingTimeText = ' ${_generateReadingTime(
      startDate: null,
      finishDate: null,
      context: context,
      readingTime: readingTime,
    )}';

    return RichText(
      selectionRegistrar: SelectionContainer.maybeOf(context),
      selectionColor: ThemeGetters.getSelectionColor(context),
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text:
                '${LocaleKeys.finished_on_date.tr()} ${dateFormat.format(finishDate)}',
          ),
          TextSpan(
            text: readingTimeText,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlyStartDate(
    DateTime startDate,
    BuildContext context,
  ) {
    return RichText(
      selectionRegistrar: SelectionContainer.maybeOf(context),
      selectionColor: ThemeGetters.getSelectionColor(context),
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text:
                '${LocaleKeys.started_on_date.tr()} ${dateFormat.format(startDate)}',
          ),
        ],
      ),
    );
  }

  Widget _generateHowManyTimesRead(BuildContext context) {
    int timesRead = 0;

    for (final reading in widget.book.readings) {
      if (reading.finishDate != null) {
        timesRead++;
      }
    }

    return timesRead > 1
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Text(LocaleKeys.read_x_times
                .plural(widget.book.readings.length)
                .tr()),
          )
        : const SizedBox();
  }
}
