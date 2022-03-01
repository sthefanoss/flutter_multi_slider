import 'package:flutter/material.dart';
import 'dart:math' as math;

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

typedef ValueRangePainterCallback = bool Function(ValueRange valueRange);

class MultiSlider extends StatefulWidget {
  MultiSlider({
    required this.values,
    required this.onChanged,
    this.max = 1,
    this.min = 0,
    this.onChangeStart,
    this.onChangeEnd,
    this.color,
    this.horizontalPadding = 26.0,
    this.height = 45,
    this.divisions,
    this.valueRangePainterCallback,
    this.activeTrackColors,
    this.inactiveTrackColors,
    this.markerColors,
    this.markerIcons,
    this.activeTrackWidth,
    this.inactiveTrackWidth,
    this.unselectedMarkerRadius,
    this.selectedMarkerRadius,
    Key? key,
  })  : assert(divisions == null || divisions > 0),
        assert(max - min >= 0),
        range = max - min,
        super(key: key) {
    final valuesCopy = [...values]..sort();

    for (int index = 0; index < valuesCopy.length; index++) {
      assert(
        valuesCopy[index] == values[index],
        'MultiSlider: values must be in ascending order!',
      );
    }
    assert(
      values.first >= min && values.last <= max,
      'MultiSlider: At least one value is outside of min/max boundaries!',
    );

    assert(inactiveTrackColors == null || activeTrackColors?.length == values.length + 1,
        'MultiSlider: If specifying custom track colors, must specify values.length + 1 color values');

    assert(inactiveTrackColors == null || inactiveTrackColors?.length == values.length + 1,
        'MultiSlider: If specifying custom track colors, must specify values.length + 1 color values');
    
    assert(markerColors == null || markerColors?.length == values.length,
        'MultiSlider: If specifying custom marker colors, must specify same number of colors as values');
    
    assert(markerIcons == null || markerIcons?.length == values.length,
        'MultiSlider: If specifying custom track colors, must specify same number of icons as values');

  }

  /// [MultiSlider] maximum value.
  final double max;

  /// [MultiSlider] minimum value.
  final double min;

  /// Difference between [max] and [min]. Must be positive!
  final double range;

  /// [MultiSlider] vertical dimension. Used by [GestureDetector] and [CustomPainter].
  final double height;

  /// Empty space between the [MultiSlider] bar and the end of [GestureDetector] zone.
  final double horizontalPadding;

  /// Bar and indicators active color.
  final Color? color;

  /// List of ordered values which will be changed by user gestures with this widget.
  final List<double> values;

  /// Callback for every user slide gesture.
  final ValueChanged<List<double>>? onChanged;

  /// Callback for every time user click on this widget.
  final ValueChanged<List<double>>? onChangeStart;

  /// Callback for every time user stop click/slide on this widget.
  final ValueChanged<List<double>>? onChangeEnd;

  /// Number of divisions for discrete Slider.
  final int? divisions;

  /// Used to decide how a line between values or the boundaries should be painted.
  /// Returns [bool] and pass an [ValueRange] object as parameter.
  final ValueRangePainterCallback? valueRangePainterCallback;

  final List<Color>? activeTrackColors;

  final List<Color>? inactiveTrackColors;

  final List<Color>? markerColors;

  final List<IconData>? markerIcons;

  final double? activeTrackWidth;

  final double? inactiveTrackWidth;

  final double? unselectedMarkerRadius;

