import 'dart:io';

import 'package:blurhash/blurhash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({
    Key? key,
    this.fromOpenLibrary = false,
    this.fromOpenLibraryEdition = false,
    this.editingExistingBook = false,
    this.book,
    this.cover,
    this.work,
  }) : super(key: key);

  final Book? book;
  final bool fromOpenLibrary;
  final bool fromOpenLibraryEdition;
  final bool editingExistingBook;
  final int? cover;
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

  final _animDuration = const Duration(milliseconds: 250);
  final _defaultHeight = 60.0;

  int? _status;
  int? _rating;
  BookType _bookType = BookType.paper;

  DateTime? _startDate;
  DateTime? _finishDate;

  File? coverFile;

  String? blurHashString;

  List<String>? tags;
  List<String>? selectedTags;

  bool _isCoverDownloading = false;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/id/${widget.cover}-L.jpg';

  List<String> bookTypes = [
    LocaleKeys.book_type_paper.tr(),
    LocaleKeys.book_type_ebook.tr(),
    LocaleKeys.book_type_audiobook.tr(),
  ];

  void _prefillBookDetails() {
    _titleCtrl.text = widget.book?.title ?? '';
    _subtitleCtrl.text = widget.book?.subtitle ?? '';
    _authorCtrl.text = widget.book?.author ?? '';
    _pubYearCtrl.text = (widget.book?.publicationYear ?? '').toString();
    _pagesCtrl.text = (widget.book?.pages ?? '').toString();
    _descriptionCtrl.text = widget.book?.description ?? '';
    _isbnCtrl.text = widget.book?.isbn ?? '';
    _olidCtrl.text = widget.book?.olid ?? '';
    _myReviewCtrl.text = widget.book?.myReview ?? '';
    _bookType = widget.book?.bookType ?? BookType.paper;

    if (widget.book != null && widget.book!.startDate != null) {
      _startDate = DateTime.parse(widget.book!.startDate!);
    }

    if (widget.book != null && widget.book!.finishDate != null) {
      _finishDate = DateTime.parse(widget.book!.finishDate!);
    }

    coverFile = widget.book!.getCoverFile();

    if (widget.book?.rating != null) {
      _rating = widget.book!.rating!;
    }

    if (widget.book?.status != null && !widget.fromOpenLibrary) {
      _changeBookStatus(widget.book!.status, false);
    }

    blurHashString = widget.book?.blurHash;

    if (widget.book?.tags != null) {
      tags = widget.book!.tags!.split('|||||');
      selectedTags = widget.book!.tags!.split('|||||');
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

    if (_titleCtrl.text.isEmpty) {
      _showSnackbar(LocaleKeys.title_cannot_be_empty.tr());
      return false;
    }

    if (_authorCtrl.text.isEmpty) {
      _showSnackbar(LocaleKeys.author_cannot_be_empty.tr());
      return false;
    }

    if (_status == null) {
      _showSnackbar(LocaleKeys.set_book_status.tr());
      return false;
    }

    if (_status == 0) {
      if (_startDate != null && _finishDate != null) {
        if (_finishDate!.isBefore(_startDate!)) {
          _showSnackbar(LocaleKeys.finish_date_before_start.tr());
          return false;
        }
      }
    }

    return true;
  }

  void _saveBook() async {
    if (!_validate()) return;

    bookCubit.addBook(
      Book(
        title: _titleCtrl.text,
        subtitle: _subtitleCtrl.text.isNotEmpty ? _subtitleCtrl.text : null,
        author: _authorCtrl.text,
        status: _status!,
        favourite: false,
        rating: (_status == 0 && _rating != 0) ? _rating : null,
        startDate: (_status == 0 || _status == 1)
            ? _startDate?.toIso8601String()
            : null,
        finishDate: _status == 0 ? _finishDate?.toIso8601String() : null,
        pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
        publicationYear:
            _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
        description:
            _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
        olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
        tags: (selectedTags == null || selectedTags!.isEmpty)
            ? null
            : selectedTags?.join('|||||'),
        myReview: _myReviewCtrl.text.isEmpty ? null : _myReviewCtrl.text,
        blurHash: blurHashString,
        bookType: _bookType,
      ),
      coverFile: coverFile,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (widget.fromOpenLibrary) {
      Navigator.pop(context);
      if (!widget.fromOpenLibraryEdition) return;
      Navigator.pop(context);
    }
  }

  void _updateBook() async {
    if (!_validate()) return;

    bookCubit.updateBook(
      Book(
        id: widget.book?.id,
        title: _titleCtrl.text,
        subtitle: _subtitleCtrl.text.isNotEmpty ? _subtitleCtrl.text : null,
        author: _authorCtrl.text,
        status: _status!,
        favourite: false,
        rating: (_status == 0 && _rating != 0) ? _rating : null,
        startDate: (_status == 0 || _status == 1)
            ? _startDate?.toIso8601String()
            : null,
        finishDate: _status == 0 ? _finishDate?.toIso8601String() : null,
        pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
        publicationYear:
            _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
        description:
            _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
        olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
        tags: (selectedTags == null || selectedTags!.isEmpty)
            ? null
            : selectedTags?.join('|||||'),
        myReview: _myReviewCtrl.text.isEmpty ? null : _myReviewCtrl.text,
        blurHash: blurHashString,
        bookType: _bookType,
      ),
      coverFile: coverFile,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _loadCoverFromStorage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final colorScheme = Theme.of(context).colorScheme;

    final photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) return;

    final croppedPhoto = await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: photoXFile.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: LocaleKeys.edit_cover.tr(),
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: colorScheme.surface,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor: colorScheme.primary,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (croppedPhoto == null) return;
    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    final coversDir = (await getApplicationDocumentsDirectory()).path;

    final coverFileForSaving = File('$coversDir/cover_placeholder.jpg');
    await coverFileForSaving.writeAsBytes(croppedPhotoBytes);

    setState(() {
      coverFile = coverFileForSaving;
    });

    _generateBlurHash(croppedPhotoBytes);
  }

  void _changeBookStatus(int position, bool updateDates) {
    setState(() {
      _status = position;
    });

    final dateNow = DateTime.now();
    final date = DateTime(dateNow.year, dateNow.month, dateNow.day);

    if (updateDates) {
      if (position == 0) {
        _finishDate ??= date;
      } else if (position == 1) {
        _startDate ??= date;
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _changeBookType(String? bookType) {
    if (bookType == null) return;

    if (bookType == bookTypes[0]) {
      setState(() {
        _bookType = BookType.paper;
      });
    } else if (bookType == bookTypes[1]) {
      setState(() {
        _bookType = BookType.ebook;
      });
    } else if (bookType == bookTypes[2]) {
      setState(() {
        _bookType = BookType.audiobook;
      });
    } else {
      setState(() {
        _bookType = BookType.paper;
      });
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

    if (startDate != null) {
      setState(() {
        _startDate = startDate;
      });
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

    if (finishDate != null) {
      setState(() {
        _finishDate = finishDate;
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
    });
  }

  void _clearFinishDate() {
    setState(() {
      _finishDate = null;
    });
  }

  void changeRating(double rating) {
    _rating = (rating * 10).toInt();
  }

  void _generateBlurHash(Uint8List bytes) async {
    if (coverFile == null) return;

    if (!mounted) return;

    final blurHashStringTmp = await BlurHash.encode(bytes, 4, 3);

    setState(() {
      blurHashString = blurHashStringTmp;
    });
  }

  void _downloadCover() async {
    setState(() {
      _isCoverDownloading = true;
    });

    final coversDir = (await getApplicationDocumentsDirectory()).path;

    http.get(Uri.parse(coverUrl)).then((response) async {
      if (mounted) {
        setState(() {
          coverFile = File('$coversDir/cover_placeholder.jpg');
        });

        await coverFile!.writeAsBytes(response.bodyBytes);

        setState(() {
          _isCoverDownloading = false;
        });

        _generateBlurHash(response.bodyBytes);
      }
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
      if (coverFile != null) {
        return CoverView(
          book: widget.book,
          onPressed: _loadCoverFromStorage,
          deleteCover: _deleteCover,
          coverFile: coverFile,
          blurHashString: blurHashString,
        );
      } else {
        return CoverPlaceholder(
          defaultHeight: _defaultHeight,
          onPressed: _loadCoverFromStorage,
        );
      }
    }
  }

  _deleteCover() async {
    final coversDir = (await getApplicationDocumentsDirectory()).path;

    final coverExists = await File(
      '$coversDir/${widget.book!.id}.jpg',
    ).exists();

    if (coverExists) {
      await File('$coversDir/${widget.book!.id}.jpg').delete();
    }

    final coverPlaceholderExists = await File(
      '$coversDir/cover_placeholder.jpg',
    ).exists();

    if (coverPlaceholderExists) {
      await File('$coversDir/cover_placeholder.jpg').delete();
    }

    setState(() {
      coverFile = null;
      blurHashString = null;
    });
  }

  void _addNewTag() {
    late String newTag;

    if (_tagsCtrl.text.substring(_tagsCtrl.text.length - 1) == ' ') {
      newTag = _tagsCtrl.text.substring(0, _tagsCtrl.text.length - 1);
    } else {
      newTag = _tagsCtrl.text;
    }

    // Pipe chars are reserved for storing tags list in DB
    newTag =
        newTag.replaceAll('|', ''); //TODO: add same for @ in all needed places

    if (tags == null) {
      setState(() => tags = [newTag]);
    } else {
      setState(() => tags!.add(newTag));
    }

    _selectTag(newTag);

    _tagsCtrl.clear();
  }

  void _selectTag(tag) {
    if (selectedTags == null) {
      setState(() => selectedTags = [tag]);
    } else {
      setState(() => selectedTags!.add(tag));
    }
  }

  void _unselectTag(tag) {
    if (selectedTags == null) return;

    setState(() {
      selectedTags!.removeWhere((element) => element == tag);
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.book != null) {
      _prefillBookDetails();
    }

    if (widget.fromOpenLibrary || widget.fromOpenLibraryEdition) {
      if (widget.cover != null) {
        _downloadCover();
      }
      if (widget.fromOpenLibrary) {
        _downloadWork();
      }
    }
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
          TextButton(
            onPressed: (widget.book != null && !widget.fromOpenLibrary)
                ? _updateBook
                : _saveBook,
            child: Text(
              LocaleKeys.save.tr(),
              style: const TextStyle(fontSize: 16),
            ),
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
              bookType: _bookType,
              bookTypes: bookTypes,
              changeBookType: _changeBookType,
            ),
            const SizedBox(height: 10),
            BookStatusRow(
              animDuration: _animDuration,
              defaultHeight: _defaultHeight,
              onPressed: _changeBookStatus,
              currentStatus: _status,
            ),
            const SizedBox(height: 10),
            BookRatingBar(
              animDuration: _animDuration,
              status: _status,
              defaultHeight: _defaultHeight,
              rating: (_rating == null) ? 0.0 : _rating! / 10,
              onRatingUpdate: changeRating,
            ),
            AnimatedContainer(
              duration: _animDuration,
              height: (_status == 0) ? 10 : 0,
            ),
            DateRow(
              animDuration: _animDuration,
              status: _status,
              defaultHeight: _defaultHeight,
              startDate: _startDate,
              finishDate: _finishDate,
              showStartDatePicker: _showStartDatePicker,
              showFinishDatePicker: _showFinishDatePicker,
              clearStartDate: _clearStartDate,
              clearFinishDate: _clearFinishDate,
              showClearStartDate: (_startDate == null) ? false : true,
              showClearFinishDate: (_finishDate == null) ? false : true,
            ),
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
                  tags: tags,
                  selectedTags: selectedTags,
                  onSubmitted: (_) => _addNewTag(),
                  onEditingComplete: () {},
                  selectTag: (tag) => _selectTag(tag),
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
                  child: FilledButton(
                    onPressed: (widget.book != null && !widget.fromOpenLibrary)
                        ? _updateBook
                        : _saveBook,
                    child: const Center(
                      child: Text("Save"),
                    ),
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
