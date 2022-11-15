import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class AddBook extends StatefulWidget {
  const AddBook({
    Key? key,
    required this.topPadding,
    required this.previousThemeData,
    this.fromOpenLibrary = false,
    this.fromOpenLibraryEdition = false,
    this.editingExistingBook = false,
    this.book,
    this.cover,
  }) : super(key: key);

  final double topPadding;
  final ThemeData previousThemeData;
  final Book? book;
  final bool fromOpenLibrary;
  final bool fromOpenLibraryEdition;
  final bool editingExistingBook;
  final int? cover;

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _pubYearCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _olidCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _myReviewCtrl = TextEditingController();

  final _flex = [1, 1, 1, 1];
  final _animDuration = const Duration(milliseconds: 250);
  final _defaultHeight = 60.0;

  late List<Color> _backgroundColors;
  late List<Color> _colors;

  int? _status;
  int? _rating;

  DateTime? _startDate;
  DateTime? _finishDate;

  CroppedFile? croppedPhoto;
  CroppedFile? croppedPhotoPreview;

  XFile? photoXFile;

  Uint8List? coverForEdit;
  Uint8List? coverFromOL;

  String? blurHashString;

  List<String>? tags;
  List<String>? selectedTags;

  static const String coverBaseUrl = 'https://covers.openlibrary.org/';
  late final String coverUrl = '${coverBaseUrl}b/id/${widget.cover}-L.jpg';

  void _prefillBookDetails() {
    _titleCtrl.text = widget.book?.title ?? '';
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

    coverForEdit = widget.book?.cover;

    if (widget.book?.rating != null) {
      _rating = widget.book!.rating!;
    }

    if (widget.book?.status != null && !widget.fromOpenLibrary) {
      _changeBookStatus(widget.book!.status);
    }

    blurHashString = widget.book?.blurHash;

    if (widget.book?.tags != null) {
      tags = widget.book!.tags!.split('|');
      selectedTags = widget.book!.tags!.split('|');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  bool _validate() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (_titleCtrl.text.isEmpty) {
      _showSnackbar('Title cannot be empty');
      return false;
    }

    if (_authorCtrl.text.isEmpty) {
      _showSnackbar('Author cannot be empty');
      return false;
    }

    if (_status == null) {
      _showSnackbar('Set book status');
      return false;
    }

    if (_startDate != null && _finishDate != null) {
      if (_finishDate!.isBefore(_startDate!)) {
        _showSnackbar('Start date cannot be before finish date');
        return false;
      }
    }

    return true;
  }

  void _saveBook() async {
    if (!_validate()) return;

    late Uint8List? cover;

    if (widget.fromOpenLibrary) {
      cover = coverFromOL;
    } else if (croppedPhoto != null) {
      cover = await croppedPhoto!.readAsBytes();
    } else {
      cover = null;
    }

    bookCubit.addBook(Book(
      title: _titleCtrl.text,
      author: _authorCtrl.text,
      status: _status!,
      favourite: false,
      rating: (_rating == 0) ? null : _rating,
      startDate: _startDate?.toIso8601String(),
      finishDate: _finishDate?.toIso8601String(),
      pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
      publicationYear:
          _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
      isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
      olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
      tags: selectedTags?.join('|'),
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

    late Uint8List? cover;

    if (croppedPhoto != null) {
      cover = await croppedPhoto!.readAsBytes();
    } else {
      cover = coverForEdit;
    }

    bookCubit.updateBook(Book(
      id: widget.book?.id,
      title: _titleCtrl.text,
      author: _authorCtrl.text,
      status: _status!,
      favourite: false,
      rating: (_rating == 0) ? null : _rating,
      startDate: _startDate?.toIso8601String(),
      finishDate: _finishDate?.toIso8601String(),
      pages: _pagesCtrl.text.isEmpty ? null : int.parse(_pagesCtrl.text),
      publicationYear:
          _pubYearCtrl.text.isEmpty ? null : int.parse(_pubYearCtrl.text),
      isbn: _isbnCtrl.text.isEmpty ? null : _isbnCtrl.text,
      olid: _olidCtrl.text.isEmpty ? null : _olidCtrl.text,
      tags: selectedTags?.join('|'),
      myReview: _myReviewCtrl.text.isEmpty ? null : _myReviewCtrl.text,
      cover: cover,
      blurHash: blurHashString,
    ));

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _loadCoverFromStorage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) return;

    croppedPhoto = await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: photoXFile!.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit cover',
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black87,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor:
              (mounted) ? Theme.of(context).primaryColor : Colors.teal,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (croppedPhoto == null) return;

    setState(() {
      coverForEdit = null;
      croppedPhotoPreview = croppedPhoto;
    });

    _generateBlurHash();
  }

  void _changeBookStatus(int position) {
    _status = position;
    _animateBookStatus(position);
  }

  void _animateBookStatus(int position) {
    FocusManager.instance.primaryFocus?.unfocus();

    _flex.asMap().forEach((index, value) {
      if (position == index) {
        setState(() {
          _flex[index] = 2;
          _colors[index] = Colors.white;
          _backgroundColors[index] = widget.previousThemeData.primaryColor;
        });
      } else {
        setState(() {
          _flex[index] = 1;
          _colors[index] = widget.previousThemeData.secondaryTextColor;
          _backgroundColors[index] = widget.previousThemeData.backgroundColor;
        });
      }
    });
  }

  void _showStartDatePicker() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      helpText: 'Select reading start date',
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
      helpText: 'Select reading finish date',
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
    late Uint8List data;

    if (croppedPhotoPreview == null &&
        coverForEdit == null &&
        coverFromOL == null) return;

    if (croppedPhotoPreview != null) {
      data = await croppedPhotoPreview!.readAsBytes();
    }

    if (coverForEdit != null) {
      data = coverForEdit!;
    }

    if (coverFromOL != null) {
      data = coverFromOL!;
    }

    final image = img.decodeImage(data.toList());

    if (!mounted) return;

    setState(() {
      blurHashString = blurhash_dart.BlurHash.encode(
        image!,
        numCompX: 4,
        numCompY: 3,
      ).hash;
    });
  }

  void _downloadCover() {
    http.get(Uri.parse(coverUrl)).then((response) {
      if (mounted) {
        setState(() {
          coverFromOL = response.bodyBytes;
        });
        _generateBlurHash();
      }
    });
  }

  Widget _buildCover() {
    if (widget.fromOpenLibrary) {
      if (coverFromOL == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: LoadingAnimationWidget.inkDrop(
            color: Theme.of(context).primaryColor,
            size: 42,
          ),
        );
      } else {
        return CoverView(
          photoBytes: coverFromOL,
          onPressed: _loadCoverFromStorage,
        );
      }
    }

    if (coverForEdit != null) {
      return CoverView(
        photoBytes: coverForEdit,
        onPressed: _loadCoverFromStorage,
      );
    } else {
      if (croppedPhotoPreview != null) {
        return CoverView(
          croppedPhotoPreview: croppedPhotoPreview,
          onPressed: _loadCoverFromStorage,
        );
      } else {
        return CoverPlaceholder(
          defaultHeight: _defaultHeight,
          onPressed: _loadCoverFromStorage,
        );
      }
    }
  }

  void _addNewTag() {
    late String newTag;

    if (_tagsCtrl.text.substring(_tagsCtrl.text.length - 1) == ' ') {
      newTag = _tagsCtrl.text.substring(0, _tagsCtrl.text.length - 1);
    } else {
      newTag = _tagsCtrl.text;
    }

    // Pipe chars are reserved for storing tags list in DB
    newTag = newTag.replaceAll('|', '');

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

    bool removeTag = true;

    while (removeTag) {
      setState(() => removeTag = selectedTags!.remove(tag));
    }
  }

  @override
  void initState() {
    super.initState();

    _colors = [
      widget.previousThemeData.secondaryTextColor,
      widget.previousThemeData.secondaryTextColor,
      widget.previousThemeData.secondaryTextColor,
      widget.previousThemeData.secondaryTextColor,
    ];

    _backgroundColors = [
      widget.previousThemeData.backgroundColor,
      widget.previousThemeData.backgroundColor,
      widget.previousThemeData.backgroundColor,
      widget.previousThemeData.backgroundColor,
    ];

    if (widget.book != null) {
      _prefillBookDetails();
    }

    if (widget.fromOpenLibrary) {
      _downloadCover();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    _pubYearCtrl.dispose();
    _isbnCtrl.dispose();
    _olidCtrl.dispose();
    _myReviewCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 50;
    List<double> widths = [
      (_flex[0] * width) / (_flex[0] + _flex[1] + _flex[2] + _flex[3]),
      (_flex[1] * width) / (_flex[0] + _flex[1] + _flex[2] + _flex[3]),
      (_flex[2] * width) / (_flex[0] + _flex[1] + _flex[2] + _flex[3]),
      (_flex[3] * width) / (_flex[0] + _flex[1] + _flex[2] + _flex[3])
    ];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: widget.topPadding),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.editingExistingBook ? 'Edit book' : 'Add new book',
              style: const TextStyle(fontSize: 18),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              TextButton(
                onPressed: (widget.book != null && !widget.fromOpenLibrary)
                    ? _updateBook
                    : _saveBook,
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).mainTextColor,
                  ),
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
                    hint: 'Enter a title',
                    icon: Icons.book,
                    keyboardType: TextInputType.name,
                    autofocus:
                        (widget.fromOpenLibrary || widget.editingExistingBook)
                            ? false
                            : true,
                    maxLines: 5,
                    maxLength: 255,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                  BookTextField(
                    controller: _authorCtrl,
                    hint: 'Enter an author',
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
                    colors: _colors,
                    backgroundColors: _backgroundColors,
                    widths: widths,
                    onPressed: _changeBookStatus,
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
                          hint: 'Number of pages',
                          icon: Icons.numbers,
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
                          hint: 'Publication year',
                          icon: Icons.calendar_month,
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
                    hint: 'ISBN',
                    icon: Icons.pin,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 20,
                  ),
                  const SizedBox(height: 20),
                  BookTextField(
                    controller: _olidCtrl,
                    hint: 'Open Library ID',
                    icon: Icons.pin,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 20),
                  TagsField(
                    controller: _tagsCtrl,
                    hint: 'Tags',
                    icon: Icons.sell,
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
                    hint: 'My review',
                    icon: Icons.message,
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
                        child: SizedBox(
                          height: 51,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  Theme.of(context).secondaryTextColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 19,
                        child: SizedBox(
                          height: 51,
                          child: ElevatedButton(
                            onPressed:
                                (widget.book != null && !widget.fromOpenLibrary)
                                    ? _updateBook
                                    : _saveBook,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
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
        ),
      ),
    );
  }
}
