import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/enums.dart';
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
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

    for (var tag in tags!) {
      chips.add(_buildTagChip(
        tag: tag,
        context: context,
      ));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
              child: SelectableText(
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
                    child: SelectableText(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : const SizedBox(),
            const Divider(height: 5),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: SelectableText(
                author,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            (publicationYear != '')
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: SelectableText(
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
                            ? FontAwesomeIcons.tablet
                            : FontAwesomeIcons.bookOpen,
                    size: 16,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 10),
                  SelectableText(
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
