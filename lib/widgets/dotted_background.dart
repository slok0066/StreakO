import 'package:flutter/material.dart';

class DottedBackground extends StatelessWidget {
  final Widget child;
  const DottedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? Colors.white10 : Colors.black12;

    return CustomPaint(
      painter: _DotPainter(dotColor: dotColor),
      child: child,
    );
  }
}

class _DotPainter extends CustomPainter {
  final Color dotColor;
  _DotPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double spacing = 24.0;
    final Paint paint = Paint()..color = dotColor;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
