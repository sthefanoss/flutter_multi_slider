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
  }) : _range = max - min;

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> {
  double _maxWidth;
  int selectedInputIndex;

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
                values: widget.values.map(convertValueToPixelPosition).toList(),
                widthOffset: widget.horizontalPadding,
              ),
            ),
          ),
          onPanStart: isDisabled ? null : selectInputIndex,
          onPanUpdate: isDisabled ? null : updateInputValue,
          onPanEnd: isDisabled ? null : deselectInputIndex,
        );
      },
    );
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

  void selectInputIndex(DragStartDetails details) {
    double convertedPosition =
        convertPixelPositionToValue(details.localPosition.dx);
    double nearestValue = findNearestValue(convertedPosition);

    print(widget.horizontalPadding / widget._range);

    if ((convertedPosition - nearestValue).abs() <
        widget.horizontalPadding / widget._range) {
      setState(() {
        selectedInputIndex = widget.values.indexOf(nearestValue);
      });
    }
  }

  void updateInputValue(DragUpdateDetails details) {
    if (selectedInputIndex == null) return;

    List<double> copiedValues = [...widget.values];

    double convertedPosition =
        convertPixelPositionToValue(details.localPosition.dx);

    copiedValues[selectedInputIndex] = convertedPosition.clamp(
      calculateInnerBound(),
      calculateOuterBound(),
    );

    widget.onChanged(copiedValues);
  }

  double calculateInnerBound() {
    return selectedInputIndex == 0
        ? widget.min
        : widget.values[selectedInputIndex - 1];
  }

  double calculateOuterBound() {
    return selectedInputIndex == widget.values.length - 1
        ? widget.max
        : widget.values[selectedInputIndex + 1];
  }

  void deselectInputIndex(DragEndDetails details) {
    setState(() => selectedInputIndex = null);
  }

  double findNearestValue(double convertedPosition) {
    List<double> differences = widget.values
        .map<double>((double value) => (value - convertedPosition).abs())
        .toList();
    double minDifference = differences.reduce(
      (previousValue, value) => value < previousValue ? value : previousValue,
    );
    int minDifferenceIndex = differences.indexOf(minDifference);
    return widget.values[minDifferenceIndex];
  }
}
