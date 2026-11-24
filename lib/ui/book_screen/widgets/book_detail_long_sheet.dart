import 'dart:io';

import 'package:flutter/material.dart';

class BookDetailLongSheet extends StatelessWidget {
  const BookDetailLongSheet({
    super.key,
    required this.title,
    required this.text,
    required this.scrollController,
  });

  final String title;
  final String text;
  final ScrollController scrollController;

  static const horizontalPadding = 20.0;

  // drag handle, title, divider and bottom padding around the text
  static const headerHeight = 85.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!Platform.isIOS) _buildDragHandle(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                0,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Divider(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
              ),
            ),
            Flexible(
              child: Scrollbar(
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
                  // short texts can still drag the sheet closed
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    20,
                  ),
                  child: SelectableText(
                    text,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Container(
          height: 5,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(
                  102,
                ),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
