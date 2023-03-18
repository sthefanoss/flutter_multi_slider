part of flutter_multi_slider;

/// Used in [ValueRangePainterCallback] as parameter.
/// Every range between the edges of [MultiSlider] generate an [ValueRange].
/// Do NOT be mistaken with discrete intervals made by [divisions]!
class ValueRange {
  const ValueRange(
    this.start,
    this.end,
    this.index,
    this.isFirst,
    this.isLast,
  );

  final double start;
  final double end;
  final int index;
  final bool isFirst;
  final bool isLast;

  bool contains(double x) => x >= start && x <= end;
}

class IndicatorOptions {
  const IndicatorOptions({
    this.formatter = defaultFormatter,
    this.style,
    this.draw = true,
  });

  /// Used to define how [value] will be formatted.
  final String Function(double value) formatter;

  /// [TextStyle] used to draw formatted [value]
  final TextStyle? style;

  /// Use to choose if indicator will be drawn or not.
  final bool draw;

  static String defaultFormatter(double value) => value.toStringAsPrecision(2);

  IndicatorOptions copyWith({
    String Function(double value)? formatter,
    TextStyle? style,
    bool? draw,
  }) =>
      IndicatorOptions(
        formatter: formatter ?? this.formatter,
        style: style ?? this.style,
        draw: draw ?? this.draw,
      );
}
