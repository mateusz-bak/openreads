import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class CoverView extends StatefulWidget {
  const CoverView({
    super.key,
    this.heroTag,
    this.book,
    this.coverFile,
    this.blurHashString,
  });

  final String? heroTag;
  final String? blurHashString;
  final Book? book;
  final File? coverFile;

  @override
  State<CoverView> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  File? coverFile;

  void _loadCoverFile() {
    if (widget.coverFile != null) {
      coverFile = widget.coverFile;
    } else if (widget.book != null) {
      coverFile = widget.book!.getCoverFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadCoverFile();
    final mediaQuery = MediaQuery.of(context);

    return Stack(
      children: [
        SizedBox(
          width: mediaQuery.size.width,
          height: (mediaQuery.size.height / 2.5) + mediaQuery.padding.top + 20,
          child: const Stack(
            children: [
              CoverBackground(),
            ],
          ),
        ),
        Column(
          children: [
            SizedBox(height: mediaQuery.padding.top - 20),
            Center(
              child: SizedBox(
                height: mediaQuery.size.height / 2.5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: coverFile != null
                          ? Hero(
                              tag: widget.heroTag ?? "",
                              child: Image.file(
                                coverFile!,
                                fit: BoxFit.cover,
                                height: mediaQuery.size.height / 2.5,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 40,
            width: mediaQuery.size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
