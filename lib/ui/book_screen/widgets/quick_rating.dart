import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/core/themes/app_theme.dart';

class QuickRating extends StatefulWidget {
  const QuickRating({
    super.key,
    required this.onRatingUpdate,
  });

  final Function(double) onRatingUpdate;

  @override
  State<QuickRating> createState() => _QuickRatingState();
}

class _QuickRatingState extends State<QuickRating> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: dividerColor),
      ),
      child: Center(
        child: RatingBar.builder(
          initialRating: 0.0,
          allowHalfRating: true,
          glow: true,
          glowRadius: 0.5,
          itemSize: 40,
          itemPadding: const EdgeInsets.all(0),
          wrapAlignment: WrapAlignment.center,
          itemBuilder: (_, __) => Icon(
            Icons.star_rounded,
            color: ratingColor,
          ),
          onRatingUpdate: widget.onRatingUpdate,
        ),
      ),
    );
  }
}
