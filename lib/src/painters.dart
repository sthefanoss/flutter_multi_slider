import 'package:flutter/material.dart';

class MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final int selectedInputIndex;
  final double widthOffset;
  const MultiSliderPainter(
      {this.values, this.selectedInputIndex, this.widthOffset});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.blue
      ..isAntiAlias = true;

    var selectedPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red
      ..isAntiAlias = true;

    canvas.drawLine(Offset(widthOffset, size.height / 2),
        Offset(size.width - widthOffset, size.height / 2), paint);

    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(values[i], size.height / 2), 10,
          i == selectedInputIndex ? selectedPaint : paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
