import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/ui/similiar_books_screen/similiar_books_screen.dart';

class BookTitleDetail extends StatelessWidget {
  const BookTitleDetail({
    super.key,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.publicationYear,
    required this.bookType,
    this.tags,
  });

  final String title;
  final String? subtitle;
  final String author;
  final String publicationYear;
  final BookFormat bookType;
  final List<String>? tags;

  Widget _buildTagChip({
    required String tag,
    required BuildContext context,
  }) {
    return FilterChip(
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.surface,
      label: Text(
        tag,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        maxLines: 1,
        style: const TextStyle(fontSize: 12),
      ),
      clipBehavior: Clip.none,
      onSelected: (_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SimiliarBooksScreen(
              tag: tag,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _generateTagChips({required BuildContext context}) {
    final chips = List<Widget>.empty(growable: true);

    if (tags == null) {
      return [];
    }

    tags!.sort((a, b) => removeDiacritics(a.toLowerCase())
        .compareTo(removeDiacritics(b.toLowerCase())));

    for (var tag in tags!) {
      chips.add(_buildTagChip(
        tag: tag,
        context: context,
      ));
      chips.add(const SizedBox(width: 5));
    }

    if (chips.isNotEmpty) {
      chips.removeLast();
    }

    return chips;
  }

  void _navigateToSimiliarAuthorBooksScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimiliarBooksScreen(
          author: author,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle != null
              ? Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(200),
                  ),
                )
              : const SizedBox(),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
          ),
          const SizedBox(height: 5),
          InkWell(
            borderRadius: BorderRadius.circular(cornerRadius),
            onTap: () => _navigateToSimiliarAuthorBooksScreen(context),
            child: Text(
              author,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha(240),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: _generateTagChips(context: context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
