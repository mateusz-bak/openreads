import 'dart:io';

import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:openreads/core/themes/app_theme.dart';

class CoverView extends StatefulWidget {
  const CoverView({
    Key? key,
    this.croppedPhotoPreview,
    this.photoBytes,
    this.heroTag,
    this.onPressed,
    this.blurHash,
    this.deleteCover,
    this.constrainHeight = true,
  }) : super(key: key);

  final CroppedFile? croppedPhotoPreview;
  final Uint8List? photoBytes;
  final Function()? onPressed;
  final String? heroTag;
  final String? blurHash;
  final bool constrainHeight;
  final Function()? deleteCover;

  @override
  State<CoverView> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            child: (widget.blurHash == null)
                ? const SizedBox()
                : Stack(
                    children: [
                      BlurHash(hash: widget.blurHash!),
                      Container(
                          // color: Theme.of(context).onPrimary.withOpacity(0.4),
                          )
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
                          : (widget.photoBytes != null)
                              ? Hero(
                                  tag: widget.heroTag ?? "",
                                  child: Image.memory(
                                    widget.photoBytes!,
                                    fit: BoxFit.fill,
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
