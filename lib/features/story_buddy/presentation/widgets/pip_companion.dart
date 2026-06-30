import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/story_model.dart';
import '../providers/pip_provider.dart';

class PipCompanion extends StatefulWidget {
  final PipState state;
  final StoryModel? story;

  const PipCompanion({
    super.key,
    required this.state,
    this.story,
  });

  @override
  State<PipCompanion> createState() => _PipCompanionState();
}

class _PipCompanionState extends State<PipCompanion> with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _speakingController;
  late AnimationController _gearController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();

    // Idle controller runs breathing/floating loops continuously
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Speaking mouth animation loop
    _speakingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // Gear rotation controller runs continuously
    _gearController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Correct answer/celebration bounce controller
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _syncAnimations();
  }

  @override
  void didUpdateWidget(covariant PipCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimations();
  }

  void _syncAnimations() {
    // Speaking animations mouth movement
    if (widget.state == PipState.speaking) {
      _speakingController.repeat(reverse: true);
    } else {
      _speakingController.stop();
      _speakingController.value = 0.0;
    }

    // Gear speed adjust based on state
    _gearController.stop();
    if (widget.state == PipState.celebrating || widget.state == PipState.happy) {
      _gearController.duration = const Duration(milliseconds: 800); // spin fast!
      _gearController.repeat();
    } else if (widget.state == PipState.thinking) {
      // Gear stops spinning when thinking (reflecting story context)
    } else {
      _gearController.duration = const Duration(seconds: 4); // spin normal
      _gearController.repeat();
    }

    // Bounce animation on celebration / happy transition
    if (widget.state == PipState.celebrating || widget.state == PipState.happy) {
      _bounceController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _speakingController.dispose();
    _gearController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _speakingController,
        _gearController,
        _bounceController,
      ]),
      builder: (context, child) {
        // Floating Vertical Math
        // Float amplitude: 10px
        final floatOffset = math.sin(_idleController.value * 2 * math.pi) * 10.0;

        // Gentle breathing scale math: 1.0 to 1.04
        final breathScale = 1.0 + (math.sin(_idleController.value * 2 * math.pi) * 0.02);

        // Celebrating Bounce Math
        double bounceOffset = 0.0;
        if (_bounceController.isAnimating || _bounceController.value > 0.0) {
          // Sine curve bounce scaling down
          bounceOffset = -math.sin(_bounceController.value * math.pi) * 25.0;
        }

        // Return container with RepaintBoundary to avoid redrawing full screen layout
        return Container(
          height: 180,
          width: 180,
          alignment: Alignment.center,
          child: RepaintBoundary(
            child: Transform.translate(
              offset: Offset(0, floatOffset + bounceOffset),
              child: Transform.scale(
                scale: breathScale,
                child: CustomPaint(
                  size: const Size(140, 140),
                  painter: PipPainter(
                    state: widget.state,
                    mouthOpen: _speakingController.value,
                    gearRotation: _gearController.value * 2 * math.pi,
                    theme: widget.story?.pipTheme,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PipPainter extends CustomPainter {
  final PipState state;
  final double mouthOpen;
  final double gearRotation;
  final PipThemeModel? theme;

  PipPainter({
    required this.state,
    required this.mouthOpen,
    required this.gearRotation,
    this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Colors
    final primaryColor = theme?.primaryColor ?? AppColors.lavender;
    final secondaryColor = theme?.secondaryColor ?? AppColors.skyBlue;
    final headColor = theme?.headColor ?? AppColors.primaryLight;
    final gearColor = theme?.gearColor ?? AppColors.skyBlue;

    // Outer Glow / Shadow
    final shadowPaint = Paint()
      ..color = (theme?.primaryColor ?? AppColors.primaryPurple).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, cy + 10), 55, shadowPaint);

    // 1. Draw Neck
    final neckPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy + 20, 30, 20),
        const Radius.circular(8),
      ),
      neckPaint,
    );

    // 2. Draw Ears
    final earPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final earDetailPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Left Ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 58, cy - 35, 12, 30),
        const Radius.circular(6),
      ),
      earPaint,
    );
    canvas.drawCircle(Offset(cx - 52, cy - 20), 4, earDetailPaint);

    // Right Ear
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 46, cy - 35, 12, 30),
        const Radius.circular(6),
      ),
      earPaint,
    );
    canvas.drawCircle(Offset(cx + 52, cy - 20), 4, earDetailPaint);

    // 3. Draw Antenna
    final antennaLinePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 45), Offset(cx, cy - 65), antennaLinePaint);

    // Antenna Bulb
    Color bulbColor = secondaryColor;
    if (state == PipState.speaking) bulbColor = AppColors.candyPink;
    if (state == PipState.thinking) bulbColor = AppColors.sunshineYellow;
    if (state == PipState.celebrating || state == PipState.happy) {
      bulbColor = AppColors.mintGreen;
    }
    
    final antennaBulbPaint = Paint()
      ..color = bulbColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 72), 8, antennaBulbPaint);

    // Bulb glow
    final bulbGlowPaint = Paint()
      ..color = bulbColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy - 72), 12, bulbGlowPaint);

    // 4. Draw Head (Glassmorphic look)
    final headPaint = Paint()
      ..color = headColor
      ..style = PaintingStyle.fill;
    final headBorderPaint = Paint()
      ..color = (theme?.primaryColor ?? AppColors.primaryPurple).withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 48, cy - 50, 96, 75),
        const Radius.circular(24),
      ),
      headPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 48, cy - 50, 96, 75),
        const Radius.circular(24),
      ),
      headBorderPaint,
    );

    // 5. Draw Face Screen (Rounded screen inside head)
    final faceScreenPaint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 38, cy - 40, 76, 55),
        const Radius.circular(16),
      ),
      faceScreenPaint,
    );

    // 6. Draw Eyes (based on PipState)
    final eyePaint = Paint()..style = PaintingStyle.fill;
    
    // Choose eye glow color
    Color eyeColor = secondaryColor;
    if (state == PipState.thinking) eyeColor = AppColors.sunshineYellow;
    if (state == PipState.celebrating || state == PipState.happy) {
      eyeColor = AppColors.mintGreen;
    }
    eyePaint.color = eyeColor;

    if (state == PipState.thinking) {
      // Swirling/arc thinking eyes
      final leftEyeRect = Rect.fromCenter(center: Offset(cx - 18, cy - 20), width: 14, height: 14);
      final rightEyeRect = Rect.fromCenter(center: Offset(cx + 18, cy - 20), width: 14, height: 14);
      
      final thinkingEyeStroke = Paint()
        ..color = AppColors.sunshineYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      // Draw partial circle arcs representing thinking process
      canvas.drawArc(leftEyeRect, gearRotation, 3 * math.pi / 2, false, thinkingEyeStroke);
      canvas.drawArc(rightEyeRect, -gearRotation, 3 * math.pi / 2, false, thinkingEyeStroke);
    } else if (state == PipState.celebrating || state == PipState.happy) {
      // Squinting happy arc eyes (upside down Us)
      final happyEyeStroke = Paint()
        ..color = AppColors.mintGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      final pathLeft = Path()
        ..moveTo(cx - 25, cy - 18)
        ..quadraticBezierTo(cx - 18, cy - 26, cx - 11, cy - 18);
      
      final pathRight = Path()
        ..moveTo(cx + 11, cy - 18)
        ..quadraticBezierTo(cx + 18, cy - 26, cx + 25, cy - 18);

      canvas.drawPath(pathLeft, happyEyeStroke);
      canvas.drawPath(pathRight, happyEyeStroke);
    } else {
      // Normal rounded glowing eyes
      canvas.drawCircle(Offset(cx - 18, cy - 20), 7, eyePaint);
      canvas.drawCircle(Offset(cx + 18, cy - 20), 7, eyePaint);
      
      // Pupil shine white circles
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 20, cy - 22), 2, shinePaint);
      canvas.drawCircle(Offset(cx + 16, cy - 22), 2, shinePaint);
    }

    // 7. Draw Mouth (based on PipState)
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    if (state == PipState.speaking) {
      // Animate mouth opening oval shape
      final speakingMouthPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - 2),
            width: 14,
            height: 4 + (mouthOpen * 12),
          ),
          const Radius.circular(6),
        ),
        speakingMouthPaint,
      );
    } else if (state == PipState.thinking) {
      // Flat line mouth
      canvas.drawLine(Offset(cx - 8, cy - 2), Offset(cx + 8, cy - 2), mouthPaint);
    } else if (state == PipState.celebrating || state == PipState.happy) {
      // Large crescent smile filled
      final happyMouthPaint = Paint()
        ..color = AppColors.candyPink
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(cx - 10, cy - 4)
        ..quadraticBezierTo(cx, cy + 6, cx + 10, cy - 4)
        ..quadraticBezierTo(cx, cy + 10, cx - 10, cy - 4);
      canvas.drawPath(path, happyMouthPaint);
    } else if (state == PipState.listening) {
      // O mouth showing attentive listening
      final listeningMouthPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset(cx, cy - 2), 4, listeningMouthPaint);
    } else {
      // Gentle curve smile
      final path = Path()
        ..moveTo(cx - 8, cy - 4)
        ..quadraticBezierTo(cx, cy + 2, cx + 8, cy - 4);
      canvas.drawPath(path, mouthPaint);
    }

    // 8. Draw Body (Chest Panel with a window showing the gear)
    final bodyPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final bodyBorderPaint = Paint()
      ..color = (theme?.primaryColor ?? AppColors.primaryPurple).withValues(alpha: 0.4)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 36, cy + 32, 72, 55),
        const Radius.circular(16),
      ),
      bodyPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 36, cy + 32, 72, 55),
        const Radius.circular(16),
      ),
      bodyBorderPaint,
    );

    // Inner Chest Screen
    final chestScreenPaint = Paint()
      ..color = AppColors.textDark.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24, cy + 38, 48, 38),
        const Radius.circular(8),
      ),
      chestScreenPaint,
    );

    // 9. Draw the Gear inside chest screen!
    final gearCx = cx;
    final gearCy = cy + 57;
    
    canvas.save();
    canvas.translate(gearCx, gearCy);
    
    // Rotate canvas according to state-driven gear rotation
    if (state != PipState.thinking) {
      canvas.rotate(gearRotation);
    }

    final gearPaint = Paint()
      ..style = PaintingStyle.fill;

    if (state == PipState.thinking) {
      // When thinking, gear is inactive/de-energized (grey)
      gearPaint.color = Colors.grey;
    } else if (state == PipState.celebrating || state == PipState.happy) {
      // When happy/celebrating, gear glows vibrant warm pink/coral
      gearPaint.color = AppColors.candyPink;
    } else {
      // Standard state: the shiny gear!
      gearPaint.color = gearColor;
    }

    // Draw Gear Hub
    canvas.drawCircle(Offset.zero, 7, gearPaint);

    // Draw Spokes/Teeth of the gear
    const teethCount = 8;
    for (int i = 0; i < teethCount; i++) {
      canvas.save();
      canvas.rotate(i * (2 * math.pi / teethCount));
      // Rect representing a gear tooth
      canvas.drawRect(
        Rect.fromLTWH(-3, -11, 6, 5),
        gearPaint,
      );
      canvas.restore();
    }

    // Inner hole in the gear hub
    final holePaint = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 3, holePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PipPainter oldDelegate) {
    return oldDelegate.state != state ||
        oldDelegate.mouthOpen != mouthOpen ||
        oldDelegate.gearRotation != gearRotation ||
        oldDelegate.theme != theme;
  }
}
