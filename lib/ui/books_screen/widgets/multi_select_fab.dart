import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_type_dropdown.dart';

class MultiSelectFAB extends StatelessWidget {
  MultiSelectFAB({
    super.key,
    required this.selectedBookIds,
    required this.resetMultiselectMode,
  });

  final Set<int> selectedBookIds;
  final Function resetMultiselectMode;

  final bookTypes = [
    LocaleKeys.book_format_paperback.tr(),
    LocaleKeys.book_format_hardcover.tr(),
    LocaleKeys.book_format_ebook.tr(),
    LocaleKeys.book_format_audiobook.tr(),
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
      default:
        label = '';
    }

    return label;
  }

  Material _buildBottomSheet(BuildContext context,
      BulkEditOption bulkEditOption, Set<int> selectedBookIds) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (Platform.isAndroid)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              _buildHeader(bulkEditOption),
              const SizedBox(height: 30),
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

  _showDeleteBooksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog.adaptive(
          shape: Platform.isAndroid
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cornerRadius),
                )
              : null,
          title: Text(
            LocaleKeys.delete_books_question.tr(),
            style: const TextStyle(fontSize: 18),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            Platform.isIOS
                ? CupertinoDialogAction(
                    child: Text(LocaleKeys.no.tr()),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                : FilledButton.tonal(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(LocaleKeys.no.tr()),
                    ),
                  ),
            Platform.isIOS
                ? CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(LocaleKeys.yes.tr()),
                    onPressed: () => _bulkDeleteBooks(context),
                  )
                : FilledButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                      ),
                    ),
                    onPressed: () => _bulkDeleteBooks(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(LocaleKeys.yes.tr()),
                    ),
                  ),
          ],
        );
      },
    );
  }

  _bulkDeleteBooks(BuildContext context) async {
    for (final bookId in selectedBookIds) {
      final book = await bookCubit.getBook(bookId);

      if (book == null) continue;

      await bookCubit.updateBook(book.copyWith(
        deleted: true,
      ));
    }

    bookCubit.getDeletedBooks();

    Navigator.of(context).pop();

    resetMultiselectMode();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: SpeedDial(
        spacing: 20,
        dialRoot: (ctx, open, toggleChildren) {
          return FloatingActionButton(
            onPressed: toggleChildren,
            child: const Icon(Icons.create),
          );
        },
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.menu_book_outlined,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            labelBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            label: LocaleKeys.change_book_format.tr(),
            onTap: () {
              if (Platform.isIOS) {
                showCupertinoModalBottomSheet(
                  context: context,
                  expand: false,
                  builder: (_) {
                    return _buildBottomSheet(
                      context,
                      BulkEditOption.format,
                      selectedBookIds,
                    );
                  },
                );
              } else if (Platform.isAndroid) {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return _buildBottomSheet(
                        context,
                        BulkEditOption.format,
                        selectedBookIds,
                      );
                    });
              }
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            labelBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            label: LocaleKeys.change_books_author.tr(),
            onTap: () {
              if (Platform.isIOS) {
                showCupertinoModalBottomSheet(
                  context: context,
                  expand: false,
                  builder: (_) {
                    return _buildBottomSheet(
                      context,
                      BulkEditOption.author,
                      selectedBookIds,
                    );
                  },
                );
              } else if (Platform.isAndroid) {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return _buildBottomSheet(
                        context,
                        BulkEditOption.author,
                        selectedBookIds,
                      );
                    });
              }
            },
          ),
          SpeedDialChild(
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            labelBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            label: LocaleKeys.delete_books.tr(),
            onTap: () => _showDeleteBooksDialog(context),
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
          padding: const EdgeInsets.all(0),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cornerRadius),
                    ),
                  ),
                ),
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
          ],
        ),
      ],
    );
  }

  BookTypeDropdown _buildEditFormat(
      Set<int> selectedBookIds, BuildContext context) {
    return BookTypeDropdown(
      bookTypes: bookTypes,
      padding: const EdgeInsets.all(0),
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
        Expanded(
          child: Text(
            _getLabel(bulkEditOption),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
