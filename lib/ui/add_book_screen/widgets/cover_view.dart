import 'dart:io';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/model/book.dart';
import 'package:image/image.dart' as img;

class CoverView extends StatefulWidget {
  const CoverView({
    Key? key,
    this.croppedPhotoPreview,
    this.heroTag,
    this.onPressed,
    this.book,
    this.deleteCover,
    this.coverFile,
    this.blurHashString,
    this.constrainHeight = true,
  }) : super(key: key);

  final CroppedFile? croppedPhotoPreview;
  final Function()? onPressed;
  final String? heroTag;
  final String? blurHashString;
  final bool constrainHeight;
  final Function()? deleteCover;
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
            child: Stack(
              children: [
                _buildBlurHash(),
              ],
            ),
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
                          : coverFile != null
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

  Widget _buildBlurHash() {
    if (widget.book?.blurHash == null) {
      return const SizedBox();
    }

    final image = BlurHash.decode(widget.book!.blurHash!).toImage(35, 20);
    return Image.memory(
      Uint8List.fromList(
        img.encodeJpg(image),
      ),
      fit: BoxFit.cover,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2.5,
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
          opacity: frame == null ? 0 : 0.8,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: child,
        );
      },
    );
  }
}
