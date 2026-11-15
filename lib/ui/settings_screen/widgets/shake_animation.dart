import 'package:flutter/material.dart';

class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _turns;

  static const _angle = 20 / 360;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _turns = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: _angle), weight: 1),
      TweenSequenceItem(tween: Tween(begin: _angle, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: -_angle), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -_angle, end: 0), weight: 1),
    ]).chain(CurveTween(curve: Curves.bounceInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _turns,
      child: widget.child,
    );
  }
}
