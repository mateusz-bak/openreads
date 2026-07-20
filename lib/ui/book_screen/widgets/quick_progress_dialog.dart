import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class QuickProgressDialog extends StatefulWidget {
  const QuickProgressDialog({
    super.key,
    this.currentPage,
    this.pages,
  });

  final int? currentPage;
  final int? pages;

  @override
  State<QuickProgressDialog> createState() => _QuickProgressDialogState();
}

class _QuickProgressDialogState extends State<QuickProgressDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentPage?.toString() ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // An empty field clears the progress, so returning null here is a valid
  // result and not an error.
  int? _parseProgress() {
    final value = int.tryParse(_controller.text.trim());

    if (value == null || value < 0) return null;

    final pages = widget.pages;
    if (pages != null && value > pages) return pages;

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      title: Text(
        LocaleKeys.update_progress.tr(),
        style: const TextStyle(fontSize: 18),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: LocaleKeys.current_page.tr(),
          suffixText: widget.pages != null ? '/ ${widget.pages}' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius),
          ),
        ),
        onSubmitted: (_) => Navigator.of(context).pop(_parseProgress()),
      ),
      actions: [
        Platform.isIOS
            ? CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(LocaleKeys.cancel.tr()),
              )
            : FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(LocaleKeys.cancel.tr()),
              ),
        Platform.isIOS
            ? CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.of(context).pop(_parseProgress());
                },
                child: Text(LocaleKeys.save.tr()),
              )
            : FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_parseProgress());
                },
                child: Text(LocaleKeys.save.tr()),
              ),
      ],
    );
  }
}