  final double? selectedMarkerRadius;

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> {
  double? _maxWidth;
  int? _selectedInputIndex;
  static const double _defaultActiveTrackWidth = 6;
  static const double _defaultInactiveTrackWidth = 4;  
  static const double _defaultUnselectedMarkerRadius = 10;
  static const double _defaultSelectedMarkerRadius = 22.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sliderTheme = SliderTheme.of(context);

    final bool isDisabled = widget.onChanged == null || widget.range == 0;

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        _maxWidth = constraints.maxWidth;
        return GestureDetector(
          child: Container(
            constraints: constraints,
            width: double.infinity,
            height: widget.height,
            child: CustomPaint(
              painter: _MultiSliderPainter(
                valueRangePainterCallback: widget.valueRangePainterCallback ??
                    _defaultDivisionPainterCallback,
                divisions: widget.divisions,
                isDisabled: isDisabled,
                activeTrackColor: widget.color ??
                    sliderTheme.activeTrackColor ??
                    theme.colorScheme.primary,
                inactiveTrackColor: widget.color?.withOpacity(0.24) ??
                    sliderTheme.inactiveTrackColor ??
                    theme.colorScheme.primary.withOpacity(0.24),
                disabledActiveTrackColor:
                    sliderTheme.disabledActiveTrackColor ??
                        theme.colorScheme.onSurface.withOpacity(0.40),
                disabledInactiveTrackColor:
                    sliderTheme.disabledInactiveTrackColor ??
                        theme.colorScheme.onSurface.withOpacity(0.12),
                selectedInputIndex: _selectedInputIndex,
                values:
                    widget.values.map(_convertValueToPixelPosition).toList(),
                horizontalPadding: widget.horizontalPadding,
                activeTrackColors: widget.activeTrackColors ?? [],
                inactiveTrackColors: widget.inactiveTrackColors ?? [],
                markerColors: widget.markerColors ?? [],
                markerIcons: widget.markerIcons ?? [],
                activeTrackWidth: widget.activeTrackWidth ?? _defaultActiveTrackWidth,
                inactiveTrackWidth: widget.inactiveTrackWidth ?? _defaultInactiveTrackWidth,
                unselectedMarkerRadius: widget.unselectedMarkerRadius ?? _defaultUnselectedMarkerRadius,
                selectedMarkerRadius: widget.selectedMarkerRadius ?? _defaultSelectedMarkerRadius
              ),
            ),
          ),
          onPanStart: isDisabled ? null : _handleOnChangeStart,
          onPanUpdate: isDisabled ? null : _handleOnChanged,
          onPanEnd: isDisabled ? null : _handleOnChangeEnd,
        );
      },
    );
  }

  void _handleOnChangeStart(DragStartDetails details) {
    double valuePosition = _convertPixelPositionToValue(
      details.localPosition.dx,
    );

    int index = _findNearestValueIndex(valuePosition);

    setState(() => _selectedInputIndex = index);

    final updatedValues = updateInternalValues(details.localPosition.dx);
    widget.onChanged!(updatedValues);
    if (widget.onChangeStart != null) widget.onChangeStart!(updatedValues);
  }

  void _handleOnChanged(DragUpdateDetails details) {
    widget.onChanged!(updateInternalValues(details.localPosition.dx));
  }

  void _handleOnChangeEnd(DragEndDetails details) {
    setState(() => _selectedInputIndex = null);

    if (widget.onChangeEnd != null) widget.onChangeEnd!(widget.values);
  }

  double _convertValueToPixelPosition(double value) {
    return (value - widget.min) *
            (_maxWidth! - 2 * widget.horizontalPadding) /
            (widget.range) +
        widget.horizontalPadding;
  }

  double _convertPixelPositionToValue(double pixelPosition) {
    final value = (pixelPosition - widget.horizontalPadding) *
            (widget.range) /
            (_maxWidth! - 2 * widget.horizontalPadding) +
        widget.min;

    return value;
  }

  List<double> updateInternalValues(double xPosition) {
    if (_selectedInputIndex == null) return widget.values;

    List<double> copiedValues = [...widget.values];

    double convertedPosition = _convertPixelPositionToValue(xPosition);

    copiedValues[_selectedInputIndex!] = convertedPosition.clamp(
      _calculateInnerBound(),
      _calculateOuterBound(),
    );

    if (widget.divisions != null) {
      return copiedValues
          .map<double>(
            (value) => _getDiscreteValue(
              value,
              widget.min,
              widget.max,
              widget.divisions!,
            ),
          )
          .toList();
    }
    return copiedValues;
  }

  double _calculateInnerBound() {
    return _selectedInputIndex == 0
        ? widget.min
        : widget.values[_selectedInputIndex! - 1];
  }

  double _calculateOuterBound() {
    return _selectedInputIndex == widget.values.length - 1
        ? widget.max
        : widget.values[_selectedInputIndex! + 1];
  }

  int _findNearestValueIndex(double convertedPosition) {
    if (widget.values.length == 1) return 0;

    List<double> differences = widget.values
        .map<double>((double value) => (value - convertedPosition).abs())
        .toList();
    double minDifference = differences.reduce(
      (previousValue, value) => value < previousValue ? value : previousValue,
    );

    int minDifferenceFirstIndex = differences.indexOf(minDifference);
    int minDifferenceLastIndex = differences.lastIndexOf(minDifference);

    bool hasCollision = minDifferenceLastIndex != minDifferenceFirstIndex;

    if (hasCollision &&
        (convertedPosition > widget.values[minDifferenceFirstIndex])) {
      return minDifferenceLastIndex;
    }
    return minDifferenceFirstIndex;
  }

  bool _defaultDivisionPainterCallback(ValueRange division) =>
      !division.isFirst && !division.isLast;
}

