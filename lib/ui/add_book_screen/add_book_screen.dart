import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/cover_view_edit.dart';
import 'package:openreads/ui/add_book_screen/widgets/reading_time_field.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({
    Key? key,
    this.fromOpenLibrary = false,
    this.fromOpenLibraryEdition = false,
    this.editingExistingBook = false,
    this.coverOpenLibraryID,
    this.work,
  }) : super(key: key);

  final bool fromOpenLibrary;
  final bool fromOpenLibraryEdition;
  final bool editingExistingBook;
  final int? coverOpenLibraryID;
  final String? work;

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _pubYearCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _olidCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _myReviewCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _animDuration = const Duration(milliseconds: 250);

  bool _isCoverDownloading = false;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl =
      '${coverBaseUrl}b/id/${widget.coverOpenLibraryID}-L.jpg';

  List<String> bookTypes = [
    LocaleKeys.book_format_paperback.tr(),
    LocaleKeys.book_format_hardcover.tr(),
    LocaleKeys.book_format_ebook.tr(),
    LocaleKeys.book_format_audiobook.tr(),
  ];

  void _prefillBookDetails(Book book) {
    _titleCtrl.text = book.title;
    _subtitleCtrl.text = book.subtitle ?? '';
    _authorCtrl.text = book.author;
    _pubYearCtrl.text = (book.publicationYear ?? '').toString();
    _pagesCtrl.text = (book.pages ?? '').toString();
    _descriptionCtrl.text = book.description ?? '';
    _isbnCtrl.text = book.isbn ?? '';
    _olidCtrl.text = book.olid ?? '';
    _myReviewCtrl.text = book.myReview ?? '';
    _notesCtrl.text = book.notes ?? '';

    if (!widget.fromOpenLibrary && !widget.fromOpenLibraryEdition) {
      context.read<EditBookCoverCubit>().setCover(book.getCoverFile());
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  bool _validate() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final book = context.read<EditBookCubit>().state;

    if (book.title.isEmpty) {
      _showSnackbar(LocaleKeys.title_cannot_be_empty.tr());
      return false;
    }

    if (book.author.isEmpty) {
      _showSnackbar(LocaleKeys.author_cannot_be_empty.tr());
      return false;
    }

    if (book.status == 0) {
      if (book.startDate != null && book.finishDate != null) {
        if (book.finishDate!.isBefore(book.startDate!)) {
          _showSnackbar(LocaleKeys.finish_date_before_start.tr());
          return false;
        }
      }
    }

    return true;
  }

  void _saveBook(Book book) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_validate()) return;

    if (book.hasCover == false) {
      context.read<EditBookCoverCubit>().deleteCover(book.id);
      context.read<EditBookCubit>().addNewBook(null);
    } else {
      final cover = context.read<EditBookCoverCubit>().state;
      context.read<EditBookCubit>().addNewBook(cover);
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (widget.fromOpenLibrary) {
      Navigator.pop(context);
      if (!widget.fromOpenLibraryEdition) return;
      Navigator.pop(context);
    }
  }

  void _updateBook(Book book) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_validate()) return;

    if (book.hasCover == false) {
      context.read<EditBookCoverCubit>().deleteCover(book.id);
      context.read<EditBookCubit>().updateBook(null, context);
    } else {
      final cover = context.read<EditBookCoverCubit>().state;
      context.read<EditBookCubit>().updateBook(cover, context);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _changeBookType(String? bookType) {
    if (bookType == null) return;

    if (bookType == bookTypes[0]) {
      context.read<EditBookCubit>().setBookFormat(BookFormat.paperback);
    } else if (bookType == bookTypes[1]) {
      context.read<EditBookCubit>().setBookFormat(BookFormat.hardcover);
    } else if (bookType == bookTypes[2]) {
      context.read<EditBookCubit>().setBookFormat(BookFormat.ebook);
    } else if (bookType == bookTypes[3]) {
      context.read<EditBookCubit>().setBookFormat(BookFormat.audiobook);
    } else {
      context.read<EditBookCubit>().setBookFormat(BookFormat.paperback);
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _showStartDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: LocaleKeys.select_start_date.tr(),
    );

    if (mounted && startDate != null) {
      context.read<EditBookCubit>().setStartDate(startDate);
    }
  }

  void _showFinishDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final finishDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: LocaleKeys.select_finish_date.tr(),
    );

    if (mounted && finishDate != null) {
      context.read<EditBookCubit>().setFinishDate(finishDate);
    }
  }

  void _clearStartDate() {
    context.read<EditBookCubit>().setStartDate(null);
  }

  void _clearFinishDate() {
    context.read<EditBookCubit>().setFinishDate(null);
  }

  void _downloadCover() async {
    setState(() {
      _isCoverDownloading = true;
    });

    http.get(Uri.parse(coverUrl)).then((response) async {
      if (!mounted) return;
      final tmpCoverTimestamp = DateTime.now().millisecondsSinceEpoch;
      final tmpFile = File('${appTempDirectory.path}/$tmpCoverTimestamp.jpg');
      await tmpFile.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      await generateBlurHash(response.bodyBytes, context);

      if (!mounted) return;
      context.read<EditBookCoverCubit>().setCover(tmpFile);
      context.read<EditBookCubit>().setHasCover(true);

      setState(() {
        _isCoverDownloading = false;
      });
    });
  }

  void _downloadWork() async {
    if (widget.work != null) {
      final openLibraryWork = await OpenLibraryService().getWork(widget.work!);
      setState(() {
        if (openLibraryWork.description != null) {
          _descriptionCtrl.text = openLibraryWork.description ?? '';
        }
      });
    }
  }

  Widget _buildCover() {
    if (_isCoverDownloading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: LoadingAnimationWidget.threeArchedCircle(
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
      );
    } else {
      return const CoverViewEdit();
    }
  }

  void _addNewTag() {
    context.read<EditBookCubit>().addNewTag(_tagsCtrl.text);

    _tagsCtrl.clear();
  }

  void _unselectTag(String tag) {
    context.read<EditBookCubit>().removeTag(tag);
  }

  _attachListeners() {
    _titleCtrl.addListener(() {
      context.read<EditBookCubit>().setTitle(_titleCtrl.text);
    });

    _subtitleCtrl.addListener(() {
      context.read<EditBookCubit>().setSubtitle(_subtitleCtrl.text);
    });

    _authorCtrl.addListener(() {
      context.read<EditBookCubit>().setAuthor(_authorCtrl.text);
    });

    _pagesCtrl.addListener(() {
      context.read<EditBookCubit>().setPages(_pagesCtrl.text);
    });

    _descriptionCtrl.addListener(() {
      context.read<EditBookCubit>().setDescription(_descriptionCtrl.text);
    });

    _isbnCtrl.addListener(() {
      context.read<EditBookCubit>().setISBN(_isbnCtrl.text);
    });

    _olidCtrl.addListener(() {
      context.read<EditBookCubit>().setOLID(_olidCtrl.text);
    });

    _pubYearCtrl.addListener(() {
      context.read<EditBookCubit>().setPublicationYear(_pubYearCtrl.text);
    });

    _myReviewCtrl.addListener(() {
      context.read<EditBookCubit>().setMyReview(_myReviewCtrl.text);
    });

    _notesCtrl.addListener(() {
      context.read<EditBookCubit>().setNotes(_notesCtrl.text);
    });
  }

  @override
  void initState() {
    _prefillBookDetails(context.read<EditBookCubit>().state);
    _attachListeners();

    if (widget.fromOpenLibrary || widget.fromOpenLibraryEdition) {
      if (widget.coverOpenLibraryID != null) {
        _downloadCover();
      }

      if (widget.fromOpenLibrary) {
        _downloadWork();
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    _pubYearCtrl.dispose();
    _descriptionCtrl.dispose();
    _isbnCtrl.dispose();
    _olidCtrl.dispose();
    _tagsCtrl.dispose();
    _myReviewCtrl.dispose();
    _notesCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingExistingBook
              ? LocaleKeys.edit_book.tr()
              : LocaleKeys.add_new_book.tr(),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          BlocBuilder<EditBookCubit, Book>(
            builder: (context, state) {
              return TextButton(
                onPressed: (state.id != null)
                    ? () => _updateBook(state)
                    : () => _saveBook(state),
                child: Text(
                  LocaleKeys.save.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCover(),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Divider(),
            ),
            BookTextField(
              controller: _titleCtrl,
              hint: LocaleKeys.enter_title.tr(),
              icon: Icons.book,
              keyboardType: TextInputType.name,
              autofocus: (widget.fromOpenLibrary || widget.editingExistingBook)
                  ? false
                  : true,
              maxLines: 5,
              maxLength: 255,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _subtitleCtrl,
              hint: LocaleKeys.enter_subtitle.tr(),
              icon: Icons.book,
              keyboardType: TextInputType.name,
              maxLines: 5,
              maxLength: 255,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _authorCtrl,
              hint: LocaleKeys.enter_author.tr(),
              icon: Icons.person,
              keyboardType: TextInputType.name,
              maxLines: 5,
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Divider(),
            ),
            BookTypeDropdown(
              bookTypes: bookTypes,
              changeBookType: _changeBookType,
            ),
            const SizedBox(height: 10),
            BookStatusRow(
              animDuration: _animDuration,
              defaultHeight: defaultFormHeight,
            ),
            const SizedBox(height: 10),
            BookRatingBar(animDuration: _animDuration),
            DateRow(
              animDuration: _animDuration,
              defaultHeight: defaultFormHeight,
              showStartDatePicker: _showStartDatePicker,
              showFinishDatePicker: _showFinishDatePicker,
              clearStartDate: _clearStartDate,
              clearFinishDate: _clearFinishDate,
            ),
            const BookReadingTimeField(defaultHeight: defaultFormHeight),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Divider(),
            ),
            Row(
              children: [
                Expanded(
                  child: BookTextField(
                    controller: _pagesCtrl,
                    hint: LocaleKeys.enter_pages.tr(),
                    icon: FontAwesomeIcons.solidFileLines,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 10,
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                  ),
                ),
                Expanded(
                  child: BookTextField(
                    controller: _pubYearCtrl,
                    hint: LocaleKeys.enter_publication_year.tr(),
                    icon: FontAwesomeIcons.solidCalendar,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 4,
                    padding: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _descriptionCtrl,
              hint: LocaleKeys.enter_description.tr(),
              icon: FontAwesomeIcons.solidKeyboard,
              keyboardType: TextInputType.multiline,
              maxLength: 5000,
              hideCounter: false,
              maxLines: 15,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _isbnCtrl,
              hint: LocaleKeys.isbn.tr(),
              icon: FontAwesomeIcons.i,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: 20,
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _olidCtrl,
              hint: LocaleKeys.open_library_ID.tr(),
              icon: FontAwesomeIcons.o,
              keyboardType: TextInputType.text,
              maxLength: 20,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<String>>(
              stream: bookCubit.tags,
              builder: (context, AsyncSnapshot<List<String>?> snapshot) {
                return TagsField(
                  controller: _tagsCtrl,
                  hint: LocaleKeys.enter_tags.tr(),
                  icon: FontAwesomeIcons.tags,
                  keyboardType: TextInputType.text,
                  maxLength: 20,
                  onSubmitted: (_) => _addNewTag(),
                  onEditingComplete: () {},
                  unselectTag: (tag) => _unselectTag(tag),
                  allTags: snapshot.data,
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Divider(),
            ),
            BookTextField(
              controller: _myReviewCtrl,
              hint: LocaleKeys.my_review.tr(),
              icon: FontAwesomeIcons.solidKeyboard,
              keyboardType: TextInputType.multiline,
              maxLength: 5000,
              hideCounter: false,
              maxLines: 15,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            BookTextField(
              controller: _notesCtrl,
              hint: LocaleKeys.notes.tr(),
              icon: FontAwesomeIcons.noteSticky,
              keyboardType: TextInputType.multiline,
              maxLength: 5000,
              hideCounter: false,
              maxLines: 15,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  flex: 10,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Center(
                      child: Text("Cancel"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 19,
                  child: BlocBuilder<EditBookCubit, Book>(
                    builder: (context, state) {
                      return FilledButton(
                        onPressed: (state.id != null)
                            ? () => _updateBook(state)
                            : () => _saveBook(state),
                        child: const Center(
                          child: Text("Save"),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
