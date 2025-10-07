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
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 50),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatusBox(context),
              SizedBox(width: (widget.showChangeStatus) ? 20 : 0),
              (widget.showChangeStatus)
                  ? _buildChangeStatusButton(context)
                  : const SizedBox(),
            ],
          ),
          const SizedBox(height: 10),
          _generateHowManyTimesRead(context),
          ..._buildStartAndFinishDates(context),
          SizedBox(height: (widget.showRatingAndLike) ? 20 : 0),
          (widget.showRatingAndLike)
              ? _buildRatingAndLike(context)
              : const SizedBox(),
        ],
      ),
    );
  }

  Expanded _buildStatusBox(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.statusIcon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.statusText,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeStatusButton(BuildContext context) {
    return InkWell(
      onTap: widget.changeStatusAction,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildRatingAndLike(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              LocaleKeys.your_rating.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 0.5,
              ),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRating(context),
              ],
            ),
            LikeButton(
              isLiked: widget.book.favourite,
              onTap: widget.onLikeTap,
            ),
          ],
        ),
      ],
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
            unratedColor: Theme.of(context).colorScheme.surfaceContainerLow,
            glow: false,
            itemSize: 34,
            ignoreGestures: true,
            itemPadding: const EdgeInsets.only(right: 3),
            itemBuilder: (context, _) => FaIcon(
              FontAwesomeIcons.solidStar,
              color: Theme.of(context).colorScheme.primaryContainer,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.solidStar,
                color: Theme.of(context).colorScheme.primaryContainer,
                size: 16,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
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
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        ),
        children: [
          TextSpan(
            text:
                '${dateFormat.format(startDate)} - ${dateFormat.format(finishDate)}',
          ),
          TextSpan(
            text: readingTimeText,
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
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        ),
        children: [
          TextSpan(
            text:
                '${LocaleKeys.finished_on_date.tr()} ${dateFormat.format(finishDate)}',
          ),
          TextSpan(
            text: readingTimeText,
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
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
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
            padding: const EdgeInsets.only(bottom: 5, top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      LocaleKeys.read_x_times
                          .plural(widget.book.readings.length)
                          .tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(220),
                        height: 0.5,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
