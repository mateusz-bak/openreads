import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image/image.dart' as img;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/helpers/helpers.dart';

import 'package:openreads/ui/add_book_screen/widgets/cover_placeholder.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';

class CoverViewEdit extends StatelessWidget {
  const CoverViewEdit({super.key});

  void _loadCoverFromStorage(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final colorScheme = Theme.of(context).colorScheme;

    final photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) return;

    final croppedPhoto = await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: photoXFile.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: LocaleKeys.edit_cover.tr(),
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: colorScheme.surface,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor: colorScheme.primary,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (croppedPhoto == null) return;
    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    final tmpCoverTimestamp = DateTime.now().millisecondsSinceEpoch;

    final coverFileForSaving = File(
      '${appTempDirectory.path}/$tmpCoverTimestamp.jpg',
    );

    await coverFileForSaving.writeAsBytes(croppedPhotoBytes);
    if (!context.mounted) return;
    await generateBlurHash(croppedPhotoBytes, context);

    if (!context.mounted) return;
    context.read<EditBookCoverCubit>().setCover(coverFileForSaving);
    context.read<EditBookCubit>().setHasCover(true);
  }

  _deleteCover(BuildContext context) async {
    context.read<EditBookCubit>().setHasCover(false);
    context.read<EditBookCubit>().setBlurHash(null);
    context.read<EditBookCoverCubit>().setCover(null);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BlocBuilder<EditBookCoverCubit, File?>(
        buildWhen: (p, c) {
          return p != c;
        },
        builder: (context, state) {
          if (state != null) {
            return _buildCoverViewEdit(context);
          } else {
            return CoverPlaceholder(
              defaultHeight: defaultFormHeight,
              onPressed: () => _loadCoverFromStorage(context),
            );
          }
        },
      );
    });
  }

  Widget _buildCoverViewEdit(BuildContext context) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      return InkWell(
        onTap: () => _loadCoverFromStorage(context),
        child: Stack(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth,
              height: boxConstraints.maxWidth / 1.2,
              child: Stack(
                children: [
                  BlocBuilder<EditBookCoverCubit, File?>(
                    builder: (context, state) {
                      return _buildBlurHash(
                        context,
                        context.read<EditBookCubit>().state.blurHash,
                        boxConstraints,
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  height: (boxConstraints.maxWidth / 1.2) - 40,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      BlocBuilder<EditBookCoverCubit, File?>(
                        builder: (context, state) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(cornerRadius),
                            child: (state != null)
                                ? Image.file(
                                    state,
                                    fit: BoxFit.fill,
                                  )
                                : const SizedBox(),
                          );
                        },
                      ),
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red.shade400,
                          ),
                          icon: const Icon(FontAwesomeIcons.trash),
                          onPressed: () => _deleteCover(context),
                          iconSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBlurHash(
    BuildContext context,
    String? blurHashString,
    BoxConstraints boxConstraints,
  ) {
    if (blurHashString == null) {
      return const SizedBox();
    }

    final image = BlurHash.decode(blurHashString).toImage(35, 20);

    return Image(
      image: MemoryImage(Uint8List.fromList(img.encodeJpg(image))),
      fit: BoxFit.cover,
      width: boxConstraints.maxWidth,
      height: boxConstraints.maxWidth / 1.2,
    );
  }
}
