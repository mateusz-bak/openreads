import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_type_dropdown.dart';

class MultiSelectFAB extends StatelessWidget {
  MultiSelectFAB({super.key});

  final bookTypes = [
    LocaleKeys.book_format_paperback.tr(),
    LocaleKeys.book_format_hardcover.tr(),
    LocaleKeys.book_format_ebook.tr(),
    LocaleKeys.book_format_audiobook.tr(),
  ];

  final _authorCtrl = TextEditingController();

  final _publisherCtrl = TextEditingController();

  String _getLabel(BulkEditOption bulkEditOption) {
    String label = '';
    switch (bulkEditOption) {
      case BulkEditOption.format:
        label = LocaleKeys.change_book_format.tr();
        break;
      case BulkEditOption.publisher:
        label = LocaleKeys.change_books_publisher.tr();
        break;
      case BulkEditOption.author:
        label = LocaleKeys.change_books_author.tr();
        break;
      default:
        label = '';
    }

    return label;
  }

  Widget _buildBulkEdit(BulkEditOption bulkEditOption, List<int> selectedList,
      BuildContext context) {
    Widget bulkEditWidget;
    switch (bulkEditOption) {
      case BulkEditOption.format:
        bulkEditWidget = _buildEditFormat(selectedList, context);
        break;
      case BulkEditOption.publisher:
        bulkEditWidget = _buildEditPublisher(selectedList, context);
        break;
      case BulkEditOption.author:
        bulkEditWidget = _buildEditAuthor(selectedList, context);
        break;
      default:
        bulkEditWidget = const SizedBox();
    }

    return bulkEditWidget;
  }

  Material _buildBottomSheet(
    BuildContext context,
    BulkEditOption bulkEditOption,
    List<int> selectedList,
  ) {
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
              _buildBulkEdit(bulkEditOption, selectedList, context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateBooksFormat(
    BuildContext context,
    String bookType,
    List<int> selectedIds,
  ) async {
    List<Book> booksToSync = List.empty(growable: true);
    late BookFormat selectedBookType;

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

    for (final bookId in selectedIds) {
      Book? book = await bookCubit.getBook(bookId);

      if (book == null) continue;
      book = book.copyWith(bookFormat: selectedBookType);
      booksToSync.add(book);

      await bookCubit.updateBook(book);
    }

    if (!context.mounted) return;

    // context.read<PbSyncBloc>().add(TriggerSyncEvent(booksToSync: booksToSync));
  }

  Future<void> _updateBooksPublisher(
    BuildContext context,
    List<int> selectedIds,
  ) async {
    List<Book> booksToSync = List.empty(growable: true);
    final publisher = _publisherCtrl.text;

    if (publisher.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.bulk_update_unsuccessful_message.tr(),
          ),
        ),
      );
    }

    for (final bookId in selectedIds) {
      Book? book = await bookCubit.getBook(bookId);

      if (book == null) continue;
      book = book.copyWith(publisher: publisher);
      booksToSync.add(book);

      await bookCubit.updateBook(book);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.update_successful_message.tr())),
    );
  }

  Future<void> _updateBooksAuthor(
    BuildContext context,
    List<int> selectedIds,
  ) async {
    List<Book> booksToSync = List.empty(growable: true);
    final author = _authorCtrl.text;

    if (author.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.bulk_update_unsuccessful_message.tr(),
          ),
        ),
      );
    }

    for (final bookId in selectedIds) {
      Book? book = await bookCubit.getBook(bookId);

      if (book == null) continue;
      book = book.copyWith(author: author);
      booksToSync.add(book);

      await bookCubit.updateBook(book);
    }

    // if (context.mounted) {
    //   context
    //       .read<PbSyncBloc>()
    //       .add(TriggerSyncEvent(booksToSync: booksToSync));
    // }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.update_successful_message.tr())),
    );
  }

  _showDeleteBooksDialog(BuildContext context, List<int> selectedList) {
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
                    onPressed: () => _bulkDeleteBooks(context, selectedList),
                  )
                : FilledButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cornerRadius),
                        ),
                      ),
                    ),
                    onPressed: () => _bulkDeleteBooks(context, selectedList),
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

  _bulkDeleteBooks(BuildContext context, List<int> selectedList) async {
    List<Book> booksToSync = List.empty(growable: true);

    for (final bookId in selectedList) {
      Book? book = await bookCubit.getBook(bookId);

      if (book == null) continue;
      book = book.copyWith(deleted: true);
      booksToSync.add(book);

      await bookCubit.updateBook(book);
    }

    bookCubit.getDeletedBooks();

    if (!context.mounted) return;
    // context.read<PbSyncBloc>().add(TriggerSyncEvent(booksToSync: booksToSync));

    context.read<SelectedBooksCubit>().resetSelection();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedBooksCubit, List<int>>(
      builder: (context, selectedList) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 00),
          child: SpeedDial(
            spacing: 20,
            dialRoot: (ctx, open, toggleChildren) {
              return FloatingActionButton(
                onPressed: toggleChildren,
                child: const FaIcon(FontAwesomeIcons.penToSquare),
              );
            },
            childPadding: const EdgeInsets.all(5),
            spaceBetweenChildren: 10,
            children: [
              SpeedDialChild(
                child: FaIcon(
                  FontAwesomeIcons.bookOpen,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 18,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                labelBackgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
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
                          selectedList,
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
                            selectedList,
                          );
                        });
                  }
                },
              ),
              SpeedDialChild(
                child: FaIcon(
                  FontAwesomeIcons.book,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 18,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                labelBackgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                label: LocaleKeys.change_books_publisher.tr(),
                onTap: () {
                  if (Platform.isIOS) {
                    showCupertinoModalBottomSheet(
                      context: context,
                      expand: false,
                      builder: (_) {
                        return _buildBottomSheet(
                          context,
                          BulkEditOption.publisher,
                          selectedList,
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
                            BulkEditOption.publisher,
                            selectedList,
                          );
                        });
                  }
                },
              ),
              SpeedDialChild(
                child: FaIcon(
                  FontAwesomeIcons.user,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 18,
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                labelBackgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
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
                          selectedList,
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
                            selectedList,
                          );
                        });
                  }
                },
              ),
              SpeedDialChild(
                child: FaIcon(
                  FontAwesomeIcons.trash,
                  color: Theme.of(context).colorScheme.onTertiary,
                  size: 18,
                ),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                labelBackgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                label: LocaleKeys.delete_books.tr(),
                onTap: () => _showDeleteBooksDialog(context, selectedList),
              ),
            ],
          ),
        );
      },
    );
  }

  Column _buildEditAuthor(List<int> selectedList, BuildContext context) {
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
                onPressed: () => _updateBooksAuthor(context, selectedList),
                child: Text(LocaleKeys.save.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Column _buildEditPublisher(List<int> selectedList, BuildContext context) {
    return Column(
      children: [
        BookTextField(
          controller: _publisherCtrl,
          hint: LocaleKeys.enter_publisher.tr(),
          icon: Icons.library_books,
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
                onPressed: () => _updateBooksPublisher(context, selectedList),
                child: Text(LocaleKeys.save.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  BookTypeDropdown _buildEditFormat(
    List<int> selectedList,
    BuildContext context,
  ) {
    return BookTypeDropdown(
      bookTypes: bookTypes,
      padding: const EdgeInsets.all(0),
      changeBookType: (bookType) {
        if (bookType == null) return;
        _updateBooksFormat(context, bookType, selectedList);
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
