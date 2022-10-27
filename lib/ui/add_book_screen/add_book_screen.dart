import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';
import 'package:openreads/core/themes/app_theme.dart';

class AddBook extends StatefulWidget {
  const AddBook({
    Key? key,
    required this.topPadding,
    required this.previousContext,
    this.book,
  }) : super(key: key);

  final double topPadding;
  final BuildContext previousContext;
  final Book? book;

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  late TextEditingController _titleController,
      _authorController,
      _pagesController,
      _pubYearController,
      _isbnController,
      _olidController,
      _myReviewController;

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

  void _prefillBookDetails() {
    _titleController.text = widget.book?.title ?? '';
    _authorController.text = widget.book?.author ?? '';
    _pubYearController.text = widget.book?.publicationYear.toString() ?? '';
    _pagesController.text = widget.book?.pages.toString() ?? '';
    _isbnController.text = widget.book?.isbn ?? '';
    _olidController.text = widget.book?.olid ?? '';
    _myReviewController.text = widget.book?.myReview ?? '';

    coverForEdit = widget.book?.cover;

    if (widget.book?.rating != null) {
      _rating = widget.book!.rating! ~/ 10;
    }

    if (widget.book?.status != null) {
      _changeBookStatus(widget.book!.status!);
    }
  }

  //TODO: finish new book validation
  bool _validate() {
    if (_titleController.text.isEmpty) {
      return false;
    }

    if (_authorController.text.isEmpty) {
      return false;
    }

    if (_startDate != null && _finishDate != null) {
      if (_startDate!.isBefore(_finishDate!)) {
        return false;
      }
    }

    return true;
  }

