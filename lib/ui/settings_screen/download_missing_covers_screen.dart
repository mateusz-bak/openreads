import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

class DownloadMissingCoversScreen extends StatefulWidget {
  const DownloadMissingCoversScreen({super.key});

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

    final allBooks = await bookCubit.allBooks.first;

    setState(() {
      _progress = '$_progressValue/${allBooks.length}';
    });

    for (final book in allBooks) {
      if (book.hasCover == false) {
        final result = await bookCubit.downloadCoverByISBN(book);

        if (result == true) {
          setState(() {
            downloadedCovers.add(book);
          });
        }
      }

      setState(() {
        _progressValue++;
        _progress = '$_progressValue/${allBooks.length}';
      });
    }

    setState(() {
      _isDownloading = false;
    });
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
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                      ElevatedButton(
                        onPressed: _startCoverDownload,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cornerRadius),
                          ),
                        ),
                        child: Text(LocaleKeys.start_button.tr()),
                      ),
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
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: downloadedCovers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final book = downloadedCovers[index];
                          final coverFile = book.getCoverFile();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(cornerRadius),
                                  child: coverFile != null
                                      ? Image.file(
                                          coverFile,
                                          fit: BoxFit.cover,
                                          width: 100,
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        book.author,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
