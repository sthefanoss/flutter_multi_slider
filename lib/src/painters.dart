import 'package:flutter/material.dart';

class MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final int selectedInputIndex;
  final double horizontalPadding;

  final Paint activeTrackColorPaint;
  final Paint bigCircleColorPaint;
  final Paint inactiveTrackColorPaint;

  MultiSliderPainter({
    bool isDisabled,
    Color activeTrackColor,
    Color inactiveTrackColor,
    Color disabledActiveTrackColor,
    Color disabledInactiveTrackColor,
    this.values,
    this.selectedInputIndex,
    this.horizontalPadding,
  })  : activeTrackColorPaint = _paintFromColor(
          isDisabled ? disabledActiveTrackColor : activeTrackColor,
          true,
        ),
        inactiveTrackColorPaint = _paintFromColor(
          isDisabled ? disabledInactiveTrackColor : inactiveTrackColor,
        ),
        bigCircleColorPaint = _paintFromColor(
          activeTrackColor.withOpacity(0.20),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final double halfHeight = size.height / 2;

    canvas.drawLine(Offset(horizontalPadding, halfHeight),
        Offset(values.first, halfHeight), inactiveTrackColorPaint);

    canvas.drawLine(Offset(values.first, halfHeight),
        Offset(values.last, halfHeight), activeTrackColorPaint);

    canvas.drawLine(
        Offset(values.last, halfHeight),
        Offset(size.width - horizontalPadding, halfHeight),
        inactiveTrackColorPaint);

    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(
          Offset(values[i], halfHeight), 10, _paintFromColor(Colors.white));
      canvas.drawCircle(
          Offset(values[i], halfHeight), 10, activeTrackColorPaint);

      if (selectedInputIndex != null)
        canvas.drawCircle(Offset(values[selectedInputIndex], halfHeight), 22.5,
            bigCircleColorPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static Paint _paintFromColor(Color color, [bool active = false]) {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = active ? 6 : 4
      ..isAntiAlias = true;
  }
}