class _MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final int? selectedInputIndex;
  final double horizontalPadding;
  final Paint activeTrackColorPaint;
  final Paint bigCircleColorPaint;
  final Paint inactiveTrackColorPaint;
  final List<Color> activeTrackColors;
  final List<Color> inactiveTrackColors;
  final List<Color> markerColors;
  final List<IconData> markerIcons;
  final double activeTrackWidth;
  final double inactiveTrackWidth;
  final double unselectedMarkerRadius;
  final double selectedMarkerRadius;
  final int? divisions;
  final ValueRangePainterCallback valueRangePainterCallback;
  final bool isDisabled;

  _MultiSliderPainter({
    required this.isDisabled,
    required Color activeTrackColor,
    required Color inactiveTrackColor,
    required Color disabledActiveTrackColor,
    required Color disabledInactiveTrackColor,
    required this.values,
    required this.selectedInputIndex,
    required this.horizontalPadding,
    required this.divisions,
    required this.valueRangePainterCallback,
    required this.activeTrackColors,
    required this.inactiveTrackColors,
    required this.markerColors,
    required this.markerIcons,
    required this.activeTrackWidth,
    required this.inactiveTrackWidth,
    required this.unselectedMarkerRadius,
    required this.selectedMarkerRadius,
  })  : activeTrackColorPaint = paintFromColor(
          isDisabled ? disabledActiveTrackColor : activeTrackColor,
          activeTrackWidth,
          inactiveTrackWidth,
          true,
        ),
        inactiveTrackColorPaint = paintFromColor(
          isDisabled ? disabledInactiveTrackColor : inactiveTrackColor,
          activeTrackWidth,
          inactiveTrackWidth,
        ),
        bigCircleColorPaint = paintFromColor(
          activeTrackColor.withOpacity(0.20),
          activeTrackWidth,
          inactiveTrackWidth,
        );

  @override
  void paint(Canvas canvas, Size size) {
    final double halfHeight = size.height / 2;
    final activeTrackEndCapRadius = activeTrackWidth / 2;
    final inactiveTrackEndCapRadius = inactiveTrackWidth / 2;

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

    // TODO we could optimize this by making the decision one time on the colors creation
    Paint getTrackColor(int index, ValueRange valueRange) {
      if (isDisabled) {
        return inactiveTrackColorPaint;
      }
      if (valueRangePainterCallback(valueRange)) {
        if (activeTrackColors.length == 0) {
          return activeTrackColorPaint;
        } else {
          // TODO do we need to pre-generate the Paints from the Colors?
          return _paintFromColor(activeTrackColors[index]);
        }
      } else {
        if (inactiveTrackColors.length == 0) {
          return inactiveTrackColorPaint;
        } else {
          // TODO do we need to pre-generate the Paints from the Colors?
          return _paintFromColor(inactiveTrackColors[index]);
        }
      }
    }

    final valueRanges = _makeRanges(values, canvasStart, canvasEnd);

    // half circle at start of line
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.first.start, halfHeight),
        // TODO should we pre-calc this for performance reasons?
        radius: valueRangePainterCallback(valueRanges.last) ? activeTrackEndCapRadius : inactiveTrackEndCapRadius,
      ),
      math.pi / 2,
      math.pi,
      true,
      getTrackColor(0, valueRanges.first)
    );

    // half circle at start of line
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.last.end, halfHeight),
        // TODO should we pre-calc this for performance reasons?
        radius: valueRangePainterCallback(valueRanges.last) ? activeTrackEndCapRadius : inactiveTrackEndCapRadius,
      ),
      -math.pi / 2,
      math.pi,
      true,
      getTrackColor(valueRanges.length - 1, valueRanges.last)
    );

    // Draw all line segments in the middle of the slider
    for (int index = 0; index < valueRanges.length; index++) {
      var valueRange = valueRanges[index];
      canvas.drawLine(
        Offset(valueRange.start, halfHeight),
        Offset(valueRange.end, halfHeight),
        getTrackColor(index, valueRange),
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
          Offset(x, halfHeight),
          1,
          _paintFromColor(valueRangePainterCallback(valueRange)
              ? Colors.white.withOpacity(0.5)
              : activeTrackColorPaint.color.withOpacity(0.5)),
        );
      }
    }

    // TODO we could optimize this by making the decision one time on the colors creation
    Paint getMarkerColor({required double x, required int index, required bool selected}) {
      if (isDisabled) {
        return inactiveTrackColorPaint;
      }
      if (markerColors.length != 0) {
        return _paintFromColor(markerColors[index]);
      } else {
        return selected ? bigCircleColorPaint : activeTrackColorPaint;
      }
    }

    for (int i = 0; i < values.length; i++) {
      double x = divisions == null
          ? values[i]
          : _getDiscreteValue(values[i], canvasStart, canvasEnd, divisions!);

      canvas.drawCircle(
        Offset(x, halfHeight),
        unselectedMarkerRadius,
        _paintFromColor(Colors.white),
      );

      canvas.drawCircle(
        Offset(x, halfHeight),
        unselectedMarkerRadius,
        getMarkerColor(x: x, index: i, selected: false),
      );
      
      if (selectedInputIndex == i)
        canvas.drawCircle(
          Offset(x, halfHeight),
          selectedMarkerRadius,
          getMarkerColor(x: x, index: i, selected: true),
        );

      if (markerIcons.length > 0) {
        var icon = markerIcons[i];
        const fontPixelSize = 20.0;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
        textPainter.text = TextSpan(text: String.fromCharCode(icon.codePoint),
                style: TextStyle(fontSize: fontPixelSize,fontFamily: icon.fontFamily, color: Colors.white));
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - (fontPixelSize / 2), halfHeight - (fontPixelSize / 2)));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  static Paint paintFromColor(Color color, double activeTrackWidth, double inactiveTrackWidth, [bool active = false]) {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..strokeWidth = active ? activeTrackWidth : inactiveTrackWidth
      ..isAntiAlias = true;
  }

  Paint _paintFromColor(Color color, [bool active = false]) {
    return paintFromColor(color, activeTrackWidth, inactiveTrackWidth, active);
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
