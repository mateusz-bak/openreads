import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blurhash/blurhash.dart' as blurhash;

import 'package:openreads/logic/cubit/edit_book_cubit.dart';

Future generateBlurHash(Uint8List bytes, BuildContext context) async {
  final blurHashStringTmp = await blurhash.BlurHash.encode(bytes, 4, 3);

  if (!context.mounted) return;

  context.read<EditBookCubit>().setBlurHash(blurHashStringTmp);
}
