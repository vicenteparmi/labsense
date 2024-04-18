import 'dart:math';
import 'package:flutter/material.dart';

class MaterialYouShape extends StatefulWidget {
  const MaterialYouShape({super.key, required this.pressed});

  final bool pressed;

  @override
  _MaterialYouShapeState createState() => _MaterialYouShapeState();
}

class _MaterialYouShapeState extends State<MaterialYouShape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: const Size(200, 200),
        painter: CirclePainter(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Create the painter
class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    List<Offset> points = [];
    for (double angle = 0; angle <= 2 * pi; angle += pi / 36) {
      final x = center.dx + (radius + sin(angle * 12) * 3) * cos(angle);
      final y = center.dy + (radius + sin(angle * 12) * 3) * sin(angle);
      points.add(Offset(x, y));
    }

    // Ensure the spline is closed properly
    points.add(points.first);

    final spline = CatmullRomSpline(points);

    final path = Path()
      ..addPolygon(
          spline.generateSamples().map((tn) => tn.value).toList(), true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
