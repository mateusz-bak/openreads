import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme.of(context).brightness == Brightness.light
          ? _buildLightCard(context)
          : _buildDarkCard(context),
    );
  }

  Card _buildLightCard(BuildContext context) {
    return Card(
      color: lightCardColor,
      shadowColor: Colors.black.withAlpha(40),
      elevation: 5,
      shape: cardShape,
      child: child,
    );
  }

  Card _buildDarkCard(BuildContext context) {
    return Card(
      color: darkCardColor,
      shape: cardShape,
      child: child,
    );
  }
}
