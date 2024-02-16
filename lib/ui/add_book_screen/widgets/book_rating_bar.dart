import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';

class BookRatingBar extends StatelessWidget {
  const BookRatingBar({
    super.key,
    required this.animDuration,
  });

  final Duration animDuration;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBookCubit, Book>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AnimatedContainer(
                duration: animDuration,
                height: (state.status == BookStatus.read)
                    ? Constants.formHeight
                    : 0,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(cornerRadius),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Center(
                    child: RatingBar.builder(
                      initialRating:
                          (state.rating == null) ? 0.0 : state.rating! / 10,
                      allowHalfRating: true,
                      glow: false,
                      glowRadius: 1,
                      itemSize: 42,
                      itemPadding: const EdgeInsets.all(5),
                      wrapAlignment: WrapAlignment.center,
                      itemBuilder: (_, __) => Icon(
                        Icons.star_rounded,
                        color: ratingColor,
                      ),
                      onRatingUpdate: (rating) {
                        FocusManager.instance.primaryFocus?.unfocus();

                        context.read<EditBookCubit>().setRating(rating);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
