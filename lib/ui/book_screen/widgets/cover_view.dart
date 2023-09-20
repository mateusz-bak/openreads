import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/book_screen/widgets/widgets.dart';

class CoverView extends StatefulWidget {
  const CoverView({
    Key? key,
    this.heroTag,
    this.onPressed,
    this.book,
    this.coverFile,
    this.blurHashString,
  }) : super(key: key);

  final Function()? onPressed;
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

    return InkWell(
      onTap: widget.onPressed,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            child: const Stack(
              children: [
                CoverBackground(),
              ],
            ),
          ),
          Center(
            child: SizedBox(
              height: ((MediaQuery.of(context).size.height / 2.5) - 0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: coverFile != null
                      ? Hero(
                          tag: widget.heroTag ?? "",
                          child: Image.file(
                            coverFile!,
                            fit: BoxFit.cover,
                            height:
                                (MediaQuery.of(context).size.height / 2.5) - 40,
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
