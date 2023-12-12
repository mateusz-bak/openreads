import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/settings_screen/widgets/widgets.dart';

class DownloadMissingCoversScreen extends StatefulWidget {
  const DownloadMissingCoversScreen({
    super.key,
    this.bookIDs,
  });

  final List<int>? bookIDs;

  @override
  State<DownloadMissingCoversScreen> createState() =>
      _DownloadMissingCoversScreenState();
}

class _DownloadMissingCoversScreenState
    extends State<DownloadMissingCoversScreen> {
  bool _isDownloading = false;
  String _progress = '';
  int _progressValue = 0;
  List<Book> downloadedCovers = [];

  _startCoverDownload() async {
    setState(() {
      _isDownloading = true;
      _progressValue = 0;
    });

    final books = await bookCubit.allBooks.first;
    await _downloadCovers(books);

    setState(() {
      _isDownloading = false;
    });
  }

  _startCoverDownloadForImportedBooks() async {
    setState(() {
      _isDownloading = true;
      _progressValue = 0;
    });

    final books = await _getListOfBooksFromListOfIDs(widget.bookIDs!);
    await _downloadCovers(books);

    setState(() {
      _isDownloading = false;
    });

    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const BooksScreen(),
      ),
      (route) => false,
    );
  }

  Future<List<Book>> _getListOfBooksFromListOfIDs(List<int> bookIDs) async {
    final listOfBooks = List<Book>.empty(growable: true);

    for (final bookID in widget.bookIDs!) {
      final book = await bookCubit.getBook(bookID);

      if (book != null) {
        listOfBooks.add(book);
      }
    }

    return listOfBooks;
  }

  _downloadCovers(List<Book> books) async {
    setState(() {
      _progress = '$_progressValue/${books.length}';
    });

    // Downloading covers 20 at a time
    final asyncTasks = <Future>[];
    const asyncTasksNumber = 20;

    for (final book in books) {
      if (book.hasCover == false) {
        asyncTasks.add(_downloadCover(book));
      }

      if (asyncTasks.length == asyncTasksNumber) {
        await Future.wait(asyncTasks);
        asyncTasks.clear();
      }

      setState(() {
        _progressValue++;
        _progress = '$_progressValue/${books.length}';
      });
    }

    // Wait for the rest of async tasks
    await Future.wait(asyncTasks);
  }

  _downloadCover(Book book) async {
    final result = await bookCubit.downloadCoverByISBN(book);

    if (result == true) {
      setState(() {
        downloadedCovers.add(book);
      });
    }
  }

  @override
  initState() {
    super.initState();

    // If bookIDs is not null, then we are downloading covers automatically
    // for imported books
    if (widget.bookIDs != null) {
      _startCoverDownloadForImportedBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.download_missing_covers.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _isDownloading
              ? const LinearProgressIndicator(minHeight: 4)
              : const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.download_missing_covers_explanation.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.bookIDs == null
                          ? _buildStartButton(context)
                          : const SizedBox(),
                      const SizedBox(width: 20),
                      Text(
                        _progress,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _progress != ''
                      ? Text(
                          '${LocaleKeys.downloaded_covers.tr()} (${downloadedCovers.length})',
                          style: const TextStyle(fontSize: 16),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 10),
                  _buildGridOfCovers(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _startCoverDownload,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ),
      child: Text(LocaleKeys.start_button.tr()),
    );
  }

  Expanded _buildGridOfCovers() {
    return Expanded(
      child: Scrollbar(
        child: GridView.builder(
          itemCount: downloadedCovers.length,
          itemBuilder: (BuildContext context, int index) {
            final book = downloadedCovers[downloadedCovers.length - index - 1];
            final coverFile = book.getCoverFile();

            return MissingCoverView(coverFile: coverFile);
          },
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 1 / 1.5,
          ),
        ),
      ),
    );
  }
}
