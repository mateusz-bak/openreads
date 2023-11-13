import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:openreads/main.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_type_dropdown.dart';

List<String> bookTypes = [
  LocaleKeys.book_format_paperback.tr(),
  LocaleKeys.book_format_hardcover.tr(),
  LocaleKeys.book_format_ebook.tr(),
  LocaleKeys.book_format_audiobook.tr(),
];

showEditBookTypeBottomSheet(BuildContext context, Set<int> selectedBookIds) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                height: 3,
                width: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Text(
                    LocaleKeys.change_book_format.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              BookTypeDropdown(
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
  BookFormat selectedBookType = BookFormat.paperback;

  if (bookType == bookTypes[0]) {
    selectedBookType = BookFormat.paperback;
  } else if (bookType == bookTypes[1]) {
    selectedBookType = BookFormat.hardcover;
  } else if (bookType == bookTypes[2]) {
    selectedBookType = BookFormat.ebook;
  } else if (bookType == bookTypes[3]) {
    selectedBookType = BookFormat.audiobook;
  } else {
    selectedBookType = BookFormat.paperback;
  }

  bookCubit.updateBookFormat(selectedIds, selectedBookType);
}
