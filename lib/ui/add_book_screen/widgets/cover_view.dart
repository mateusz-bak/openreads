import 'dart:io';

import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  }) : super(key: key);

  final CroppedFile? croppedPhotoPreview;
  final Uint8List? photoBytes;
  final Function()? onPressed;
  final String? heroTag;
  final String? blurHash;

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
            height: MediaQuery.of(context).size.height / 3,
            child: (widget.blurHash == null)
                ? const SizedBox()
                : Stack(
                    children: [
                      BlurHash(hash: widget.blurHash!),
                      Container(
                        color: Theme.of(context).onPrimary.withOpacity(0.4),
                      )
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Container(
                height: (MediaQuery.of(context).size.height / 3) - 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).onPrimary,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
