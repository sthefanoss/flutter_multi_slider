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
    this.displayDivisions = true,
    this.valueRangePainterCallback,
    this.addOrRemove = false,
    this.defaultRange,
    this.showTooltip = false,
    this.tooltipBuilder,
    this.tooltipTheme = const CustomTooltipData(),
    Key? key,
  })  : assert(divisions == null || divisions > 0),
        assert(max - min >= 0),
        assert(defaultRange == null || addOrRemove),
        assert(defaultRange != null || !addOrRemove),
        assert(tooltipBuilder != null || !showTooltip),
        range = max - min,
        super(key: key) {
      // Creating a copy of values and sorting it in ascending order
      final valuesCopy = [...values]..sort();

      // Checking if the copy matches the values
      for (int index = 0; index < valuesCopy.length; index++) {
        assert(
          valuesCopy[index] == values[index],
          'MultiSlider: values must be in ascending order!',
        );

      if(values.isNotEmpty){
        assert(
          values.first >= min && values.last <= max,
          'MultiSlider: At least one value is outside of min/max boundaries!',
        );
      }
      
    }
  }

  /// [MultiSlider] maximum value.
  final double max;

  /// [MultiSlider] minimum value.
  final double min;

  /// Difference between [max] and [min]. Must be non-negative!
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

  /// Whether to display the lines indicating [divisions].
  final bool displayDivisions;

  /// Used to decide how a line between values or the boundaries should be painted.
  /// Returns [bool] and pass an [ValueRange] object as parameter.
  final ValueRangePainterCallback? valueRangePainterCallback;

  /// Adds or removes a new pair of boundaries on double tap. When this is true, the 
  /// [defaultRange] mustn't be null.
  final bool addOrRemove; 

  /// Default difference between values of two new boundaries added on double tap.
  /// [addOrRemove] must be true when this is not null. 
  final double? defaultRange;

  /// If true, a floating label will be displayed above the slider with a String
  /// returned by [tooltipBuilder]
  final bool showTooltip;

  /// A function that takes currently selected value as a parameter and returns
  /// a String that will be displayed on tooltip if [showTooltip] is true.
  final String Function(double value)? tooltipBuilder;

  /// The data of the tooltip
  final CustomTooltipData tooltipTheme;

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> with TickerProviderStateMixin {
  double? _maxWidth;
  int? _selectedInputIndex;
  // This is for the tooltip builder, because _selectedInputIndex was null 
  // when the tooltip animation was stoping and it threw an error
  late int _selectedIndexNotNull;
  double? _doubleTapPosition;

  // A key what allows displaying the tooltip above the slider
  late GlobalKey _overlayKey;
  // Position of the tooltip
  late Offset _offset;
  late Size _size;
  OverlayEntry? _overlayEntry;
  // Animation controller for the tooltip
  late AnimationController _controller;


  @override
  void initState() {
    _overlayKey = GlobalKey();
    _controller = AnimationController(
      vsync: this, 
      duration: widget.tooltipTheme.animationDuration,
    );
    super.initState();
  }


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
            key: _overlayKey,
            constraints: constraints,
            width: double.infinity,
            height: widget.height,
            child: CustomPaint(
                painter: _MultiSliderPainter(
                  valueRangePainterCallback: widget.valueRangePainterCallback ??
                      _defaultDivisionPainterCallback,
                  divisions: widget.divisions,
                  displayDivisions: widget.displayDivisions,
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
                ),
            ),
          ),
          onPanStart: isDisabled ? null : _handleOnChangeStart,
          onPanUpdate: isDisabled ? null : _handleOnChanged,
          onPanEnd: isDisabled ? null : _handleOnChangeEnd,
          onDoubleTapDown: isDisabled || !widget.addOrRemove 
            ? null 
            : _handleOnDoubleTapDown,
          onDoubleTapCancel: isDisabled || !widget.addOrRemove 
            ? null 
            : _handleOnDoubleTapCancel,
          onDoubleTap: isDisabled || !widget.addOrRemove 
            ? null 
            : _handleOnDoubleTap,
        );
      },
    );
  }


  // Get size and offset for the tooltip 
  void _getOverlayDetails(double offset) {
    final renderBox = _overlayKey.currentContext!.findRenderObject() as RenderBox;
    _size = renderBox.size;
    _offset = renderBox.localToGlobal(Offset(offset - _size.width/2, 0));
  }

  void _stopOverlayAnimation() async {
    await _controller.reverse();
    _overlayEntry!.remove();
  }

  String _getTooltipLabel() {
    if(_selectedInputIndex != null) {
      _selectedIndexNotNull = _selectedInputIndex!;
    }
    return widget.tooltipBuilder!(widget.values[_selectedIndexNotNull]);
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height - _offset.dy - _size.height/2 + 10,
        left: _offset.dx - 25,
        width: _size.width + 50,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 0.9).animate(
            CurvedAnimation(
              parent: _controller, 
              curve: widget.tooltipTheme.animationCurve
            )
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(widget.tooltipTheme.radius),
                elevation: widget.tooltipTheme.elevation,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.tooltipTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.tooltipTheme.radius),
                  ),
                  child: Text(
                    _getTooltipLabel(),
                    style: widget.tooltipTheme.textStyle,
                  ),
                  padding: widget.tooltipTheme.textPadding,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(10, 5),
                  painter: DrawTriangleShape(widget.tooltipTheme.backgroundColor),
                )
              ),
            ],
          ),
        ),
      ),
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

    if(widget.showTooltip) {
      _getOverlayDetails(
        _convertValueToPixelPosition(updatedValues[_selectedInputIndex!])
      );
      _overlayEntry = _createOverlay();
      Overlay.of(context)!.insert(_overlayEntry!);
      _controller.forward();
    }
  }

  void _handleOnChanged(DragUpdateDetails details) {
    var updatedValues = updateInternalValues(details.localPosition.dx);
    widget.onChanged!(updatedValues);

    if(widget.showTooltip) {
      _getOverlayDetails(
        _convertValueToPixelPosition(updatedValues[_selectedInputIndex!])
      );
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _handleOnChangeEnd(DragEndDetails details) {
    setState(() => _selectedInputIndex = null);

    if (widget.onChangeEnd != null) widget.onChangeEnd!(widget.values);

    if(widget.showTooltip) {
      _stopOverlayAnimation();
    }
  }

  void _handleOnDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition.dx;
  }

  void _handleOnDoubleTapCancel() {
    _doubleTapPosition = null;
  }

  void _handleOnDoubleTap() {
    if(_doubleTapPosition != null) {
      // Check whether the double tap was on an empty fragment of the slider
    
      final values = <double>[
        widget.min,
        ...widget.values
            .map<double>(widget.divisions == null
                ? (v) => v
                : (v) => _getDiscreteValue(v, widget.min, widget.max, widget.divisions!))
            .toList(),
        widget.max
      ];
      var valueRanges = List<ValueRange>.generate(
        values.length - 1,
        (index) => ValueRange(
          values[index],
          values[index + 1],
          index,
          index == 0,
          index == values.length - 2,
        ),
      );

      var valuePosition = _convertPixelPositionToValue(_doubleTapPosition!);

      bool isBetween = false;

      var callback = widget.valueRangePainterCallback ?? _defaultDivisionPainterCallback;
      
      for (ValueRange valueRange in valueRanges) {
        if(
          valuePosition >= valueRange.start && 
          valuePosition <= valueRange.end &&
          callback(valueRange)
        ) {
          isBetween = true;
          break;
        }
      }

      // If the double tap was on an empty fragment add new values
      if(!isBetween) {
        var copiedValues = [...widget.values];

        double upperLimit = copiedValues.firstWhere(
          (e) => e > valuePosition,
          orElse: () => widget.max,
        );

        double lowerLimit = copiedValues.lastWhere(
          (e) => e < valuePosition,
          orElse: () => widget.min,
        );

        double lower;
        double upper;

        if(lowerLimit < valuePosition - widget.defaultRange!/2) {
          lower = (widget.divisions != null) 
            ? _getDiscreteValue(
              valuePosition - widget.defaultRange!/2, 
              widget.min, 
              widget.max, 
              widget.divisions!
            ) 
            : valuePosition - widget.defaultRange!/2;
        } else {
          lower = lowerLimit;
        }

        if(upperLimit > valuePosition + widget.defaultRange!/2) {
          upper = (widget.divisions != null) 
            ? _getDiscreteValue(
              valuePosition + widget.defaultRange!/2,
              widget.min, 
              widget.max, 
              widget.divisions!
            ) 
            : valuePosition + widget.defaultRange!/2;
        } else {
          upper = upperLimit;
        }

        int lowerInsertIndex = copiedValues.lastIndexWhere(
          (e) => e <= lower
        ) + 1;
        copiedValues.insert(lowerInsertIndex, lower);

        int upperInsertIndex = copiedValues.indexWhere(
          (e) => e >= upper
        );
        if (upperInsertIndex == -1) upperInsertIndex = copiedValues.length;
        copiedValues.insert(upperInsertIndex, upper);

        widget.onChanged!(copiedValues);
        
      // Else, remove existing pair of boundaries
      } else {
        var copiedValues = [...widget.values];

        int upperIndex = copiedValues.indexWhere(
          (e) => e >= valuePosition,
        );

        copiedValues.removeAt(upperIndex);

        int lowerIndex = copiedValues.lastIndexWhere(
          (e) => e <= valuePosition,
        );

        copiedValues.removeAt(lowerIndex);

        widget.onChanged!(copiedValues);
      }

    } 
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


  bool _defaultDivisionPainterCallback(ValueRange range) => range.index % 2 == 1;

}



class _MultiSliderPainter extends CustomPainter {
  final List<double> values;
  final int? selectedInputIndex;
  final double horizontalPadding;
  final Paint activeTrackColorPaint;
  final Paint bigCircleColorPaint;
  final Paint inactiveTrackColorPaint;
  final int? divisions;
  final bool displayDivisions;
  final ValueRangePainterCallback valueRangePainterCallback;

  _MultiSliderPainter({
    required bool isDisabled,
    required Color activeTrackColor,
    required Color inactiveTrackColor,
    required Color disabledActiveTrackColor,
    required Color disabledInactiveTrackColor,
    required this.values,
    required this.selectedInputIndex,
    required this.horizontalPadding,
    required this.divisions,
    required this.displayDivisions,
    required this.valueRangePainterCallback,
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

    final valueRanges = _makeRanges(values, canvasStart, canvasEnd);

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(valueRanges.first.start, halfHeight),
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
        center: Offset(valueRanges.last.end, halfHeight),
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
      canvas.drawLine(
        Offset(valueRange.start, halfHeight),
        Offset(valueRange.end, halfHeight),
        valueRangePainterCallback(valueRange)
            ? activeTrackColorPaint
            : inactiveTrackColorPaint,
      );
    }

    if (divisions != null && displayDivisions) {
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

    for (int i = 0; i < values.length; i++) {
      double x = divisions == null
          ? values[i]
          : _getDiscreteValue(values[i], canvasStart, canvasEnd, divisions!);

      canvas.drawCircle(
        Offset(x, halfHeight),
        10,
        _paintFromColor(Colors.white),
      );

      canvas.drawCircle(
        Offset(x, halfHeight),
        10,
        activeTrackColorPaint,
      );

      if (selectedInputIndex == i)
        canvas.drawCircle(
          Offset(x, halfHeight),
          22.5,
          bigCircleColorPaint,
        );
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


double _getDiscreteValue(
  double value,
  double start,
  double end,
  int divisions,
) {
  final k = (end - start) / divisions;
  return start + ((value - start) / k).roundToDouble() * k;
}


/// A class that defines configuration for [MultiSlider]'s tooltip. 
class CustomTooltipData {
  final Color backgroundColor;
  final TextStyle textStyle;
  final EdgeInsets textPadding;
  final Duration animationDuration;
  final Curve animationCurve;
  final double radius;
  final double elevation;

  const CustomTooltipData({
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(color: Colors.black),
    this.textPadding = const EdgeInsets.all(5),
    this.radius = 5,
    this.elevation = 5,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.bounceOut,
  });
}


class DrawTriangleShape extends CustomPainter {
  late Paint painter;
 
  DrawTriangleShape(Color color) {
    painter = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
 
  }
  
  @override
  void paint(Canvas canvas, Size size) {
 
    var path = Path();
 
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width/2, size.height);
    path.close();
 
    canvas.drawPath(path, painter);
  }
 
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}