import 'package:flutter/material.dart';

import 'painters.dart';

class MultiSlider extends StatefulWidget {
  final double max;
  final double min;
  final double _range;
  final double height;
  final double horizontalPadding;

  final Color activeColor;
  final Color inactiveColor;

  final List<double> values;
  final ValueChanged<List<double>> onChanged;
  final ValueChanged<List<double>> onChangeStart;
  final ValueChanged<List<double>> onChangeEnd;

  const MultiSlider({
    @required this.values,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.max = 1.0,
    this.min = 0.0,
    this.activeColor,
    this.inactiveColor,
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
  double _maxWidth;
  int selectedInputIndex;
  List<double> _internalValues;

  @override
  void initState() {
    _internalValues = widget.values;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    SliderThemeData sliderTheme = SliderTheme.of(context);

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
                activeTrackColor: widget.activeColor ??
                    sliderTheme.activeTrackColor ??
                    theme.colorScheme.primary,
                inactiveTrackColor: widget.inactiveColor ??
                    sliderTheme.inactiveTrackColor ??
                    theme.colorScheme.primary.withOpacity(0.24),
                disabledActiveTrackColor:
                    sliderTheme.disabledActiveTrackColor ??
                        theme.colorScheme.onSurface.withOpacity(0.40),
                disabledInactiveTrackColor:
                    sliderTheme.disabledInactiveTrackColor ??
                        theme.colorScheme.onSurface.withOpacity(0.12),
                selectedInputIndex: selectedInputIndex,
                values:
                    _internalValues.map(convertValueToPixelPosition).toList(),
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

    if (widget.onChangeStart != null) widget.onChangeStart(_internalValues);
  }

  void handleOnChanged(DragUpdateDetails details) {
    _internalValues = updateInternalValues(details.localPosition.dx);
    widget.onChanged(_internalValues);
  }

  void handleOnChangeEnd(DragEndDetails details) {
    setState(() => selectedInputIndex = null);

    if (widget.onChangeEnd != null) widget.onChangeEnd(_internalValues);
  }

  double convertValueToPixelPosition(double value) {
    return (value - widget.min) *
            (_maxWidth - 2 * widget.horizontalPadding) /
            (widget._range) +
        widget.horizontalPadding;
  }

  double convertPixelPositionToValue(double pixelPosition) {
    return (pixelPosition - widget.horizontalPadding) *
            (widget._range) /
            (_maxWidth - 2 * widget.horizontalPadding) +
        widget.min;
  }

  List<double> updateInternalValues(double xPosition) {
    if (selectedInputIndex == null) return _internalValues;

    List<double> copiedValues = [..._internalValues];

    double convertedPosition = convertPixelPositionToValue(xPosition);

    copiedValues[selectedInputIndex] = convertedPosition.clamp(
      calculateInnerBound(),
      calculateOuterBound(),
    );

    return copiedValues;
  }

  double calculateInnerBound() {
    return selectedInputIndex == 0
        ? widget.min
        : _internalValues[selectedInputIndex - 1];
  }

  double calculateOuterBound() {
    return selectedInputIndex == _internalValues.length - 1
        ? widget.max
        : _internalValues[selectedInputIndex + 1];
  }

  int findNearestValueIndex(double convertedPosition) {
    if (_internalValues.length == 1) return 0;

    List<double> differences = _internalValues
        .map<double>((double value) => (value - convertedPosition).abs())
        .toList();
    double minDifference = differences.reduce(
      (previousValue, value) => value < previousValue ? value : previousValue,
    );

    int minDifferenceFirstIndex = differences.indexOf(minDifference);
    int minDifferenceLastIndex = differences.lastIndexOf(minDifference);

    bool hasCollision = minDifferenceLastIndex != minDifferenceFirstIndex;

    if (hasCollision &&
        (convertedPosition > _internalValues[minDifferenceFirstIndex])) {
      return minDifferenceLastIndex;
    }
    return minDifferenceFirstIndex;
  }
}
