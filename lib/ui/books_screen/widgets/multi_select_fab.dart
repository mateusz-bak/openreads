import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_type_dropdown.dart';

class MultiSelectFAB extends StatelessWidget {
  MultiSelectFAB({
    super.key,
    required this.selectedBookIds,
  });

  final Set<int> selectedBookIds;

  final bookTypes = [
    'Paperback',
    'Hardcover',
    'Ebook',
    'Audiobook',
  ];

  final _authorCtrl = TextEditingController();

  String _getLabel(BulkEditOption bulkEditOption) {
    String label = '';
    switch (bulkEditOption) {
      case BulkEditOption.format:
        label = LocaleKeys.change_book_format.tr();
        break;
      case BulkEditOption.author:
        label = LocaleKeys.change_books_author.tr();
        break;
    }
    return label;
  }

  showEditBooksBottomSheet(
    BuildContext context,
    Set<int> selectedBookIds,
    BulkEditOption bulkEditOption,
  ) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopLine(context),
                    const SizedBox(height: 20),
                    _buildHeader(bulkEditOption),
                    const SizedBox(height: 20),
                    bulkEditOption == BulkEditOption.format
                        ? _buildEditFormat(selectedBookIds, context)
                        : bulkEditOption == BulkEditOption.author
                            ? _buildEditAuthor(selectedBookIds, context)
                            : const SizedBox(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _updateBooksFormat(String bookType, Set<int> selectedIds) {
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

    bookCubit.bulkUpdateBookFormat(selectedIds, selectedBookType);
  }

  bool _updateBooksAuthor(Set<int> selectedIds) {
    final author = _authorCtrl.text;

    if (author.isEmpty) return false;

    bookCubit.bulkUpdateBookAuthor(selectedIds, author);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: SpeedDial(
        spacing: 3,
        dialRoot: (ctx, open, toggleChildren) {
          return FloatingActionButton(
              onPressed: toggleChildren, child: const Icon(Icons.create));
        },
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.menu_book_outlined),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            label: LocaleKeys.change_book_format.tr(),
            onTap: () {
              showEditBooksBottomSheet(
                context,
                selectedBookIds,
                BulkEditOption.format,
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.person),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            label: LocaleKeys.change_books_author.tr(),
            onTap: () {
              showEditBooksBottomSheet(
                context,
                selectedBookIds,
                BulkEditOption.author,
              );
            },
          ),
        ],
      ),
    );
  }

  Column _buildEditAuthor(Set<int> selectedBookIds, BuildContext context) {
    return Column(
      children: [
        BookTextField(
          controller: _authorCtrl,
          hint: LocaleKeys.enter_author.tr(),
          icon: Icons.person,
          keyboardType: TextInputType.name,
          maxLines: 5,
          maxLength: 255,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  final result = _updateBooksAuthor(selectedBookIds);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result
                            ? LocaleKeys.update_successful_message.tr()
                            : LocaleKeys.bulk_update_unsuccessful_message.tr(),
                      ),
                    ),
                  );
                },
                child: Text(LocaleKeys.save.tr()),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  BookTypeDropdown _buildEditFormat(
      Set<int> selectedBookIds, BuildContext context) {
    return BookTypeDropdown(
      bookTypes: bookTypes,
      changeBookType: (bookType) {
        if (bookType == null) return;
        _updateBooksFormat(bookType, selectedBookIds);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.update_successful_message.tr()),
          ),
        );
      },
    );
  }

  Row _buildHeader(BulkEditOption bulkEditOption) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          _getLabel(bulkEditOption),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Container _buildTopLine(BuildContext context) {
    return Container(
      height: 3,
      width: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
