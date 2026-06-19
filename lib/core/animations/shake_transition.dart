import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShakeTransition extends StatefulWidget {
  final Widget child;
  final int trigger;
  final double offsetRange;

  const ShakeTransition({
    super.key,
    required this.child,
    required this.trigger,
    this.offsetRange = 10.0,
  });

  @override
  State<ShakeTransition> createState() => _ShakeTransitionState();
}

class _ShakeTransitionState extends State<ShakeTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant ShakeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger > 0) {
      // Trigger the shake animation!
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value == 0.0) return widget.child;

        // Sine wave calculations to move child left/right
        // _controller.value goes 0.0 -> 1.0
        // We shake 3 full cycles (6 pi)
        // Damping factor (1.0 - _controller.value) dampens the shake towards the end
        final dx = math.sin(_controller.value * 6 * math.pi) * 
            widget.offsetRange * 
            (1.0 - _controller.value);

        return Transform.translate(
          offset: Offset(dx, 0),
          child: widget.child,
        );
      },
    );
  }
}
