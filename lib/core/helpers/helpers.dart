import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/generated/locale_keys.g.dart';

import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

Future generateBlurHash(Uint8List bytes, BuildContext context) async {
  final blurHashStringTmp = await createBlurHash(bytes);

  if (!context.mounted) return;

  context.read<EditBookCubit>().setBlurHash(blurHashStringTmp);
}

Future<String?> createBlurHash(Uint8List? bytes) async {
  if (bytes == null) return null;

  ui.Codec? codec;
  ui.Image? decoded;

  try {
    // a 2x2 hash only keeps the low frequencies, so the image is decoded
    // natively at a small size and only that copy is encoded in Dart
    codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 100,
      allowUpscaling: false,
    );
    decoded = (await codec.getNextFrame()).image;

    final pixels = await decoded.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    final width = decoded.width;
    final height = decoded.height;

    if (pixels == null) return null;

    final image = img.Image.fromBytes(
      width: width,
      height: height,
      bytes: pixels.buffer,
      bytesOffset: pixels.offsetInBytes,
      numChannels: 4,
    );

    return blurhash_dart.BlurHash.encode(
      image,
      numCompX: Constants.blurHashX,
      numCompY: Constants.blurHashY,
    ).hash;
  } catch (error) {
    return null;
  } finally {
    decoded?.dispose();
    codec?.dispose();
  }
}

void errorSnackBar(String message) async {
  final snackBar = SnackBar(content: Text(message));
  snackbarKey.currentState?.showSnackBar(snackBar);
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
        statusBarLight: false,
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

// covers are rounded inside their heroes, so the flying cover keeps rounded
// corners and its radius moves between the radii of both screens
Widget buildCoverHeroFlight(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final fromChild = (fromHeroContext.widget as Hero).child;
  final toChild = (toHeroContext.widget as Hero).child;

  // the animation runs from the pushed route's start, also when popping
  final isPush = flightDirection == HeroFlightDirection.push;
  final begin = _getCoverRadius(isPush ? fromChild : toChild);
  final end = _getCoverRadius(isPush ? toChild : fromChild);

  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      return ClipRRect(
        borderRadius: BorderRadiusGeometry.lerp(begin, end, animation.value)!,
        child: child,
      );
    },
    child: toChild is ClipRRect ? toChild.child : toChild,
  );
}

BorderRadiusGeometry _getCoverRadius(Widget heroChild) {
  if (heroChild is ClipRRect) return heroChild.borderRadius;

  return BorderRadius.zero;
}
