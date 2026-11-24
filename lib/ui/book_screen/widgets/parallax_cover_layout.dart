import 'package:flutter/material.dart';

class ParallaxCoverLayout extends StatefulWidget {
  const ParallaxCoverLayout({
    super.key,
    required this.cover,
    required this.coverHeight,
    required this.child,
  });

  final Widget cover;
  final double coverHeight;
  final Widget child;

  @override
  State<ParallaxCoverLayout> createState() => _ParallaxCoverLayoutState();
}

class _ParallaxCoverLayoutState extends State<ParallaxCoverLayout> {
  static const double parallaxFactor = 0.5;
  static const double sheetOverlap = 40;
  static const double sheetRadius = 25;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset =
                _scrollController.hasClients ? _scrollController.offset : 0.0;

            // the cover moves slower than the details sheet
            return Transform.translate(
              offset: Offset(0, -offset * parallaxFactor),
              child: child,
            );
          },
          child: RepaintBoundary(child: widget.cover),
        ),
        SingleChildScrollView(
          controller: _scrollController,
          // bouncing would move the sheet away from the slower cover
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: widget.coverHeight - sheetOverlap),
              _buildSheet(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      // the cover should never show below short details
      constraints: BoxConstraints(
        minHeight: screenHeight - (widget.coverHeight - sheetOverlap),
      ),
      padding: const EdgeInsets.only(top: sheetOverlap),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(sheetRadius),
        ),
      ),
      child: widget.child,
    );
  }
}
