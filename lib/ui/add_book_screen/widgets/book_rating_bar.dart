import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookRatingBar extends StatelessWidget {
  const BookRatingBar({
    Key? key,
    required this.animDuration,
    required this.status,
    required this.defaultHeight,
    required this.rating,
    required this.onRatingUpdate,
  }) : super(key: key);

  final Duration animDuration;
  final int? status;
  final double defaultHeight;
  final double rating;
  final Function(double) onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animDuration,
      height: (status == 0) ? defaultHeight : 0,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).outlineColor),
        ),
        child: Center(
          child: RatingBar.builder(
            initialRating: rating,
            allowHalfRating: true,
            glow: false,
            unratedColor: Theme.of(context).secondaryBackgroundColor,
            glowRadius: 1,
            itemSize: 42,
            itemPadding: const EdgeInsets.all(5),
            wrapAlignment: WrapAlignment.center,
            itemBuilder: (_, __) => Icon(
              Icons.star,
              color: Theme.of(context).primaryColor,
            ),
            onRatingUpdate: (rating) => onRatingUpdate(rating),
          ),
        ),
      ),
    );
  }
}
