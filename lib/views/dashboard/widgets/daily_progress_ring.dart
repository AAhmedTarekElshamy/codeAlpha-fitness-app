import 'dart:math';
import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class DailyProgressRing extends StatelessWidget {
  final int steps;
  final int targetSteps;
  final double size;

  const DailyProgressRing({
    super.key,
    required this.steps,
    required this.targetSteps,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = targetSteps > 0 ? steps / targetSteps : 0.0;
    // Cap percentage at 1.0 for full circle, but we can draw multiple loops or just cap it. Let's cap at 1.0 for visual simplicity.
    final double cappedPercentage = min(percentage, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: cappedPercentage),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: RingPainter(
                  progress: value,
                  trackColor: FitnessTheme.cardBg.withOpacity(0.5),
                  progressColor: FitnessTheme.steps,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_run,
                    color: FitnessTheme.steps,
                    size: size * 0.15,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    steps.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},'),
                    style: TextStyle(
                      fontSize: size * 0.16,
                      fontWeight: FontWeight.bold,
                      color: FitnessTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'of $targetSteps steps',
                    style: TextStyle(
                      fontSize: size * 0.065,
                      color: FitnessTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FitnessTheme.steps.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: size * 0.06,
                        color: FitnessTheme.steps,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12; // padding
    const strokeWidth = 14.0;

    // 1. Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -pi / 2; // start at the top
      final sweepAngle = 2 * pi * progress;

      // Draw progress path with gradient
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            progressColor.withOpacity(0.3),
            progressColor,
          ],
          stops: const [0.0, 1.0],
          transform: const GradientRotation(-pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

      // 3. Optional: Add a little glowing dot at the end of the arc
      final endAngle = startAngle + sweepAngle;
      final dotOffset = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle),
      );

      final glowPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(dotOffset, strokeWidth * 0.7, glowPaint);
      
      final solidPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotOffset, strokeWidth * 0.4, solidPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
