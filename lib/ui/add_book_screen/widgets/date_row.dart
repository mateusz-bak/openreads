import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/widgets/widgets.dart';

class DateRow extends StatelessWidget {
  const DateRow({
    Key? key,
    required this.animDuration,
    required this.defaultHeight,
    required this.showStartDatePicker,
    required this.showFinishDatePicker,
    required this.clearStartDate,
    required this.clearFinishDate,
  }) : super(key: key);

  final Duration animDuration;
  final double defaultHeight;

  final Function() showStartDatePicker;
  final Function() showFinishDatePicker;
  final Function() clearStartDate;
  final Function() clearFinishDate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMd(
      '${context.locale.languageCode}-${context.locale.countryCode}',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: BlocBuilder<EditBookCubit, Book>(
        builder: (context, state) {
          return AnimatedContainer(
            duration: animDuration,
            height: (state.status == 2) ? 0 : defaultHeight,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: animDuration,
                    width: (state.status == 1 || state.status == 3)
                        ? (MediaQuery.of(context).size.width - 20)
                        : (state.status == 2)
                            ? (MediaQuery.of(context).size.width - 20)
                            : (MediaQuery.of(context).size.width - 40) / 2,
                    child: SetDateButton(
                      defaultHeight: defaultHeight,
                      icon: FontAwesomeIcons.play,
                      text: (state.startDate == null)
                          ? LocaleKeys.start_date.tr()
                          : dateFormat.format(state.startDate!),
                      onPressed: showStartDatePicker,
                      onClearPressed: clearStartDate,
                      showClearButton: (state.startDate == null) ? false : true,
                    ),
                  ),
                  AnimatedContainer(
                    duration: animDuration,
                    width: (state.status == 0) ? 10 : 0,
                  ),
                  AnimatedContainer(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(),
                    duration: animDuration,
                    width: (state.status == 0)
                        ? (MediaQuery.of(context).size.width - 20) / 2
                        : 0,
                    child: SetDateButton(
                      defaultHeight: defaultHeight,
                      icon: FontAwesomeIcons.flagCheckered,
                      text: (state.finishDate == null)
                          ? LocaleKeys.finish_date.tr()
                          : dateFormat.format(state.finishDate!),
                      onPressed: showFinishDatePicker,
                      onClearPressed: clearFinishDate,
                      showClearButton:
                          (state.finishDate == null) ? false : true,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
