part of flutter_multi_slider;

class _MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final List<double> positions;
  final int? selectedInputIndex;
  final double horizontalPadding;
  final int? divisions;
  final TrackbarBuilder trackbarBuilder;
  final List<Color>? rangeColors;
  final IndicatorBuilder? indicator;
  final IndicatorBuilder? selectedIndicator;
  final ThumbBuilder thumbBuilder;
  final double activeTrackSize;
  final double inactiveTrackSize;
  final TextDirection textDirection;
  final double textHeightOffset;
  final Color thumbColor;

  _MultiSliderPainter({
    required this.values,
    required this.positions,
    required this.selectedIndicator,
    required this.selectedInputIndex,
    required this.horizontalPadding,
    required this.divisions,
    required this.trackbarBuilder,
    required this.rangeColors,
    required this.indicator,
    required this.activeTrackSize,
    required this.inactiveTrackSize,
    required this.textDirection,
    required this.textHeightOffset,
    required this.thumbBuilder,
    required this.thumbColor,
  });

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
          index % 2 == 0,
          index % 2 == 1,
        ),
      );
    }

    final valueRanges = _makeRanges(positions, canvasStart, canvasEnd);
    final fistDot = trackbarBuilder(valueRanges.first);
    final lastDot = trackbarBuilder(valueRanges.last);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.first.start, baseLine),
        radius: fistDot.size! / 2,
      ),
      math.pi / 2,
      math.pi,
      true,
      _paintFromColor(fistDot.color!, 0),
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.last.end, baseLine),
        radius: lastDot.size! / 2,
      ),
      -math.pi / 2,
      math.pi,
      true,
      _paintFromColor(lastDot.color!, 0),
    );

    for (final valueRange in valueRanges) {
      final v = trackbarBuilder(valueRange);
      final Paint rangePaint = _paintFromColor(v.color!, v.size!);

      canvas.drawLine(
        Offset(valueRange.start, baseLine),
        Offset(valueRange.end, baseLine),
        rangePaint,
      );
    }

    if (divisions != null) {
      final divisionsList = List<double>.generate(
        divisions! + 1,
        (index) => canvasStart + index * (canvasEnd - canvasStart) / divisions!,
      );

      for (double x in divisionsList) {
        final valueRange = valueRanges.firstWhere(
          (valueRange) => valueRange.contains(x),
        );

        canvas.drawCircle(
          Offset(x, baseLine),
          1,
          _paintFromColor(
            trackbarBuilder(valueRange).isActive
                ? Colors.white.withOpacity(0.5)
                : thumbColor.withOpacity(0.5),
          ),
        );
      }
    }

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );

    for (int i = 0; i < positions.length; i++) {
      final isSelected = selectedInputIndex == i;
      final thumbValue = ThumbValue(i, values[i], isSelected);
      final thumbOptions = thumbBuilder(thumbValue);
      double x = divisions == null
          ? positions[i]
          : _getDiscreteValue(positions[i], canvasStart, canvasEnd, divisions!);

      if (isSelected) {
        canvas.drawCircle(
          Offset(x, baseLine),
          thumbOptions.radius! + 10,
          _paintFromColor(thumbOptions.color!.withOpacity(0.25)),
        );
      }

      IndicatorOptions? f;
      if (selectedIndicator != null && isSelected) {
        f = selectedIndicator!(thumbValue);
      } else if (indicator != null) {
        f = indicator!(thumbValue);
      }

      if (f != null && f.draw) {
        textPainter
          ..text = TextSpan(text: f.formatter(values[i]), style: f.style)
          ..layout()
          ..paint(
            canvas,
            Offset(
              x - textPainter.width / 2,
              baseLine - thumbOptions.radius! - textHeightOffset,
            ),
          );
      }

      // Draw thumb
      Path path = Path();
      path.addOval(
        Rect.fromCircle(
          center: Offset(x, baseLine),
          radius: thumbOptions.radius!,
        ),
      );
      if (thumbOptions.elevation! > 0) {
        canvas.drawShadow(path, Colors.black, thumbOptions.elevation!, true);
      }
      canvas.drawPath(
        path,
        _paintFromColor(
          thumbOptions.color!,
          activeTrackSize,
        ),
      );
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
