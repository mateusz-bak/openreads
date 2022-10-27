import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    Key? key,
    required this.book,
    required this.onPressed,
    required this.heroTag,
  }) : super(key: key);

  final Book book;
  final String heroTag;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: (book.cover != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Hero(
                          tag: heroTag,
                          child: Image.memory(
                            book.cover!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${book.title}',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).mainTextColor,
                      ),
                    ),
                    Text(
                      '${book.author}',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Theme.of(context).secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    RatingBar.builder(
                      initialRating:
                          (book.rating == null) ? 0 : (book.rating! / 10),
                      allowHalfRating: true,
                      unratedColor: Colors.transparent,
                      glow: false,
                      glowRadius: 1,
                      itemSize: 24,
                      ignoreGestures: true,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Theme.of(context).primaryColor,
                      ),
                      onRatingUpdate: (_) {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
