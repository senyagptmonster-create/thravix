import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/thravix_theme.dart';

class TurnstileFlowPainter extends CustomPainter {
  final double occupancyFraction;
  final double rotorAngle;

  TurnstileFlowPainter({required this.occupancyFraction, required this.rotorAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.44;

    // Outer perimeter occupancy ring
    final trackPaint = Paint()
      ..color = ThravixTheme.edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    final isOverCapacity = occupancyFraction >= 0.9;
    final arcColor = isOverCapacity
        ? ThravixTheme.danger
        : (occupancyFraction >= 0.75 ? ThravixTheme.warning : ThravixTheme.accent);

    final sweepAngle = 2 * pi * occupancyFraction.clamp(0.0, 1.0);
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Mechanical 3-bar Turnstile Rotor
    final armRadius = radius - 28;
    final armPaint = Paint()
      ..color = ThravixTheme.accentLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final angle = rotorAngle + (i * 2 * pi / 3);
      final armEnd = Offset(
        center.dx + armRadius * cos(angle),
        center.dy + armRadius * sin(angle),
      );
      canvas.drawLine(center, armEnd, armPaint);
      canvas.drawCircle(armEnd, 5, Paint()..color = Colors.white);
    }

    // Center rotor hub
    canvas.drawCircle(center, 18, Paint()..color = ThravixTheme.surface);
    canvas.drawCircle(center, 18, Paint()..color = ThravixTheme.accent..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawCircle(center, 8, Paint()..color = ThravixTheme.accentLight);
  }

  @override
  bool shouldRepaint(covariant TurnstileFlowPainter oldDelegate) {
    return oldDelegate.occupancyFraction != occupancyFraction ||
        oldDelegate.rotorAngle != rotorAngle;
  }
}
