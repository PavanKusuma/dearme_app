import 'package:flutter/material.dart';

class VerticalDottedLine extends StatelessWidget {
  final double height;
  final Color color;

  const VerticalDottedLine({
    Key? key,
    required this.height,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _VerticalDottedLinePainter(color),
      ),
    );
  }
}

class _VerticalDottedLinePainter extends CustomPainter {
  final Color color;

  _VerticalDottedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashWidth = 5;
    const dashSpace = 5;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashWidth),
          paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_VerticalDottedLinePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
