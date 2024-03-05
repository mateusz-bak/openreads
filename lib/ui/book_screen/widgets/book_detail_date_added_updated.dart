import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/main.dart';

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
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  LocaleKeys.added_on.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
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
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        LocaleKeys.modified_on.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
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
  }
}
