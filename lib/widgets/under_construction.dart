import 'package:flutter/material.dart';

class UnderConstruction extends StatelessWidget {
  final double height;
  final Color stripeColor;
  final double opacity;

  const UnderConstruction({
    super.key,
    required this.height,
    required this.stripeColor,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _StripePainter(stripeColor),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color stripeColor;
  _StripePainter(this.stripeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const stripeWidth = 16.0;
    for(double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      paint.color = stripeColor;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
      paint.color = Colors.black87;
      final path2 = Path()
        ..moveTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth * 2, 0)
        ..lineTo(x + stripeWidth * 2 + size.height, size.height)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..close();
      canvas.drawPath(path2, paint2);
    }
  }

  final paint2 = Paint()..color = Colors.transparent;

  @override
  bool shouldRepaint(_) => false;
}
