import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';
import 'package:blurhash/blurhash.dart';

class CoverView extends StatefulWidget {
  const CoverView({
    Key? key,
    this.croppedPhotoPreview,
    this.heroTag,
    this.onPressed,
    this.book,
    this.deleteCover,
    this.constrainHeight = true,
  }) : super(key: key);

  final CroppedFile? croppedPhotoPreview;
  final Function()? onPressed;
  final String? heroTag;
  final bool constrainHeight;
  final Function()? deleteCover;
  final Book? book;

  @override
  State<CoverView> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  File? coverFile;
  Future<Uint8List?> _decodeBlurHash() async {
    return BlurHash.decode(widget.book!.blurHash!, 32, 32);
  }

  @override
  void initState() {
    coverFile = widget.book!.getCoverFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            child: (widget.book?.blurHash != null)
                ? Stack(
                    children: [
                      FutureBuilder<Uint8List?>(
                          future: _decodeBlurHash(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                frameBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  int? frame,
                                  bool wasSynchronouslyLoaded,
                                ) {
                                  if (wasSynchronouslyLoaded) {
                                    return child;
                                  }
                                  return AnimatedOpacity(
                                    opacity: frame == null ? 0 : 0.7,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeIn,
                                    child: child,
                                  );
                                },
                              );
                            } else {
                              return const SizedBox();
                            }
                          }),
                    ],
                  )
                : const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                height: widget.constrainHeight
                    ? ((MediaQuery.of(context).size.height / 2.5) - 20)
                    : null,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      child: (widget.croppedPhotoPreview != null)
                          ? Image.file(
                              File(widget.croppedPhotoPreview!.path),
                              fit: BoxFit.fill,
                            )
                          : widget.book != null && coverFile != null
                              ? Hero(
                                  tag: widget.heroTag ?? "",
                                  child: Image.file(
                                    coverFile!,
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : const SizedBox(),
                    ),
                    widget.deleteCover != null
                        ? Positioned(
                            right: 1,
                            bottom: 1,
                            child: IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red.shade400,
                              ),
                              icon: const Icon(FontAwesomeIcons.trash),
                              onPressed: widget.deleteCover,
                              iconSize: 16,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
