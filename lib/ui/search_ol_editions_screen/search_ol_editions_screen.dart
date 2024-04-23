import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/reading.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/search_ol_editions_screen/widgets/widgets.dart';

class SearchOLEditionsScreen extends StatefulWidget {
  const SearchOLEditionsScreen({
    super.key,
    required this.editions,
    required this.title,
    this.subtitle,
    required this.author,
    required this.pagesMedian,
    required this.isbn,
    required this.olid,
    required this.firstPublishYear,
    required this.status,
  });

  final List<String> editions;
  final String title;
  final String? subtitle;
  final String author;
  final int? pagesMedian;
  final List<String>? isbn;
  final String? olid;
  final int? firstPublishYear;
  final BookStatus status;

  @override
  State<SearchOLEditionsScreen> createState() => _SearchOLEditionsScreenState();
}

class _SearchOLEditionsScreenState extends State<SearchOLEditionsScreen> {
  Uint8List? editionCoverPreview;
  bool _onlyEditionsWithCovers = false;

  void _saveEdition({
    required OLEditionResult result,
    required int? cover,
    String? work,
  }) {
    final defaultBookFormat = context.read<DefaultBooksFormatCubit>().state;

    final book = Book(
      title: result.title!,
      subtitle: result.subtitle,
      author: widget.author,
      pages: result.numberOfPages,
      status: widget.status,
      favourite: false,
      isbn: (result.isbn13 != null && result.isbn13!.isNotEmpty)
          ? result.isbn13![0]
          : (result.isbn10 != null && result.isbn10!.isNotEmpty)
              ? result.isbn10![0]
              : null,
      olid: (result.key != null) ? result.key!.replaceAll('/books/', '') : null,
      publicationYear: widget.firstPublishYear,
      bookFormat: result.physicalFormat ?? defaultBookFormat,
      readings: List<Reading>.empty(growable: true),
      tags: LocaleKeys.owned_book_tag.tr(),
      dateAdded: DateTime.now(),
      dateModified: DateTime.now(),
    );

    context.read<EditBookCubit>().setBook(book);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBookScreen(
          fromOpenLibrary: true,
          fromOpenLibraryEdition: true,
          work: work,
          coverOpenLibraryID: cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.choose_edition.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _onlyEditionsWithCovers,
                        onChanged: (value) {
                          setState(() {
                            _onlyEditionsWithCovers = value;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      Text(
                        LocaleKeys.only_editions_with_covers.tr(),
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                // UniqueKey() is used to force the widget to rebuild
                OLEditionsGrid(
                  key: UniqueKey(),
                  editions: widget.editions,
                  saveEdition: _saveEdition,
                  onlyEditionsWithCovers: _onlyEditionsWithCovers,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
