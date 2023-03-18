part of flutter_multi_slider;

class MultiSlider extends StatefulWidget {
  const MultiSlider({
    required this.values,
    required this.onChanged,
    this.max = 1,
    this.min = 0,
    this.onChangeStart,
    this.onChangeEnd,
    this.color,
    this.rangeColors,
    this.thumbColor,
    this.thumbRadius = 10,
    this.horizontalPadding = 26.0,
    this.height = 45,
    this.activeTrackSize = 6,
    this.inactiveTrackSize = 4,
    this.indicator,
    this.selectedIndicator = defaultIndicator,
    this.divisions,
    this.valueRangePainterCallback,
    this.textDirection = TextDirection.ltr,
    this.textHeightOffset = 30,
    Key? key,
  })  : range = max - min,
        assert(values.length != 0),
        assert(divisions == null || divisions > 0),
        assert(max - min >= 0),
        super(key: key);

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

  /// Bar range active colors.
  final List<Color>? rangeColors;

  /// Thumb radius.
  final double thumbRadius;

  /// Thumb color.
  final Color? thumbColor;

  /// Value indicator.
  final IndicatorBuilder? indicator;

  /// Value indicator.
  final IndicatorBuilder? selectedIndicator;

  /// Active track size.
  final double activeTrackSize;

  /// Inactive track size.
  final double inactiveTrackSize;

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

  /// [TextDirection] used on [indicator] and [selectedIndicator] drawing.
  final TextDirection textDirection;

  final double textHeightOffset;

  static IndicatorOptions defaultIndicator(double value, int index) {
    return IndicatorOptions();
  }

  @override
  _MultiSliderState createState() => _MultiSliderState();
}

class _MultiSliderState extends State<MultiSlider> {
  late double _maxWidth;
  int? _selectedInputIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sliderTheme = SliderTheme.of(context);

    final bool isDisabled = widget.onChanged == null || widget.range == 0;
    final indicatorTextTheme = theme.textTheme.labelMedium;
    final selectedIndicatorTextTheme = theme.textTheme.bodyText1;

    IndicatorBuilder? indicator, selectedIndicator;
    if (widget.indicator != null) {
      indicator = selectedIndicator = (value, index) {
        final f = widget.indicator!(value, index);
        return IndicatorOptions(
          draw: f.draw,
          formatter: f.formatter,
          style: indicatorTextTheme?.copyFromOther(f.style),
        );
      };
    }
    if (widget.selectedIndicator != null) {
      selectedIndicator = (value, index) {
        final f = widget.selectedIndicator!(value, index);
        return IndicatorOptions(
          draw: f.draw,
          formatter: f.formatter,
          style: selectedIndicatorTextTheme?.copyFromOther(f.style),
        );
      };
    }

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
                rangeColors: widget.rangeColors,
                thumbColor: widget.thumbColor ??
                    widget.color ??
                    sliderTheme.activeTrackColor ??
                    theme.colorScheme.primary,
                thumbRadius: widget.thumbRadius,
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
                values: widget.values,
                indicator: indicator,
                selectedIndicator: selectedIndicator,
                positions:
                    widget.values.map(_convertValueToPixelPosition).toList(),
                horizontalPadding: widget.horizontalPadding,
                activeTrackSize: widget.activeTrackSize,
                inactiveTrackSize: widget.inactiveTrackSize,
                textDirection: widget.textDirection,
                textHeightOffset: widget.textHeightOffset,
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
            (_maxWidth - 2 * widget.horizontalPadding) /
            (widget.range) +
        widget.horizontalPadding;
  }

  double _convertPixelPositionToValue(double pixelPosition) {
    final value = (pixelPosition - widget.horizontalPadding) *
            (widget.range) /
            (_maxWidth - 2 * widget.horizontalPadding) +
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
