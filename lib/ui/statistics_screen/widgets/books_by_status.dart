import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class BooksByStatus extends StatefulWidget {
  const BooksByStatus({
    super.key,
    required this.title,
    required this.list,
  });

  final String title;
  final List<int>? list;

  @override
  State<StatefulWidget> createState() => BooksByStatusState();
}

class BooksByStatusState extends State<BooksByStatus> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return StatsCard(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${LocaleKeys.books_finished.tr()} - ${widget.list![0]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${LocaleKeys.books_in_progress.tr()} - ${widget.list![1]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${LocaleKeys.books_for_later.tr()} - ${widget.list![2]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
