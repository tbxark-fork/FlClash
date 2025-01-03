import 'dart:ui';

import 'package:flutter/material.dart';

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() {
    return 'Point{x: $x, y: $y}';
  }
}

class LineChart extends StatefulWidget {
  final List<Point> points;
  final Color color;
  final Duration duration;
  final bool gradient;

  const LineChart({
    super.key,
    this.gradient = false,
    required this.points,
    required this.color,
    this.duration = const Duration(milliseconds: 0),
  });

  @override
  State<LineChart> createState() => _LineChartState();
}

typedef ComputedPath = Path Function(Size size);

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double progress = 0;
  List<Point> prevPoints = [];
  List<Point> nextPoints = [];
  List<Point> points = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    points = widget.points;
    prevPoints = points;
  }

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points != points) {
      prevPoints = points;
      if (!_controller.isCompleted) {
        prevPoints = nextPoints;
      }
      points = widget.points;
      _controller.forward(from: 0);
    }
  }

  List<Point> getRenderPoints(List<Point> points) {
    if (points.isEmpty) return [];
    double maxX = points[0].x;
    double minX = points[0].x;
    double maxY = points[0].y;
    double minY = points[0].y;
    for (final point in points) {
      if (point.x > maxX) maxX = point.x;
      if (point.x < minX) minX = point.x;
      if (point.y > maxY) maxY = point.y;
      if (point.y < minY) minY = point.y;
    }
    return points.map((e) {
      var x = (e.x - minX) / (maxX - minX);
      if (x.isNaN) {
        x = 0.5;
      }

      var y = (e.y - minY) / (maxY - minY);
      if (y.isNaN) {
        y = 0.5;
      }

      return Point(
        x,
        y,
      );
    }).toList();
  }

  List<Point> getInterpolatePoints(
    List<Point> prevPoints,
    List<Point> points,
    double t,
  ) {
    var renderPrevPoints = getRenderPoints(prevPoints);
    var renderPotions = getRenderPoints(points);
    return List.generate(renderPotions.length, (i) {
      if (i > renderPrevPoints.length - 1) {
        return renderPotions[i];
      }
      var x = lerpDouble(renderPrevPoints[i].x, renderPotions[i].x, t)!;
      var y = lerpDouble(renderPrevPoints[i].y, renderPotions[i].y, t)!;
      return Point(
        x,
        y,
      );
    });
  }

  Path getPath(List<Point> points, Size size) {
    final path = Path()
      ..moveTo(points[0].x * size.width, (1 - points[0].y) * size.height);

    for (var i = 1; i < points.length - 1; i++) {
      final nextPoint = points[i + 1];
      final currentPoint = points[i];
      final midX = (currentPoint.x + nextPoint.x) / 2;
      final midY = (currentPoint.y + nextPoint.y) / 2;
      path.quadraticBezierTo(
        currentPoint.x * size.width,
        (1 - currentPoint.y) * size.height,
        midX * size.width,
        (1 - midY) * size.height,
      );
    }
    path.lineTo(points.last.x * size.width, (1 - points.last.y) * size.height);

    return path;
  }

  ComputedPath getComputedPath({
    required List<Point> prevPoints,
    required List<Point> points,
    required progress,
  }) {
    nextPoints = getInterpolatePoints(prevPoints, points, progress);
    return (size) {
      final prevPath = getPath(prevPoints, size);
      final nextPath = getPath(nextPoints, size);
      final prevMetric = prevPath.computeMetrics().first;
      final nextMetric = nextPath.computeMetrics().first;
      final prevLength = prevMetric.length;
      final nextLength = nextMetric.length;
      return nextMetric.extractPath(
        0,
        prevLength + (nextLength - prevLength) * progress,
      );
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, container) {
      return AnimatedBuilder(
        animation: _controller.view,
        builder: (_, __) {
          return CustomPaint(
            painter: LineChartPainter(
              gradient: widget.gradient,
              color: widget.color,
              computedPath: getComputedPath(
                prevPoints: prevPoints,
                points: points,
                progress: _controller.value,
              ),
            ),
            child: SizedBox(
              height: container.maxHeight,
              width: container.maxWidth,
            ),
          );
        },
      );
    });
  }
}

class LineChartPainter extends CustomPainter {
  final ComputedPath computedPath;
  final Color color;
  final bool gradient;

  LineChartPainter({
    required this.computedPath,
    required this.color,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 2.0;
    final path = computedPath(Size(size.width, size.height * 0.7));

    if (gradient) {
      final fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height + strokeWidth * 2);
      fillPath.lineTo(0, size.height + strokeWidth * 2);
      fillPath.close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.1),
        ],
      );

      final shader = gradient.createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height + strokeWidth * 2,
        ),
      );

      final fillPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
