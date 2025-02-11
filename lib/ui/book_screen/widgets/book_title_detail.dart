import 'package:diacritic/diacritic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        side: BorderSide(
          color: dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          overflow: TextOverflow.fade,
          softWrap: true,
          maxLines: 5,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
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
      ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : const SizedBox(),
            const Divider(height: 5),
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(cornerRadius),
              onTap: () => _navigateToSimiliarAuthorBooksScreen(context),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Text(
                  author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            (publicationYear != '')
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      publicationYear,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FaIcon(
                    bookType == BookFormat.audiobook
                        ? FontAwesomeIcons.headphones
                        : bookType == BookFormat.ebook
                            ? FontAwesomeIcons.tabletScreenButton
                            : FontAwesomeIcons.bookOpen,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    bookType == BookFormat.audiobook
                        ? LocaleKeys.book_format_audiobook.tr()
                        : bookType == BookFormat.ebook
                            ? LocaleKeys.book_format_ebook.tr()
                            : bookType == BookFormat.hardcover
                                ? LocaleKeys.book_format_hardcover.tr()
                                : LocaleKeys.book_format_paperback.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 0,
                    ),
                    child: Wrap(
                      children: _generateTagChips(context: context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
