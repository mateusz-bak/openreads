import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/model/book.dart';

class YearSummaryImage extends StatelessWidget {
  const YearSummaryImage({
    super.key,
    required this.year,
    required this.books,
    required this.coverFiles,
    required this.finishedBooks,
    required this.finishedPages,
    required this.title,
    required this.finishedBooksLabel,
    required this.finishedPagesLabel,
    required this.colorScheme,
    this.booksTarget,
    this.pagesTarget,
  });

  final int year;
  final List<Book> books;
  final Map<Book, File> coverFiles;
  final int finishedBooks;
  final int finishedPages;
  final String title;
  final String finishedBooksLabel;
  final String finishedPagesLabel;
  final ColorScheme colorScheme;
  final int? booksTarget;
  final int? pagesTarget;

  static const double width = 360;
  static const double height = 640;
  static const int maxCovers = 52;

  // 360x640 canvas exported as a 1080x1920 image
  static const double exportPixelRatio = 3;

  static const double _padding = 20;
  static const double _gap = 4;

  @override
  Widget build(BuildContext context) {
    // covers are decoded at the export size, not the stored size
    final pixelRatio = max(
      exportPixelRatio,
      MediaQuery.devicePixelRatioOf(context),
    );

    // light accent tints wash out the covers, light mode stays neutral
    final isDark = colorScheme.brightness == Brightness.dark;
    final topColor = isDark
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final onTopColor =
        isDark ? colorScheme.onPrimaryContainer : colorScheme.onSurface;

    // the shared image cannot depend on the system text size
    return MediaQuery.withNoTextScaling(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                topColor,
                colorScheme.surfaceContainerLowest,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: Column(
              children: [
                _buildHeader(onTopColor),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => _buildGrid(
                      constraints.maxWidth,
                      constraints.maxHeight,
                      pixelRatio,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color onTopColor) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: onTopColor,
          ),
        ),
        Text(
          '$year',
          style: TextStyle(
            fontSize: 44,
            height: 1.1,
            fontWeight: FontWeight.bold,
            color: onTopColor,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStat(
                finishedBooks,
                booksTarget,
                finishedBooksLabel,
              ),
            ),
            Expanded(
              child: _buildStat(
                finishedPages,
                pagesTarget,
                finishedPagesLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStat(
    int value,
    int? target,
    String label,
  ) {
    final hasTarget = target != null && target > 0;

    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTarget && value >= target) ...[
                FaIcon(
                  FontAwesomeIcons.trophy,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              Text.rich(
                TextSpan(
                  text: '$value',
                  children: [
                    if (hasTarget)
                      TextSpan(
                        text: '/$target',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(
    double maxWidth,
    double maxHeight,
    double pixelRatio,
  ) {
    if (books.isEmpty) return const SizedBox();

    // covers are a showcase, the header has the totals
    final visibleBooks = books.take(maxCovers).toList();
    final tilesCount = visibleBooks.length;

    final columns = _getColumns(tilesCount, maxWidth, maxHeight);
    final tileWidth = _getTileWidth(
      tilesCount,
      columns,
      maxWidth,
      maxHeight,
    );
    final tileHeight = tileWidth * 1.5;

    return Center(
      child: SizedBox(
        width: columns * tileWidth + (columns - 1) * _gap,
        child: Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final book in visibleBooks)
              _buildCover(book, tileWidth, tileHeight, pixelRatio),
          ],
        ),
      ),
    );
  }

  // largest 2:3 tile that fits both the width and the height
  double _getTileWidth(
    int tilesCount,
    int columns,
    double maxWidth,
    double maxHeight,
  ) {
    final rows = (tilesCount / columns).ceil();
    final widthLimit = (maxWidth - (columns - 1) * _gap) / columns;
    final heightLimit = (maxHeight - (rows - 1) * _gap) / rows / 1.5;

    return min(widthLimit, heightLimit).floorToDouble();
  }

  // columns count that gives the biggest covers
  int _getColumns(int tilesCount, double maxWidth, double maxHeight) {
    int biggestColumns = 1;
    double biggestTile = 0;
    for (var columns = 1; columns <= tilesCount; columns++) {
      final tileWidth = _getTileWidth(
        tilesCount,
        columns,
        maxWidth,
        maxHeight,
      );
      if (tileWidth > biggestTile) {
        biggestTile = tileWidth;
        biggestColumns = columns;
      }
    }

    return biggestColumns;
  }

  Widget _buildCover(
    Book book,
    double tileWidth,
    double tileHeight,
    double pixelRatio,
  ) {
    final coverFile = coverFiles[book];

    return ClipRRect(
      borderRadius: BorderRadius.circular(tileWidth * 0.05),
      child: SizedBox(
        width: tileWidth,
        height: tileHeight,
        child: coverFile != null
            ? Image.file(
                coverFile,
                fit: BoxFit.cover,
                cacheWidth: (tileWidth * pixelRatio).ceil(),
              )
            : Container(
                color: colorScheme.surfaceContainerHighest,
                padding: EdgeInsets.all(tileWidth * 0.08),
                alignment: Alignment.center,
                child: Text(
                  book.title,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: tileWidth * 0.14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/icon_cropped.png',
          height: 10,
        ),
        const SizedBox(width: 6),
        Text(
          Constants.appName,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
