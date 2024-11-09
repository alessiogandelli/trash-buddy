import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
  const  double radius = 27; // Adjust this value to change the corner radius

  final path = Path()
    ..moveTo(0, radius)
    ..lineTo(0, size.height - radius)
    ..quadraticBezierTo(0, size.height, radius, size.height)
    ..lineTo(size.width / 2 - radius, size.height)
    ..lineTo(size.width / 2, size.height + radius) // Tail point moved to bottom
    ..lineTo(size.width / 2 + radius, size.height)
    ..lineTo(size.width - radius, size.height)
    ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
    ..lineTo(size.width, radius)
    ..quadraticBezierTo(size.width, 0, size.width - radius, 0)
    ..lineTo(radius, 0)
    ..quadraticBezierTo(0, 0, 0, radius);

    // Add shadow
    canvas.drawShadow(path, Colors.black26, 4.0, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
