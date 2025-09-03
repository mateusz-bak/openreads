import 'package:flutter/material.dart';

class ChartLegendElement extends StatelessWidget {
  const ChartLegendElement({
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
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$text ($number)',
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ]);
  }
}
