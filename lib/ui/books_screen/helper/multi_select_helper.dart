import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:openreads/main.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_type_dropdown.dart';

List<String> bookTypes = [
  LocaleKeys.book_type_paper.tr(),
  LocaleKeys.book_type_ebook.tr(),
  LocaleKeys.book_type_audiobook.tr(),
];

showEditBookTypeBottomSheet(BuildContext context, Set<int> selectedBookIds) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.change_book_type.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              BookTypeDropdown(
                multiSelect: true,
                bookTypes: bookTypes,
                changeBookType: (bookType) {
                  if (bookType == null) return;
                  _updateBooks(bookType, selectedBookIds);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(LocaleKeys.update_successful_message.tr()),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      });
}

void _updateBooks(String bookType, Set<int> selectedIds) async {
  BookType selectedBookType = BookType.paper;
  if (bookType == bookTypes[0]) {
    selectedBookType = BookType.paper;
  } else if (bookType == bookTypes[1]) {
    selectedBookType = BookType.ebook;
  } else if (bookType == bookTypes[2]) {
    selectedBookType = BookType.audiobook;
  } else {
    selectedBookType = BookType.paper;
  }

  bookCubit.updateBookType(selectedIds, selectedBookType);
}
