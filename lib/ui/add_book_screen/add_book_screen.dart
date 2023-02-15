import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({
    Key? key,
    this.fromOpenLibrary = false,
    this.fromOpenLibraryEdition = false,
    this.editingExistingBook = false,
    this.book,
    this.cover,
  }) : super(key: key);

  final Book? book;
  final bool fromOpenLibrary;
  final bool fromOpenLibraryEdition;
  final bool editingExistingBook;
  final int? cover;

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _pubYearCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _olidCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _myReviewCtrl = TextEditingController();

  final _animDuration = const Duration(milliseconds: 250);
  final _defaultHeight = 60.0;

  int? _status;
  int? _rating;

  DateTime? _startDate;
  DateTime? _finishDate;

  Uint8List? cover;

  String? blurHashString;

  List<String>? tags;
  List<String>? selectedTags;

  bool _isCoverDownloading = false;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/id/${widget.cover}-L.jpg';

  void _prefillBookDetails() {
    _titleCtrl.text = widget.book?.title ?? '';
    _subtitleCtrl.text = widget.book?.subtitle ?? '';
    _authorCtrl.text = widget.book?.author ?? '';
    _pubYearCtrl.text = (widget.book?.publicationYear ?? '').toString();
    _pagesCtrl.text = (widget.book?.pages ?? '').toString();
    _isbnCtrl.text = widget.book?.isbn ?? '';
    _olidCtrl.text = widget.book?.olid ?? '';
    _myReviewCtrl.text = widget.book?.myReview ?? '';

    if (widget.book != null && widget.book!.startDate != null) {
      _startDate = DateTime.parse(widget.book!.startDate!);
    }

    if (widget.book != null && widget.book!.finishDate != null) {
      _finishDate = DateTime.parse(widget.book!.finishDate!);
    }

    cover = widget.book?.cover;

    if (widget.book?.rating != null) {
      _rating = widget.book!.rating!;
    }

    if (widget.book?.status != null && !widget.fromOpenLibrary) {
      _changeBookStatus(widget.book!.status);
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
      _showSnackbar(l10n.title_cannot_be_empty);
      return false;
    }

    if (_authorCtrl.text.isEmpty) {
      _showSnackbar(l10n.author_cannot_be_empty);
      return false;
    }

    if (_status == null) {
      _showSnackbar(l10n.set_book_status);
      return false;
    }

    if (_status == 0) {
      if (_startDate != null && _finishDate != null) {
        if (_finishDate!.isBefore(_startDate!)) {
          _showSnackbar(l10n.finish_date_before_start);
          return false;
        }
      }
    }

    return true;
  }

  void _saveBook() async {
    if (!_validate()) return;

    bookCubit.addBook(Book(
      title: _titleCtrl.text,
      subtitle: _subtitleCtrl.text.isNotEmpty ? _subtitleCtrl.text : null,
      author: _authorCtrl.text,
      status: _status!,
      favourite: false,
      rating: (_status == 0 && _rating != 0) ? _rating : null,
      startDate:
          (_status == 0 || _status == 1) ? _startDate?.toIso8601String() : null,
      finishDate: _status == 0 ? _finishDate?.toIso8601String() : null,
      pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
      publicationYear:
          _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
      isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
      olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
      tags: (selectedTags == null || selectedTags!.isEmpty)
          ? null
          : selectedTags?.join('|||||'),
      myReview: _myReviewCtrl.text.isEmpty ? null : _myReviewCtrl.text,
      cover: cover,
      blurHash: blurHashString,
    ));

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

    bookCubit.updateBook(Book(
      id: widget.book?.id,
      title: _titleCtrl.text,
      subtitle: _subtitleCtrl.text.isNotEmpty ? _subtitleCtrl.text : null,
      author: _authorCtrl.text,
      status: _status!,
      favourite: false,
      rating: (_status == 0 && _rating != 0) ? _rating : null,
      startDate:
          (_status == 0 || _status == 1) ? _startDate?.toIso8601String() : null,
      finishDate: _status == 0 ? _finishDate?.toIso8601String() : null,
      pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
      publicationYear:
          _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
      isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
      olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
      tags: (selectedTags == null || selectedTags!.isEmpty)
          ? null
          : selectedTags?.join('|||||'),
      myReview: _myReviewCtrl.text.isEmpty ? null : _myReviewCtrl.text,
      cover: cover,
      blurHash: blurHashString,
    ));

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _loadCoverFromStorage() async {
    FocusManager.instance.primaryFocus?.unfocus();
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
          toolbarTitle: l10n.edit_cover,
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.surface,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (croppedPhoto == null) return;
    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    setState(() {
      cover = croppedPhotoBytes;
    });

    _generateBlurHash();
  }

  void _changeBookStatus(int position) {
    setState(() {
      _status = position;
    });

    final dateNow = DateTime.now();
    final date = DateTime(dateNow.year, dateNow.month, dateNow.day);

    if (position == 0) {
      _finishDate ??= date;
    } else if (position == 1) {
      _startDate ??= date;
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
      helpText: l10n.select_start_date,
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
      helpText: l10n.select_finish_date,
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

  void _generateBlurHash() async {
    if (cover == null) return;
    final image = img.decodeImage(cover!);
    if (image == null) return;
    if (!mounted) return;

    setState(() {
      blurHashString = blurhash_dart.BlurHash.encode(
        image,
        numCompX: 4,
        numCompY: 3,
      ).hash;
    });
  }

  void _downloadCover() {
    setState(() {
      _isCoverDownloading = true;
    });

    http.get(Uri.parse(coverUrl)).then((response) {
      if (mounted) {
        setState(() {
          cover = response.bodyBytes;
          _isCoverDownloading = false;
        });
        _generateBlurHash();
      }
    });
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
      if (cover != null) {
        return CoverView(
          photoBytes: cover,
          onPressed: _loadCoverFromStorage,
          deleteCover: _deleteCover,
        );
      } else {
        return CoverPlaceholder(
          defaultHeight: _defaultHeight,
          onPressed: _loadCoverFromStorage,
        );
      }
    }
  }

  _deleteCover() {
    setState(() {
      cover = null;
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
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    _pubYearCtrl.dispose();
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
          widget.editingExistingBook ? l10n.edit_book : l10n.add_new_book,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: (widget.book != null && !widget.fromOpenLibrary)
                ? _updateBook
                : _saveBook,
            child: Text(
              l10n.save,
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              _buildCover(),
              const SizedBox(height: 20),
              BookTextField(
                controller: _titleCtrl,
                hint: l10n.enter_title,
                icon: Icons.book,
                keyboardType: TextInputType.name,
                autofocus:
                    (widget.fromOpenLibrary || widget.editingExistingBook)
                        ? false
                        : true,
                maxLines: 5,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              BookTextField(
                controller: _subtitleCtrl,
                hint: l10n.enter_subtitle,
                icon: Icons.book,
                keyboardType: TextInputType.name,
                maxLines: 5,
                maxLength: 255,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),
              BookTextField(
                controller: _authorCtrl,
                hint: l10n.enter_author,
                icon: Icons.person,
                keyboardType: TextInputType.name,
                maxLines: 5,
                maxLength: 255,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              BookStatusRow(
                animDuration: _animDuration,
                defaultHeight: _defaultHeight,
                onPressed: _changeBookStatus,
                currentStatus: _status,
              ),
              const SizedBox(height: 20),
              BookRatingBar(
                animDuration: _animDuration,
                status: _status,
                defaultHeight: _defaultHeight,
                rating: (_rating == null) ? 0.0 : _rating! / 10,
                onRatingUpdate: changeRating,
              ),
              AnimatedContainer(
                duration: _animDuration,
                height: (_status == 0) ? 20 : 0,
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
              AnimatedContainer(
                duration: _animDuration,
                height: (_status == 2 || _status == null) ? 0 : 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: BookTextField(
                      controller: _pagesCtrl,
                      hint: l10n.enter_pages,
                      icon: FontAwesomeIcons.solidFileLines,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 10,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: BookTextField(
                      controller: _pubYearCtrl,
                      hint: l10n.enter_publication_year,
                      icon: FontAwesomeIcons.solidCalendar,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      maxLength: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              BookTextField(
                controller: _isbnCtrl,
                hint: l10n.isbn,
                icon: FontAwesomeIcons.i,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                maxLength: 20,
              ),
              const SizedBox(height: 20),
              BookTextField(
                controller: _olidCtrl,
                hint: l10n.open_library_ID,
                icon: FontAwesomeIcons.o,
                keyboardType: TextInputType.text,
                maxLength: 20,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 20),
              TagsField(
                controller: _tagsCtrl,
                hint: l10n.enter_tags,
                icon: FontAwesomeIcons.tags,
                keyboardType: TextInputType.text,
                maxLength: 20,
                tags: tags,
                selectedTags: selectedTags,
                onSubmitted: (_) => _addNewTag(),
                onEditingComplete: () {},
                selectTag: (tag) => _selectTag(tag),
                unselectTag: (tag) => _unselectTag(tag),
              ),
              const SizedBox(height: 20),
              BookTextField(
                controller: _myReviewCtrl,
                hint: l10n.my_review,
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
                      onPressed:
                          (widget.book != null && !widget.fromOpenLibrary)
                              ? _updateBook
                              : _saveBook,
                      child: const Center(
                        child: Text("Save"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
