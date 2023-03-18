part of flutter_multi_slider;

class _MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final List<double> positions;
  final int? selectedInputIndex;
  final double horizontalPadding;
  final Paint activeTrackColorPaint;
  final Paint thumbColorPaint;
  final Paint bigCircleColorPaint;
  final Paint inactiveTrackColorPaint;
  final int? divisions;
  final ValueRangePainterCallback valueRangePainterCallback;
  final List<Color>? rangeColors;
  final double thumbRadius;
  final IndicatorBuilder? indicator;
  final IndicatorBuilder? selectedIndicator;
  final double activeTrackSize;
  final double inactiveTrackSize;
  final TextDirection textDirection;
  final double textHeightOffset;

  _MultiSliderPainter({
    required bool isDisabled,
    required Color activeTrackColor,
    required Color inactiveTrackColor,
    required Color disabledActiveTrackColor,
    required Color disabledInactiveTrackColor,
    required Color thumbColor,
    required this.values,
    required this.positions,
    required this.selectedIndicator,
    required this.selectedInputIndex,
    required this.horizontalPadding,
    required this.divisions,
    required this.valueRangePainterCallback,
    required this.rangeColors,
    required this.thumbRadius,
    required this.indicator,
    required this.activeTrackSize,
    required this.inactiveTrackSize,
    required this.textDirection,
    required this.textHeightOffset,
  })  : activeTrackColorPaint = _paintFromColor(
          isDisabled ? disabledActiveTrackColor : activeTrackColor,
          activeTrackSize,
        ),
        inactiveTrackColorPaint = _paintFromColor(
          isDisabled ? disabledInactiveTrackColor : inactiveTrackColor,
          inactiveTrackSize,
        ),
        thumbColorPaint = _paintFromColor(
          thumbColor,
          inactiveTrackSize,
        ),
        bigCircleColorPaint = _paintFromColor(
          activeTrackColor.withOpacity(0.20),
          inactiveTrackSize,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final double baseLine = size.height / 2;
    final canvasStart = horizontalPadding;
    final canvasEnd = size.width - horizontalPadding;

    List<ValueRange> _makeRanges(
      List<double> innerValues,
      double start,
      double end,
    ) {
      final values = <double>[
        start,
        ...innerValues
            .map<double>(divisions == null
                ? (v) => v
                : (v) => _getDiscreteValue(v, start, end, divisions!))
            .toList(),
        end
      ];
      return List<ValueRange>.generate(
        values.length - 1,
        (index) => ValueRange(
          values[index],
          values[index + 1],
          index,
          index == 0,
          index == values.length - 2,
        ),
      );
    }

    final valueRanges = _makeRanges(positions, canvasStart, canvasEnd);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.first.start, baseLine),
        radius: valueRangePainterCallback(valueRanges.first) ? 3 : 2,
      ),
      math.pi / 2,
      math.pi,
      true,
      valueRangePainterCallback(valueRanges.first)
          ? activeTrackColorPaint
          : inactiveTrackColorPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.last.end, baseLine),
        radius: valueRangePainterCallback(valueRanges.last) ? 3 : 2,
      ),
      -math.pi / 2,
      math.pi,
      true,
      valueRangePainterCallback(valueRanges.last)
          ? activeTrackColorPaint
          : inactiveTrackColorPaint,
    );

    for (ValueRange valueRange in valueRanges) {
      Color rangeColor = valueRangePainterCallback(valueRange)
          ? activeTrackColorPaint.color
          : inactiveTrackColorPaint.color;

      if (rangeColors != null && valueRange.index < rangeColors!.length) {
        rangeColor = rangeColors![valueRange.index];
      }

      final Paint rangePaint = _paintFromColor(
          rangeColor,
          valueRangePainterCallback(valueRange)
              ? activeTrackSize
              : inactiveTrackSize);

      canvas.drawLine(
        Offset(valueRange.start, baseLine),
        Offset(valueRange.end, baseLine),
        rangePaint,
      );
    }

    if (divisions != null) {
      final divisionsList = List<double>.generate(
          divisions! + 1,
          (index) =>
              canvasStart + index * (canvasEnd - canvasStart) / divisions!);

      for (double x in divisionsList) {
        final valueRange = valueRanges.firstWhere(
          (valueRange) => valueRange.contains(x),
        );

        canvas.drawCircle(
          Offset(x, baseLine),
          1,
          _paintFromColor(valueRangePainterCallback(valueRange)
              ? Colors.white.withOpacity(0.5)
              : activeTrackColorPaint.color.withOpacity(0.5)),
        );
      }
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );

    for (int i = 0; i < positions.length; i++) {
      final isSelected = selectedInputIndex == i;
      double x = divisions == null
          ? positions[i]
          : _getDiscreteValue(positions[i], canvasStart, canvasEnd, divisions!);

      if (isSelected)
        canvas.drawCircle(
          Offset(x, baseLine),
          thumbRadius + 10,
          bigCircleColorPaint,
        );

      IndicatorOptions? f;
      if (selectedIndicator != null && isSelected) {
        f = selectedIndicator!(values[i], i);
      } else if (indicator != null) {
        f = indicator!(values[i], i);
      }

      if (f != null && f.draw) {
        textPainter
          ..text = TextSpan(text: f.formatter(values[i]), style: f.style)
          ..layout()
          ..paint(
            canvas,
            Offset(
              x - textPainter.width / 2,
              baseLine - thumbRadius - textHeightOffset,
            ),
          );
      }

      // Draw thumb
      Path path = Path();
      path.addOval(
          Rect.fromCircle(center: Offset(x, baseLine), radius: thumbRadius));
      canvas.drawShadow(path, Colors.black, 3, true);
      canvas.drawPath(path, thumbColorPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static Paint _paintFromColor(Color color, [double strokeWidth = 6]) {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
  }
}

double _getDiscreteValue(
  double value,
  double start,
  double end,
  int divisions,
) {
  final k = (end - start) / divisions;
  return start + ((value - start) / k).roundToDouble() * k;
}