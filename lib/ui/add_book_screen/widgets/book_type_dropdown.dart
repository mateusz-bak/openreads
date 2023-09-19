import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';

class BookTypeDropdown extends StatelessWidget {
  const BookTypeDropdown({
    super.key,
    required this.bookTypes,
    required this.changeBookType,
    this.multiSelect = false,
  });

  final List<String> bookTypes;
  final Function(String?) changeBookType;
  final bool multiSelect;

  String _getBookTypeDropdownValue(BookType bookType) {
    switch (bookType) {
      case BookType.paper:
        return bookTypes[0];
      case BookType.ebook:
        return bookTypes[1];
      case BookType.audiobook:
        return bookTypes[2];
      default:
        return bookTypes[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: dividerColor,
          ),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(cornerRadius),
            bottomLeft: Radius.circular(cornerRadius),
            topRight: Radius.circular(cornerRadius),
            bottomRight: Radius.circular(cornerRadius),
          ),
        ),
        child: BlocBuilder<EditBookCubit, Book>(
          builder: (context, state) {
            return Row(
              children: [
                Container(
                  height: 60,
                  padding: EdgeInsets.fromLTRB(
                    10,
                    0,
                    state.bookType == BookType.audiobook
                        ? 2
                        : state.bookType == BookType.ebook
                            ? 4
                            : 0,
                    0,
                  ),
                  child: Center(
                    child: FaIcon(
                      state.bookType == BookType.audiobook
                          ? FontAwesomeIcons.headphones
                          : state.bookType == BookType.ebook
                              ? FontAwesomeIcons.tablet
                              : FontAwesomeIcons.bookOpen,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      isExpanded: true,
                      buttonStyleData: const ButtonStyleData(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                      items: bookTypes
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      value: _getBookTypeDropdownValue(state.bookType),
                      onChanged: (value) {
                        changeBookType(value);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
