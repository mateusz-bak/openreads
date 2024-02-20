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
import 'package:openreads/model/book.dart';
import 'package:openreads/resources/open_library_service.dart';

import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class CoverViewEdit extends StatefulWidget {
  const CoverViewEdit({super.key});

  static showInfoSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  @override
  State<CoverViewEdit> createState() => _CoverViewEditState();
}

class _CoverViewEditState extends State<CoverViewEdit> {
  bool _isCoverLoading = false;

  void _setCoverLoading(bool value) {
    setState(() {
      _isCoverLoading = value;
    });
  }

  void _loadCoverFromStorage(BuildContext context) async {
    _setCoverLoading(true);
    Navigator.of(context).pop();

    final photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) {
      _setCoverLoading(false);
      return;
    }

    final croppedPhoto = await _cropImage(await photoXFile.readAsBytes());

    if (croppedPhoto == null) {
      _setCoverLoading(false);
      return;
    }

    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }

    await generateBlurHash(croppedPhotoBytes, context);
    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }

    context.read<EditBookCoverCubit>().setCover(croppedPhotoBytes);
    context.read<EditBookCubit>().setHasCover(true);

    _setCoverLoading(false);
  }

  void _editCurrentCover(BuildContext context) async {
    _setCoverLoading(true);
    Navigator.of(context).pop();

    final cover = context.read<EditBookCoverCubit>().state;

    if (cover == null) {
      _setCoverLoading(false);
      return;
    }

    final croppedPhoto = await _cropImage(cover);

    if (croppedPhoto == null) {
      _setCoverLoading(false);
      return;
    }

    final croppedPhotoBytes = await croppedPhoto.readAsBytes();

    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }

    await generateBlurHash(croppedPhotoBytes, context);

    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }

    context.read<EditBookCoverCubit>().setCover(croppedPhotoBytes);
    context.read<EditBookCubit>().setHasCover(true);

    _setCoverLoading(false);
  }

  Future<CroppedFile?> _cropImage(Uint8List cover) async {
    final colorScheme = Theme.of(context).colorScheme;

    //write temporary file as ImageCropper requires a file
    final tmpCoverTimestamp = DateTime.now().millisecondsSinceEpoch;
    final tmpCoverFile = File(
      '${appTempDirectory.path}/$tmpCoverTimestamp.jpg',
    );
    await tmpCoverFile.writeAsBytes(cover);

    return await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: tmpCoverFile.path,
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
        IOSUiSettings(
          title: LocaleKeys.edit_cover.tr(),
          cancelButtonTitle: LocaleKeys.cancel.tr(),
          doneButtonTitle: LocaleKeys.save.tr(),
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: true,
          aspectRatioPickerButtonHidden: false,
          aspectRatioLockDimensionSwapEnabled: false,
        ),
      ],
    );
  }

  _deleteCover(BuildContext context) async {
    _setCoverLoading(true);

    context.read<EditBookCubit>().setHasCover(false);
    context.read<EditBookCubit>().setBlurHash(null);
    context.read<EditBookCoverCubit>().setCover(null);

    _setCoverLoading(false);
  }

  _loadCoverFromOpenLibrary(BuildContext context) async {
    Navigator.of(context).pop();

    final isbn = context.read<EditBookCubit>().state.isbn;

    if (isbn == null) {
      CoverViewEdit.showInfoSnackbar(LocaleKeys.isbn_cannot_be_empty.tr());
      return;
    }

    _setCoverLoading(true);

    final cover = await OpenLibraryService().getCover(isbn);

    if (cover == null) {
      CoverViewEdit.showInfoSnackbar(LocaleKeys.cover_not_found_in_ol.tr());
      _setCoverLoading(false);
      return;
    }

    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }
    await generateBlurHash(cover, context);

    if (!context.mounted) {
      _setCoverLoading(false);
      return;
    }
    context.read<EditBookCoverCubit>().setCover(cover);
    context.read<EditBookCubit>().setHasCover(true);

    _setCoverLoading(false);
  }

  showCoverLoadBottomSheet(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (modalContext) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 3,
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CoverOptionButton(
                    text: LocaleKeys.load_cover_from_phone.tr(),
                    icon: FontAwesomeIcons.mobile,
                    onPressed: () => _loadCoverFromStorage(context),
                  ),
                  const SizedBox(height: 15),
                  CoverOptionButton(
                    text: LocaleKeys.get_cover_from_open_library.tr(),
                    icon: FontAwesomeIcons.globe,
                    onPressed: () => _loadCoverFromOpenLibrary(context),
                  ),
                  BlocBuilder<EditBookCubit, Book>(
                    builder: (blocContext, state) {
                      if (state.hasCover) {
                        return Column(
                          children: [
                            const SizedBox(height: 15),
                            CoverOptionButton(
                              text: LocaleKeys.edit_current_cover.tr(),
                              icon: FontAwesomeIcons.image,
                              onPressed: () => _editCurrentCover(
                                context,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isCoverLoading
            ? const LinearProgressIndicator(minHeight: 3)
            : const SizedBox(height: 3),
        const SizedBox(height: 5),
        Builder(builder: (context) {
          return BlocBuilder<EditBookCoverCubit, Uint8List?>(
            buildWhen: (p, c) {
              return p != c;
            },
            builder: (context, state) {
              if (state != null) {
                return _buildCoverViewEdit(
                  context,
                  () => showCoverLoadBottomSheet(context),
                );
              } else {
                return CoverPlaceholder(
                  defaultHeight: Constants.formHeight,
                  onPressed: () => showCoverLoadBottomSheet(context),
                );
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildCoverViewEdit(
    BuildContext context,
    Function() onTap,
  ) {
    return LayoutBuilder(builder: (context, boxConstraints) {
      return InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            SizedBox(
              width: boxConstraints.maxWidth,
              height: boxConstraints.maxWidth / 1.2,
              child: Stack(
                children: [
                  BlocBuilder<EditBookCoverCubit, Uint8List?>(
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
                  width: boxConstraints.maxWidth - 40,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    children: [
                      BlocBuilder<EditBookCoverCubit, Uint8List?>(
                        builder: (context, state) {
                          return Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(cornerRadius),
                              child: (state != null)
                                  ? Image.memory(
                                      state,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : const SizedBox(),
                            ),
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
