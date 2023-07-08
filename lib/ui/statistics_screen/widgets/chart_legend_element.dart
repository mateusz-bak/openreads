import 'package:flutter/material.dart';

class ChartLegendElement extends StatelessWidget {
  const ChartLegendElement({
    super.key,
    required this.color,
    this.size = 14,
    required this.text,
    required this.number,
    this.reversed = false,
  });
  final Color color;
  final double size;
  final String text;
  final int number;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Text(
        '$text ($number)',
        style: const TextStyle(fontSize: 11),
      ),
      const SizedBox(width: 8),
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
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: reversed ? widgets.reversed.toList() : widgets,
    );
  }
}
