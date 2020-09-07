import 'package:flutter/material.dart';
import 'painters.dart';

class MultiSlider extends StatefulWidget {
  final double max;
  final double min;
  final double range;
  final double minimumDistancePercentage;
  final List<double> values;
  final double widthOffset;
  final void Function(List<double>) onChanged;

  MultiSlider(
      {this.max,
      this.min,
      this.minimumDistancePercentage = 5,
      this.values,
      this.onChanged,
      this.widthOffset = 20.0})
      : range = max - min;

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> {
  final double _maxHeight = 50.0;
  double get _maxWidth => MediaQuery.of(context).size.width;
  int selectedInputIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: _maxWidth,
        height: _maxHeight,
        child: CustomPaint(
          painter: MultiSliderPainter(
            selectedInputIndex: selectedInputIndex,
            values: widget.values.map(convertValueToPixelPosition).toList(),
            widthOffset: widget.widthOffset,
          ),
        ),
      ),
      onPanStart: selectInputIndex,
      onPanUpdate: updateInputValue,
      onPanEnd: deselectInputIndex,
    );
  }

  double convertValueToPixelPosition(double value) {
    return (value - widget.min) *
            (_maxWidth - 2 * widget.widthOffset) /
            (widget.range) +
        widget.widthOffset;
  }

  double convertPixelPositionToValue(double pixelPosition) {
    return (pixelPosition - widget.widthOffset) *
            (widget.range) /
            (_maxWidth - 2 * widget.widthOffset) +
        widget.min;
  }

  void selectInputIndex(DragStartDetails details) {
    double convertedPosition =
        convertPixelPositionToValue(details.localPosition.dx);
    double nearestValue = findNearestValue(convertedPosition);

    print(widget.widthOffset / widget.range);

    if ((convertedPosition - nearestValue).abs() <
        widget.widthOffset / widget.range) {
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
        : (widget.values[selectedInputIndex - 1] +
            widget.range * widget.minimumDistancePercentage / 100);
  }

  double calculateOuterBound() {
    return selectedInputIndex == widget.values.length - 1
        ? widget.max
        : (widget.values[selectedInputIndex + 1] -
            widget.range * widget.minimumDistancePercentage / 100);
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
