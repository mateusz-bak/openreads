import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class BookStatusRow extends StatelessWidget {
  const BookStatusRow({
    super.key,
    required this.animDuration,
    required this.defaultHeight,
  });

  final Duration animDuration;
  final double defaultHeight;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditBookCubit, Book>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              AnimatedStatusButton(
                duration: animDuration,
                height: defaultHeight,
                icon: Icons.done,
                text: LocaleKeys.book_status_finished.tr(),
                isSelected: state.status == BookStatus.read,
                currentStatus: state.status,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.read<EditBookCubit>().setStatus(BookStatus.read);
                },
              ),
              const SizedBox(width: 10),
              AnimatedStatusButton(
                duration: animDuration,
                height: defaultHeight,
                icon: Icons.autorenew,
                text: LocaleKeys.book_status_in_progress.tr(),
                isSelected: state.status == BookStatus.inProgress,
                currentStatus: state.status,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context
                      .read<EditBookCubit>()
                      .setStatus(BookStatus.inProgress);
                },
              ),
              const SizedBox(width: 10),
              AnimatedStatusButton(
                duration: animDuration,
                height: defaultHeight,
                icon: Icons.timelapse,
                text: LocaleKeys.book_status_for_later.tr(),
                isSelected: state.status == BookStatus.forLater,
                currentStatus: state.status,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.read<EditBookCubit>().setStatus(BookStatus.forLater);
                },
              ),
              const SizedBox(width: 10),
              AnimatedStatusButton(
                duration: animDuration,
                height: defaultHeight,
                icon: Icons.not_interested,
                text: LocaleKeys.book_status_unfinished.tr(),
                isSelected: state.status == BookStatus.unfinished,
                currentStatus: state.status,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context
                      .read<EditBookCubit>()
                      .setStatus(BookStatus.unfinished);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
