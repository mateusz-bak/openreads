import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final double radius;
  final double indicatorHeight;
  final ThemeData themeData;

  const CustomTabIndicator({
    this.radius = 3,
    this.indicatorHeight = 3,
    required this.themeData,
  });

  @override
  CustomPainter createBoxPainter([VoidCallback? onChanged]) => CustomPainter(
        this,
        onChanged,
        radius,
        themeData.primaryColor,
        indicatorHeight,
      );
}

class CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;
  final double radius;
  final Color color;
  final double indicatorHeight;

  CustomPainter(
    this.decoration,
    VoidCallback? onChanged,
    this.radius,
    this.color,
    this.indicatorHeight,
  ) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    final Paint paint = Paint();
    double xAxisPos = offset.dx + configuration.size!.width / 2;
    double yAxisPos =
        offset.dy + configuration.size!.height - indicatorHeight / 2;
    paint.color = color;

    RRect fullRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(xAxisPos, yAxisPos),
        width: configuration.size!.width / 2,
        height: indicatorHeight,
      ),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );

    canvas.drawRRect(fullRect, paint);
  }
}
