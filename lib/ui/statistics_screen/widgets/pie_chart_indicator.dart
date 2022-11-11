import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class PieChartIndicator extends StatelessWidget {
  const PieChartIndicator({
    super.key,
    required this.color,
    this.size = 16,
    required this.text,
  });
  final Color color;
  final double size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).mainTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      ],
    );
  }
}
