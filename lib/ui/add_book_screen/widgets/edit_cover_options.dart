import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/model/book.dart';

class EditCoverOptions extends StatelessWidget {
  const EditCoverOptions({
    super.key,
    required this.loadCoverFromStorage,
    required this.searchForCoverOnline,
    required this.loadCoverFromOpenLibrary,
    required this.editCurrentCover,
  });

  final Function(BuildContext) loadCoverFromStorage;
  final Function(BuildContext) searchForCoverOnline;
  final Function(BuildContext) loadCoverFromOpenLibrary;
  final Function(BuildContext) editCurrentCover;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isIOS)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ListTile(
              title: Text(LocaleKeys.load_cover_from_phone.tr()),
              leading: FaIcon(
                FontAwesomeIcons.mobile,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => loadCoverFromStorage(context),
            ),
            ListTile(
              title: Text(LocaleKeys.searchOnlineForCover.tr()),
              leading: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => searchForCoverOnline(context),
            ),
            ListTile(
              title: Text(LocaleKeys.get_cover_from_open_library.tr()),
              leading: FaIcon(
                FontAwesomeIcons.globe,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => loadCoverFromOpenLibrary(context),
            ),
            BlocBuilder<EditBookCubit, Book>(
              builder: (blocContext, state) {
                if (state.hasCover) {
                  return ListTile(
                    title: Text(LocaleKeys.edit_current_cover.tr()),
                    leading: FaIcon(
                      FontAwesomeIcons.image,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => editCurrentCover(context),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
