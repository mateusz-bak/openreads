import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CoverView extends StatelessWidget {
  const CoverView({
    Key? key,
    this.croppedPhotoPreview,
    this.photoBytes,
    required this.onPressed,
  }) : super(key: key);

  final CroppedFile? croppedPhotoPreview;
  final Uint8List? photoBytes;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width - 20,
            height: MediaQuery.of(context).size.height / 3,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: (croppedPhotoPreview != null)
                      ? Image.file(
                          File(croppedPhotoPreview!.path),
                          fit: BoxFit.fill,
                        )
                      : (photoBytes != null)
                          ? Image.memory(
                              photoBytes!,
                              fit: BoxFit.fill,
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
