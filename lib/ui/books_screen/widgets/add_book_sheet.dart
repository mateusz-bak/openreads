import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class AddBookSheet extends StatefulWidget {
  const AddBookSheet({
    super.key,
    required this.addManually,
    required this.searchInOpenLibrary,
    required this.scanBarcode,
  });

  final Function() addManually;
  final Function() searchInOpenLibrary;
  final Function() scanBarcode;

  @override
  State<AddBookSheet> createState() => _AddBookSheetState();
}

class _AddBookSheetState extends State<AddBookSheet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid)
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
              title: Text(LocaleKeys.add_manually.tr()),
              leading: FaIcon(
                FontAwesomeIcons.solidKeyboard,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: widget.addManually,
            ),
            ListTile(
              title: Text(LocaleKeys.add_search.tr()),
              leading: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: widget.searchInOpenLibrary,
            ),
            ListTile(
              title: Text(LocaleKeys.add_scan.tr()),
              leading: FaIcon(
                FontAwesomeIcons.barcode,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: widget.scanBarcode,
            ),
          ],
        ),
      ),
    );
  }
}
