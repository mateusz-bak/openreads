import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/home_screen/widgets/widgets.dart';

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
      color: Theme.of(context).brightness == Brightness.dark
          ? darkBackgroundColor
          : lightBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
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
            AddBookMethodButton(
              title: LocaleKeys.add_manually.tr(),
              icon: FontAwesomeIcons.solidKeyboard,
              onTap: widget.addManually,
            ),
            AddBookMethodButton(
              title: LocaleKeys.add_search.tr(),
              icon: FontAwesomeIcons.magnifyingGlass,
              onTap: widget.searchInOpenLibrary,
            ),
            AddBookMethodButton(
              title: LocaleKeys.add_scan.tr(),
              icon: FontAwesomeIcons.barcode,
              onTap: widget.scanBarcode,
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
