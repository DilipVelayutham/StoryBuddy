import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BubblyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const BubblyButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.primaryPurple,
    this.foregroundColor = AppColors.textLight,
    this.borderColor = Colors.transparent,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  // Helper factory for simple text buttons
  factory BubblyButton.text({
    Key? key,
    required VoidCallback? onPressed,
    required String label,
    Color backgroundColor = AppColors.primaryPurple,
    IconData? icon,
  }) {
    return BubblyButton(
      key: key,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: AppColors.textLight),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<BubblyButton> createState() => _BubblyButtonState();
}

class _BubblyButtonState extends State<BubblyButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _scale = 0.94; // Compress slightly on tap
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _scale = 1.06; // Spring out slightly
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _scale = 1.0;
          });
        }
      });
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      setState(() {
        _scale = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutBack,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                : null,
          ),
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
