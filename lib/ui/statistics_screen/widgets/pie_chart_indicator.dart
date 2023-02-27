import 'package:flutter/material.dart';

class PieChartIndicator extends StatelessWidget {
  const PieChartIndicator({
    super.key,
    required this.color,
    this.size = 14,
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          '$text ($number)',
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
