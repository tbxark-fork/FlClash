import 'dart:math';
import 'package:flutter/material.dart';

@immutable
class DonutChartData {
  final double _value;
  final Color color;

  const DonutChartData({
    required double value,
    required this.color,
  }) : _value = value + 0.01;

  double get value => _value;
}

class DonutChart extends StatelessWidget {
  final List<DonutChartData> data;

  const DonutChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DonutChartPainter(data),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<DonutChartData> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    double gapAngle = 2 * asin(strokeWidth * 1 / (2 * radius)) * 1.2;

    final total = data.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final availableAngle = 2 * pi - (data.length * gapAngle);

    double startAngle = -pi / 2;

    for (final item in data) {
      final sweepAngle = availableAngle * (item.value / total);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = item.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return true;
  }
}
