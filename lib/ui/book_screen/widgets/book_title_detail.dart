import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookTitleDetail extends StatelessWidget {
  const BookTitleDetail({
    Key? key,
    required this.title,
    required this.author,
    required this.publicationYear,
    this.tags,
  }) : super(key: key);

  final String title;
  final String author;
  final String publicationYear;
  final List<String>? tags;

  Widget _buildTagChip(
      {required String tag,
      required bool selected,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).mainTextColor,
          ),
        ),
        checkmarkColor: Colors.white,
        selected: selected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (_) {},
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
        selected: false,
        context: context,
      ));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).mainTextColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Text(
              author,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).secondaryTextColor,
              ),
            ),
          ),
          (publicationYear != '')
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: Text(
                    publicationYear,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).secondaryTextColor,
                    ),
                  ),
                )
              : const SizedBox(),
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
    );
  }
}
