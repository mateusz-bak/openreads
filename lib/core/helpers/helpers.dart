import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blurhash/blurhash.dart' as blurhash;
import 'package:openreads/core/constants/constants.dart';

import 'package:openreads/logic/cubit/edit_book_cubit.dart';
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

  return readingsWithFinishDate
      .map((e) => e.finishDate)
      .reduce((value, element) => value!.isAfter(element!) ? value : element);
}

DateTime? getLatestStartDate(Book book) {
  if (book.readings.isEmpty) return null;

  final readingsWithStartDate = book.readings.where((e) => e.startDate != null);

  return readingsWithStartDate
      .map((e) => e.startDate)
      .reduce((value, element) => value!.isAfter(element!) ? value : element);
}
