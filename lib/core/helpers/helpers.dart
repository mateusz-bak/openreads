import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blurhash/blurhash.dart' as blurhash;
import 'package:image_cropper/image_cropper.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/generated/locale_keys.g.dart';

import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

Future generateBlurHash(Uint8List bytes, BuildContext context) async {
  final blurHashStringTmp = await blurhash.BlurHash.encode(
    bytes,
    Constants.blurHashX,
    Constants.blurHashY,
  );

  if (!context.mounted) return;

  context.read<EditBookCubit>().setBlurHash(blurHashStringTmp);
}

DateTime? getLatestFinishDate(Book book) {
  if (book.readings.isEmpty) return null;

  final readingsWithFinishDate =
      book.readings.where((e) => e.finishDate != null);

  if (readingsWithFinishDate.isEmpty) return null;

  return readingsWithFinishDate
      .map((e) => e.finishDate)
      .reduce((value, element) => value!.isAfter(element!) ? value : element);
}

DateTime? getLatestStartDate(Book book) {
  if (book.readings.isEmpty) return null;

  final readingsWithStartDate = book.readings.where((e) => e.startDate != null);

  if (readingsWithStartDate.isEmpty) return null;

  return readingsWithStartDate
      .map((e) => e.startDate)
      .reduce((value, element) => value!.isAfter(element!) ? value : element);
}

Future<CroppedFile?> cropImage(BuildContext context, Uint8List cover) async {
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
