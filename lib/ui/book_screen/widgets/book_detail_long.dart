import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/ui/book_screen/widgets/book_detail_long_sheet.dart';

class BookDetailLong extends StatelessWidget {
  const BookDetailLong({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  static const collapsedMaxLines = 10;
  static const textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  void _showFullText(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        builder: (context) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            // the modal's controller lets the text drag the sheet closed
            child: BookDetailLongSheet(
              title: title,
              text: text,
              scrollController: ModalScrollController.of(context)!,
            ),
          );
        },
      );
    } else {
      final sheetSize = _getSheetSize(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          // the sheet's controller lets the text drag the sheet closed
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: sheetSize,
            minChildSize: min(0.25, sheetSize),
            maxChildSize: sheetSize,
            builder: (context, scrollController) => BookDetailLongSheet(
              title: title,
              text: text,
              scrollController: scrollController,
            ),
          );
        },
      );
    }
  }

  // part of the screen the sheet needs for the whole text, at most 90%
  double _getSheetSize(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    // Material bottom sheets are at most 640 wide
    final sheetWidth = min(mediaQuery.size.width, 640.0);

    final textPainter = _layoutText(
      context,
      maxWidth: sheetWidth - BookDetailLongSheet.horizontalPadding * 2,
    );
    final textHeight = textPainter.height;
    textPainter.dispose();

    final sheetHeight = textHeight +
        BookDetailLongSheet.headerHeight +
        mediaQuery.padding.bottom;

    return min(0.9, sheetHeight / mediaQuery.size.height);
  }

  bool _isTooLong(BuildContext context, double maxWidth) {
    final textPainter = _layoutText(
      context,
      maxWidth: maxWidth,
      maxLines: collapsedMaxLines,
    );

    final isTooLong = textPainter.didExceedMaxLines;
    textPainter.dispose();

    return isTooLong;
  }

  // measures the text the same way the Text widget lays it out
  TextPainter _layoutText(
    BuildContext context, {
    required double maxWidth,
    int? maxLines,
  }) {
    var style = DefaultTextStyle.of(context).style.merge(textStyle);
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    return TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      textHeightBehavior: DefaultTextHeightBehavior.maybeOf(context),
    )..layout(maxWidth: maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 0.5,
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            if (!_isTooLong(context, constraints.maxWidth)) {
              return Text(text, style: textStyle);
            }

            return _buildCollapsedText(context);
          },
        ),
      ],
    );
  }

  Widget _buildCollapsedText(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(cornerRadius),
      onTap: () => _showFullText(context),
      // the fading last lines show that there is more text
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
          stops: [0.7, 1.0],
        ).createShader(bounds),
        child: Text(
          text,
          maxLines: collapsedMaxLines,
          overflow: TextOverflow.clip,
          style: textStyle,
        ),
      ),
    );
  }
}
