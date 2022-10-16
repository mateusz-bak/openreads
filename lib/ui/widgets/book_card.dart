import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    Key? key,
    required this.title,
    required this.author,
  }) : super(key: key);

  final String title;
  final String author;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 80,
              width: 60,
              child: Placeholder(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    author,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: 3,
                    allowHalfRating: true,
                    glowColor: Colors.amber.shade100,
                    unratedColor: Colors.black12,
                    glowRadius: 1,
                    itemSize: 24,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber.shade300,
                    ),
                    onRatingUpdate: (_) {},
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