  void _saveBook() async {
    if (!_validate()) return;

    late Uint8List? cover;
    if (croppedPhoto != null) {
      cover = await croppedPhoto!.readAsBytes();
    } else {
      cover = null;
    }

    bookCubit.addBook(Book(
      title: _titleController.text,
      author: _authorController.text,
      status: _status,
      rating: _rating,
      startDate: _startDate?.toIso8601String(),
      finishDate: _finishDate?.toIso8601String(),
      pages: _pagesController.text.isEmpty
          ? null
          : int.parse(_pagesController.text),
      publicationYear: _pubYearController.text.isEmpty
          ? null
          : int.parse(_pubYearController.text),
      isbn: _isbnController.text.isEmpty ? null : _isbnController.text,
      olid: _olidController.text.isEmpty ? null : _olidController.text,
      // tags: _tags,
      myReview:
          _myReviewController.text.isEmpty ? null : _myReviewController.text,
      cover: cover,
    ));

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _updateBook() async {
    if (!_validate()) return;

    late Uint8List? cover;

    if (croppedPhoto != null) {
      cover = await croppedPhoto!.readAsBytes();
    } else {
      cover = coverForEdit;
    }

    //TODO: finish all parameters
    bookCubit.updateBook(Book(
      id: widget.book?.id,
      title: _titleController.text,
      author: _authorController.text,
      status: _status,
      rating: _rating,
      startDate: _startDate?.toIso8601String(),
      finishDate: _finishDate?.toIso8601String(),
      pages: _pagesController.text.isEmpty
          ? null
          : int.parse(_pagesController.text),
      publicationYear: _pubYearController.text.isEmpty
          ? null
          : int.parse(_pubYearController.text),
      isbn: _isbnController.text.isEmpty ? null : _isbnController.text,
      olid: _olidController.text.isEmpty ? null : _olidController.text,
      // tags: _tags,
      myReview:
          _myReviewController.text.isEmpty ? null : _myReviewController.text,
      cover: cover,
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
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
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
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
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
          _backgroundColors[index] =
              Theme.of(widget.previousContext).primaryColor;
        });
      } else {
        setState(() {
          _flex[index] = 1;
          _colors[index] = Theme.of(widget.previousContext).secondaryTextColor;
          _backgroundColors[index] =
              Theme.of(widget.previousContext).backgroundColor;
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

  void changeRating(double rating) {
    _rating = (rating * 10).toInt();
  }

  @override
  void initState() {
    super.initState();

    _colors = [
      Theme.of(widget.previousContext).secondaryTextColor,
      Theme.of(widget.previousContext).secondaryTextColor,
      Theme.of(widget.previousContext).secondaryTextColor,
      Theme.of(widget.previousContext).secondaryTextColor,
    ];

    _backgroundColors = [
      Theme.of(widget.previousContext).backgroundColor,
      Theme.of(widget.previousContext).backgroundColor,
      Theme.of(widget.previousContext).backgroundColor,
      Theme.of(widget.previousContext).backgroundColor,
    ];

    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _pagesController = TextEditingController();
    _pubYearController = TextEditingController();
    _isbnController = TextEditingController();
    _olidController = TextEditingController();
    _myReviewController = TextEditingController();

    if (widget.book != null) {
      _prefillBookDetails();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _pubYearController.dispose();
    _isbnController.dispose();
    _olidController.dispose();
    _myReviewController.dispose();

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
            title: const Text('Add new book'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              //TODO: change button color based on validation
              TextButton(
                onPressed: (widget.book == null) ? _saveBook : _updateBook,
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  (coverForEdit != null)
                      ? CoverView(
                          photoBytes: coverForEdit,
                          onPressed: _loadCoverFromStorage,
                        )
                      : (croppedPhotoPreview != null)
                          ? CoverView(
                              croppedPhotoPreview: croppedPhotoPreview,
                              onPressed: _loadCoverFromStorage,
                            )
                          : CoverPlaceholder(
                              defaultHeight: _defaultHeight,
                              onPressed: _loadCoverFromStorage,
                            ),
                  const SizedBox(height: 15.0),
                  BookTextField(
                    controller: _titleController,
                    hint: 'Enter a title',
                    icon: Icons.book,
                    keyboardType: TextInputType.text,
                    autofocus: true,
                    maxLines: 5,
                    maxLength: 255,
                  ),
                  const SizedBox(height: 15.0),
                  BookTextField(
                    controller: _authorController,
                    hint: 'Enter an author',
                    icon: Icons.person,
                    keyboardType: TextInputType.name,
                    maxLines: 5,
                    maxLength: 255,
                  ),
                  const SizedBox(height: 15.0),
                  BookStatusRow(
                    animDuration: _animDuration,
                    defaultHeight: _defaultHeight,
                    colors: _colors,
                    backgroundColors: _backgroundColors,
                    widths: widths,
                    onPressed: _changeBookStatus,
                  ),
                  const SizedBox(height: 15.0),
                  BookRatingBar(
                    animDuration: _animDuration,
                    status: _status,
                    defaultHeight: _defaultHeight,
                    rating: _rating,
                    onRatingUpdate: changeRating,
                  ),
                  AnimatedContainer(
                    duration: _animDuration,
                    height: (_status == 0) ? 15 : 0,
                  ),
                  DateRow(
                    animDuration: _animDuration,
                    status: _status,
                    defaultHeight: _defaultHeight,
                    startDate: _startDate,
                    finishDate: _finishDate,
                    showStartDatePicker: _showStartDatePicker,
                    showFinishDatePicker: _showFinishDatePicker,
                  ),
                  AnimatedContainer(
                    duration: _animDuration,
                    height: (_status == 2 || _status == null) ? 0 : 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: BookTextField(
                          controller: _pagesController,
                          hint: 'Number of pages',
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          maxLength: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BookTextField(
                          controller: _pubYearController,
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
                  const SizedBox(height: 15.0),
                  BookTextField(
                    controller: _isbnController,
                    hint: 'ISBN',
                    icon: Icons.pin,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 20,
                  ),
                  const SizedBox(height: 15.0),
                  BookTextField(
                    controller: _olidController,
                    hint: 'Open Library ID',
                    icon: Icons.pin,
                    keyboardType: TextInputType.text,
                    maxLength: 20,
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    height: _defaultHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sell,
                              color: Theme.of(context).secondaryTextColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tags',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  BookTextField(
                    controller: _myReviewController,
                    hint: 'My review',
                    icon: Icons.message,
                    keyboardType: TextInputType.multiline,
                    maxLength: 5000,
                    hideCounter: false,
                    maxLines: 15,
                  ),
                  const SizedBox(height: 25.0),
                  Row(
                    children: [
                      Expanded(
                        flex: 11,
                        child: MaterialButton(
                          color: Theme.of(context).secondaryTextColor,
                          onPressed: () => Navigator.pop(context),
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 19,
                        child: MaterialButton(
                          color: Theme.of(context).primaryColor,
                          onPressed:
                              (widget.book == null) ? _saveBook : _updateBook,
                          child: const Center(
                            child: Text(
                              "Add",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
