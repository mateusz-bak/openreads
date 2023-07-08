import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookTypeDropdown extends StatelessWidget {
  const BookTypeDropdown({
    super.key,
    required this.bookType,
    required this.bookTypes,
    required this.changeBookType,
  });

  final BookType bookType;
  final List<String> bookTypes;
  final Function(String?) changeBookType;

  String _getBookTypeDropdownValue() {
    switch (bookType) {
      case BookType.paper:
        return bookTypes[0];
      case BookType.ebook:
        return bookTypes[1];
      case BookType.audiobook:
        return bookTypes[2];
      default:
        return bookTypes[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: dividerColor,
        ),
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(cornerRadius),
          bottomLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
          bottomRight: Radius.circular(cornerRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            padding: EdgeInsets.fromLTRB(
              10,
              0,
              bookType == BookType.audiobook
                  ? 2
                  : bookType == BookType.ebook
                      ? 4
                      : 0,
              0,
            ),
            child: Center(
              child: FaIcon(
                bookType == BookType.audiobook
                    ? FontAwesomeIcons.headphones
                    : bookType == BookType.ebook
                        ? FontAwesomeIcons.tablet
                        : FontAwesomeIcons.bookOpen,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                isExpanded: true,
                buttonStyleData: const ButtonStyleData(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                items: bookTypes
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                value: _getBookTypeDropdownValue(),
                onChanged: (value) => changeBookType(value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
