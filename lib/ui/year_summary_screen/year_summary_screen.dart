import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/constants/locale.dart';
import 'package:openreads/core/helpers/backup/backup.dart';
import 'package:openreads/core/helpers/helpers.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/year_summary_screen/widgets/widgets.dart';

class YearSummaryScreen extends StatefulWidget {
  const YearSummaryScreen({
    super.key,
    required this.year,
    required this.books,
    required this.finishedBooks,
    required this.finishedPages,
    this.booksTarget,
    this.pagesTarget,
  });

  final int year;
  final List<Book> books;
  final int finishedBooks;
  final int finishedPages;
  final int? booksTarget;
  final int? pagesTarget;

  @override
  State<YearSummaryScreen> createState() => _YearSummaryScreenState();
}

class _YearSummaryScreenState extends State<YearSummaryScreen> {
  static const _sortOptions = [
    SortType.byFinishDate,
    SortType.byRating,
    SortType.byTitle,
  ];

  static const _fallbackLocale = Locale('en', 'US');

  final _imageKey = GlobalKey();
  // one entry per reading finished in the year, re-reads included
  final _readings = <MapEntry<Book, DateTime>>[];
  final _coverFiles = <Book, File>{};

  double _minRating = 0;
  SortType _sortType = SortType.byFinishDate;
  bool _isAsc = true;
  bool _isSharing = false;
  bool _onlyWithCovers = false;
  bool _showBooksTarget = true;
  bool _showPagesTarget = false;
  bool _hideRereads = false;
  bool _showOptions = false;
  Brightness _brightness = Brightness.dark;
  Locale? _locale;
  Locale? _requestedLocale;
  Color? _imageSeedColor;
  ColorScheme? _imageColorScheme;
  Map<String, dynamic>? _translations;
  Map<String, dynamic>? _fallbackTranslations;

