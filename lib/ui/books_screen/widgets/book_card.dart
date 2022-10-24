import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:openreads/model/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    Key? key,
    required this.book,
    required this.onPressed,
  }) : super(key: key);

  final Book book;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            // color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: (book.cover != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.memory(
                          book.cover!,
                          fit: BoxFit.cover,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${book.author}',
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 3,
                      allowHalfRating: true,
                      unratedColor: Colors.black12,
                      glow: false,
                      glowRadius: 1,
                      itemSize: 24,
                      ignoreGestures: true,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber.shade300,
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
