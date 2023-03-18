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

  final String Function(double value) formatter;
  final TextStyle? style;
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

class Foo {
  Foo({this.color, required this.isBold});

  final Color? color;
  final bool isBold;
}
