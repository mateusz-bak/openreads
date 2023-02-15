import 'package:flutter/material.dart';

class PieChartIndicator extends StatelessWidget {
  const PieChartIndicator({
    super.key,
    required this.color,
    this.size = 16,
    required this.text,
    required this.number,
  });
  final Color color;
  final double size;
  final String text;
  final int number;

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
        const SizedBox(width: 4),
        Text(
          '$text ($number)',
          style: const TextStyle(fontSize: 12),
        )
      ],
    );
  }
}
