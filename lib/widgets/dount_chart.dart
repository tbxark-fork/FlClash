import 'dart:math';
import 'package:fl_clash/common/common.dart';
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

class DonutChart extends StatefulWidget {
  final List<DonutChartData> data;
  final Duration duration;

  const DonutChart({
    super.key,
    required this.data,
    this.duration = commonDuration,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<DonutChartData> _oldData;

  @override
  void initState() {
    super.initState();
    _oldData = widget.data;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _oldData = oldWidget.data;
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: DonutChartPainter(
            _oldData,
            widget.data,
            _animationController.value,
          ),
        );
      },
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<DonutChartData> oldData;
  final List<DonutChartData> newData;
  final double progress;

  DonutChartPainter(this.oldData, this.newData, this.progress);

  List<DonutChartData> get interpolatedData {
    if (oldData.length != newData.length) return newData;

    return List.generate(newData.length, (index) {
      final oldValue = oldData[index].value;
      final newValue = newData[index].value;
      final interpolatedValue = oldValue + (newValue - oldValue) * progress;

      return DonutChartData(
        value: interpolatedValue,
        color: Color.lerp(oldData[index].color, newData[index].color, progress)!,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.0;
    final radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;

    double gapAngle = 2 * asin(strokeWidth * 1 / (2 * radius)) * 1.2;

    final data = interpolatedData;
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
    return oldDelegate.progress != progress ||
        oldDelegate.oldData != oldData ||
        oldDelegate.newData != newData;
  }
}