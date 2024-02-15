import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class BookDetailDateAddedUpdated extends StatefulWidget {
  const BookDetailDateAddedUpdated({
    super.key,
    required this.dateAdded,
    required this.dateModified,
  });

  final DateTime dateAdded;
  final DateTime dateModified;

  @override
  State<BookDetailDateAddedUpdated> createState() =>
      _BookDetailDateAddedUpdatedState();
}

class _BookDetailDateAddedUpdatedState
    extends State<BookDetailDateAddedUpdated> {
  late DateFormat dateFormat;

  Future _initDateFormat() async {
    await initializeDateFormatting();

    // ignore: use_build_context_synchronously
    dateFormat = DateFormat.yMMMMd(context.locale.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initDateFormat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox();
          }

          return Card(
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: dividerColor, width: 1),
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        LocaleKeys.date_added.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SelectableText(
                        '${dateFormat.format(widget.dateAdded)} ${widget.dateAdded.hour}:${widget.dateAdded.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  widget.dateAdded.millisecondsSinceEpoch !=
                          widget.dateModified.millisecondsSinceEpoch
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SelectableText(
                              LocaleKeys.date_modified.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SelectableText(
                              '${dateFormat.format(widget.dateModified)} ${widget.dateModified.hour}:${widget.dateModified.minute}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        });
  }
}
