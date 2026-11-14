import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/common/blur_hash_background.dart';

class CoverBackground extends StatelessWidget {
  const CoverBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentBookCubit, Book>(
      buildWhen: (previous, current) {
        return previous.blurHash != current.blurHash;
      },
      builder: (context, state) {
        if (state.blurHash == null) return const SizedBox();

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: (MediaQuery.of(context).size.height / 2.5) +
              MediaQuery.of(context).padding.top +
              20,
          child: BlurHashBackground(
            blurHash: state.blurHash!,
            opacity: 0.6,
          ),
        );
      },
    );
  }
}
