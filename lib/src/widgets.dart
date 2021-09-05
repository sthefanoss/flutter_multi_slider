import 'package:flutter/material.dart';

import 'painters.dart';

class MultiSlider extends StatefulWidget {
  final double max;
  final double min;
  final double _range;
  final double height;
  final double horizontalPadding;

  final Color? color;
  final List<double> values;
  final ValueChanged<List<double>>? onChanged;
  final ValueChanged<List<double>>? onChangeStart;
  final ValueChanged<List<double>>? onChangeEnd;

  MultiSlider({
    required this.values,
    required this.onChanged,
    this.max = 1,
    this.min = 0,
    this.onChangeStart,
    this.onChangeEnd,
    this.color,
    this.horizontalPadding = 20.0,
    this.height = 45,
  }) : _range = max - min {
    final valuesCopy = [...values];
    valuesCopy.sort();
    for (int index = 0; index < valuesCopy.length; index++)
      assert(
        valuesCopy[index] == values[index],
        'MultiSlider: values must be in ascending order!',
      );

    assert(
      values.first >= min && values.last <= max,
      'MultiSlider: At least one value is outside of min/max boundaries!',
    );
  }

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> {
  double? _maxWidth;
  int? selectedInputIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sliderTheme = SliderTheme.of(context);

    final bool isDisabled = widget.onChanged == null;

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        _maxWidth = constraints.maxWidth;
        return GestureDetector(
          child: Container(
            constraints: constraints,
            width: double.infinity,
            height: widget.height,
            child: CustomPaint(
              painter: MultiSliderPainter(
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
                selectedInputIndex: selectedInputIndex,
                values: widget.values.map(convertValueToPixelPosition).toList(),
                horizontalPadding: widget.horizontalPadding,
              ),
            ),
          ),
          onPanStart: isDisabled ? null : handleOnChangeStart,
          onPanUpdate: isDisabled ? null : handleOnChanged,
          onPanEnd: isDisabled ? null : handleOnChangeEnd,
        );
      },
    );
  }

  void handleOnChangeStart(DragStartDetails details) {
    double valuePosition = convertPixelPositionToValue(
      details.localPosition.dx,
    );

    int index = findNearestValueIndex(valuePosition);

    setState(() => selectedInputIndex = index);

    if (widget.onChangeStart != null) widget.onChangeStart!(widget.values);
  }

  void handleOnChanged(DragUpdateDetails details) {
    widget.onChanged!(updateInternalValues(details.localPosition.dx));
  }

  void handleOnChangeEnd(DragEndDetails details) {
    setState(() => selectedInputIndex = null);

    if (widget.onChangeEnd != null) widget.onChangeEnd!(widget.values);
  }

  double convertValueToPixelPosition(double value) {
    return (value - widget.min) *
            (_maxWidth! - 2 * widget.horizontalPadding) /
            (widget._range) +
        widget.horizontalPadding;
  }

  double convertPixelPositionToValue(double pixelPosition) {
    return (pixelPosition - widget.horizontalPadding) *
            (widget._range) /
            (_maxWidth! - 2 * widget.horizontalPadding) +
        widget.min;
  }

  List<double> updateInternalValues(double xPosition) {
    if (selectedInputIndex == null) return widget.values;

    List<double> copiedValues = [...widget.values];

    double convertedPosition = convertPixelPositionToValue(xPosition);

    copiedValues[selectedInputIndex!] = convertedPosition.clamp(
      calculateInnerBound(),
      calculateOuterBound(),
    );

    return copiedValues;
  }

  double calculateInnerBound() {
    return selectedInputIndex == 0
        ? widget.min
        : widget.values[selectedInputIndex! - 1];
  }

  double calculateOuterBound() {
    return selectedInputIndex == widget.values.length - 1
        ? widget.max
        : widget.values[selectedInputIndex! + 1];
  }

  int findNearestValueIndex(double convertedPosition) {
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
}