  Future<Map<String, dynamic>> _loadTranslationFile(Locale locale) async {
    final json = await rootBundle.loadString(
      'assets/translations/${locale.toLanguageTag()}.json',
    );

    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> _changeLanguage(Locale locale) async {
    _requestedLocale = locale;

    try {
      final translations = await _loadTranslationFile(locale);
      _fallbackTranslations ??= await _loadTranslationFile(_fallbackLocale);

      // a later pick may have finished loading first
      if (!mounted || _requestedLocale != locale) return;
      setState(() {
        _locale = locale;
        _translations = translations;
      });
    } catch (error) {
      errorSnackBar(LocaleKeys.internal_error.tr());
    }
  }

  // the image can be in a different language than the app
  String _translate(String key) {
    if (_translations == null) return key.tr();

    final translation = _translations![key];
    if (translation is String && translation.isNotEmpty) return translation;

    final fallback = _fallbackTranslations?[key];
    return fallback is String ? fallback : key.tr();
  }

  Locale _getSelectedLocale(BuildContext context) {
    if (_locale != null) return _locale!;

    final appLocale = context.locale;
    for (final language in supportedLocales) {
      if (language.locale == appLocale) return language.locale;
    }
    for (final language in supportedLocales) {
      if (language.locale.languageCode == appLocale.languageCode) {
        return language.locale;
      }
    }

    return _fallbackLocale;
  }

  Future<void> _shareImage(Rect? sharePositionOrigin) async {
    setState(() => _isSharing = true);

    try {
      final boundary = _imageKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      await _precacheCovers();

      final image = await boundary.toImage(
        pixelRatio: YearSummaryImage.exportPixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) throw Exception('Could not encode the image');

      final bytes = byteData.buffer.asUint8List();
      final fileName = 'openreads_${widget.year}.png';

      if (Platform.isLinux) {
        // share_plus can't share files on Linux
        final savedFile = await FilePicker.saveFile(
          fileName: fileName,
          bytes: bytes,
          mimeType: 'image/png',
        );

        if (savedFile != null) {
          BackupGeneral.showInfoSnackbar(LocaleKeys.export_successful.tr());
        }
      } else {
        final path = '${appTempDirectory.path}/$fileName';
        await File(path).writeAsBytes(bytes);

        await SharePlus.instance.share(ShareParams(
          files: [XFile(path, mimeType: 'image/png')],
          sharePositionOrigin: sharePositionOrigin,
        ));
      }
    } catch (error) {
      errorSnackBar(LocaleKeys.internal_error.tr());
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // covers load asynchronously, capturing too early leaves empty tiles
  Future<void> _precacheCovers() async {
    final futures = <Future<void>>[];

    void visit(Element element) {
      final widget = element.widget;
      if (widget is Image) futures.add(precacheImage(widget.image, element));
      element.visitChildren(visit);
    }

    _imageKey.currentContext?.visitChildElements(visit);
    await Future.wait(futures);
    await WidgetsBinding.instance.endOfFrame;
  }

  List<MapEntry<Book, DateTime>> _getLastReadings() {
    final lastFinishDates = <Book, DateTime>{};

    for (final reading in _readings) {
      final finishDate = lastFinishDates[reading.key];
      if (finishDate == null || reading.value.isAfter(finishDate)) {
        lastFinishDates[reading.key] = reading.value;
      }
    }

    return lastFinishDates.entries.toList();
  }

  List<Book> _getBooksToShow(List<MapEntry<Book, DateTime>> readings) {
    final booksToShow = readings.where(
      (reading) {
        final book = reading.key;
        if (_onlyWithCovers && !_coverFiles.containsKey(book)) return false;

        // ratings are stored as stars * 10
        return _minRating == 0 || (book.rating ?? 0) >= _minRating * 10;
      },
    ).toList();

    final direction = _isAsc ? 1 : -1;

    int compareFinishDates(
      MapEntry<Book, DateTime> a,
      MapEntry<Book, DateTime> b,
    ) =>
        a.value.compareTo(b.value);

    switch (_sortType) {
      case SortType.byRating:
        booksToShow.sort((a, b) {
          final result = (a.key.rating ?? 0).compareTo(b.key.rating ?? 0);
          // secondary sorting, by finish date, always in reading order
          return result != 0 ? result * direction : compareFinishDates(a, b);
        });
        break;
      case SortType.byTitle:
        booksToShow.sort(
          (a, b) =>
              a.key.title.toLowerCase().compareTo(
                    b.key.title.toLowerCase(),
                  ) *
              direction,
        );
        break;
      default:
        booksToShow.sort((a, b) => compareFinishDates(a, b) * direction);
    }

    return booksToShow.map((reading) => reading.key).toList();
  }

  ColorScheme _getImageColorScheme() {
    final seedColor = Theme.of(context).colorScheme.primary;

    if (_imageColorScheme?.brightness != _brightness ||
        _imageSeedColor != seedColor) {
      _imageSeedColor = seedColor;
      _imageColorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        // fixed tones keep the text readable with any accent color
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        brightness: _brightness,
      );
    }

    return _imageColorScheme!;
  }

  void _changeSort(SortType sortType) {
    setState(() {
      if (_sortType == sortType) {
        _isAsc = !_isAsc;
      } else {
        _sortType = sortType;
        // best rated books first by default
        _isAsc = sortType != SortType.byRating;
      }
    });
  }

  String _getSortLabel(SortType sortType) {
    switch (sortType) {
      case SortType.byRating:
        return LocaleKeys.rating.tr();
      case SortType.byTitle:
        return LocaleKeys.title.tr();
      default:
        return LocaleKeys.finish_date.tr();
    }
  }

  @override
  void initState() {
    super.initState();

    for (final book in widget.books) {
      for (final reading in book.readings) {
        final finishDate = reading.finishDate;
        if (finishDate == null || finishDate.year != widget.year) continue;

        _readings.add(MapEntry(book, finishDate));
      }
    }

    for (final reading in _readings) {
      if (_coverFiles.containsKey(reading.key)) continue;

      final coverFile = reading.key.getCoverFile();
      if (coverFile != null) _coverFiles[reading.key] = coverFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.share_year_in_books.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: _buildPreview(),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: _showOptions
                  ? ConstrainedBox(
                      // short screens keep part of the preview visible
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                      ),
                      child: SingleChildScrollView(child: _buildOptions()),
                    )
                  : const SizedBox(),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final books = _getBooksToShow(
      _hideRereads ? _getLastReadings() : _readings,
    );

    return Center(
      child: AspectRatio(
        aspectRatio: YearSummaryImage.width / YearSummaryImage.height,
        // border on the preview only, the shared image has none
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cornerRadius),
            child: FittedBox(
              child: RepaintBoundary(
                key: _imageKey,
                child: Directionality(
                  textDirection: Bidi.isRtlLanguage(
                    _getSelectedLocale(context).languageCode,
                  )
                      ? ui.TextDirection.rtl
                      : ui.TextDirection.ltr,
                  child: YearSummaryImage(
                    year: widget.year,
                    books: books,
                    coverFiles: _coverFiles,
                    finishedBooks: widget.finishedBooks,
                    finishedPages: widget.finishedPages,
                    title: _translate(LocaleKeys.my_year_in_books),
                    finishedBooksLabel: _translate(LocaleKeys.finished_books),
                    finishedPagesLabel: _translate(LocaleKeys.finished_pages),
                    colorScheme: _getImageColorScheme(),
                    booksTarget: _showBooksTarget ? widget.booksTarget : null,
                    pagesTarget: _showPagesTarget ? widget.pagesTarget : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionTitle(LocaleKeys.language.tr()),
          Row(
            children: [
              Expanded(child: _buildLanguageDropdown()),
              const SizedBox(width: 10),
              _buildBrightnessSwitch(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildOptionTitle(LocaleKeys.rating.tr())),
              _buildRatingLabel(),
            ],
          ),
          Slider(
            value: _minRating,
            max: 5,
            divisions: 10,
            onChanged: (value) => setState(() => _minRating = value),
          ),
          const SizedBox(height: 10),
          _buildOptionTitle(LocaleKeys.sort_by.tr()),
          Wrap(
            spacing: 8,
            children: [
              for (final sortType in _sortOptions)
                FilterChip(
                  label: _buildSortLabel(sortType),
                  selected: _sortType == sortType,
                  showCheckmark: false,
                  onSelected: (_) => _changeSort(sortType),
                ),
            ],
          ),
          const SizedBox(height: 5),
          _buildSwitch(
            LocaleKeys.only_books_with_covers.tr(),
            _onlyWithCovers,
            (value) => setState(() => _onlyWithCovers = value),
          ),
          _buildSwitch(
            LocaleKeys.hide_rereads.tr(),
            _hideRereads,
            (value) => setState(() => _hideRereads = value),
          ),
          if ((widget.booksTarget ?? 0) > 0)
            _buildSwitch(
              LocaleKeys.books_challenge.tr(),
              _showBooksTarget,
              (value) => setState(() => _showBooksTarget = value),
            ),
          if ((widget.pagesTarget ?? 0) > 0)
            _buildSwitch(
              LocaleKeys.pages_challenge.tr(),
              _showPagesTarget,
              (value) => setState(() => _showPagesTarget = value),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => setState(() => _showOptions = !_showOptions),
            isSelected: _showOptions,
            tooltip: LocaleKeys.customize.tr(),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 10),
          Expanded(child: _buildShareButton()),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Builder(
      builder: (context) {
        return FilledButton.icon(
          onPressed: _isSharing
              ? null
              : () {
                  // iPad needs an anchor for the share popover
                  final box = context.findRenderObject() as RenderBox?;
                  _shareImage(
                    box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null,
                  );
                },
          icon: Icon(
            Platform.isLinux ? Icons.download_rounded : Icons.share_rounded,
          ),
          label: Text(
            Platform.isLinux ? LocaleKeys.save.tr() : LocaleKeys.share.tr(),
          ),
        );
      },
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownMenu<Locale>(
      initialSelection: _getSelectedLocale(context),
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      // same height as the light/dark switch next to it
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        constraints: const BoxConstraints(maxHeight: 40),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      onSelected: (locale) {
        if (locale != null) _changeLanguage(locale);
      },
      dropdownMenuEntries: [
        for (final language in supportedLocales)
          DropdownMenuEntry(
            value: language.locale,
            label: language.fullName,
          ),
      ],
    );
  }

  Widget _buildBrightnessSwitch() {
    return SegmentedButton<Brightness>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      selected: {_brightness},
      onSelectionChanged: (selection) {
        setState(() => _brightness = selection.first);
      },
      segments: [
        ButtonSegment(
          value: Brightness.light,
          icon: const Icon(Icons.light_mode_rounded),
          tooltip: LocaleKeys.theme_mode_light.tr(),
        ),
        ButtonSegment(
          value: Brightness.dark,
          icon: const Icon(Icons.dark_mode_rounded),
          tooltip: LocaleKeys.theme_mode_dark.tr(),
        ),
      ],
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(cornerRadius),
      child: Row(
        children: [
          SizedBox(
            height: 40,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortLabel(SortType sortType) {
    if (_sortType != sortType) return Text(_getSortLabel(sortType));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_getSortLabel(sortType)),
        const SizedBox(width: 6),
        FaIcon(
          _isAsc ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildOptionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingLabel() {
    if (_minRating == 0) return Text(LocaleKeys.all_ratings.tr());

    final stars = _minRating == _minRating.roundToDouble()
        ? '${_minRating.toInt()}'
        : '$_minRating';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_minRating == 5 ? stars : '$stars+'),
        const SizedBox(width: 2),
        const Icon(Icons.star_rounded, size: 18),
      ],
    );
  }
}
