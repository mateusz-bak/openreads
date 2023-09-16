import 'dart:io';

import 'package:flutter/material.dart';

class GridCardCover extends StatelessWidget {
  const GridCardCover({
    super.key,
    required this.heroTag,
    required this.file,
  });

  final String heroTag;
  final File file;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Image.file(
        file,
        fit: BoxFit.cover,
        frameBuilder: (
          BuildContext context,
          Widget child,
          int? frame,
          bool wasSynchronouslyLoaded,
        ) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }
}
