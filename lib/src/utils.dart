part of '../flutter_multi_slider.dart';

extension TextStyleExtension on TextStyle {
  TextStyle copyFromOther(TextStyle? other) => other == null
      ? this
      : copyWith(
          inherit: other.inherit,
          color: other.color,
          backgroundColor: other.backgroundColor,
          fontSize: other.fontSize,
          fontWeight: other.fontWeight,
          fontStyle: other.fontStyle,
          letterSpacing: other.letterSpacing,
          wordSpacing: other.wordSpacing,
          textBaseline: other.textBaseline,
          height: other.height,
          foreground: other.foreground,
          background: other.background,
          shadows: other.shadows,
          fontFeatures: other.fontFeatures,
          decoration: other.decoration,
          decorationColor: other.decorationColor,
          decorationStyle: other.decorationStyle,
          decorationThickness: other.decorationThickness,
          debugLabel: other.debugLabel,
          fontFamily: other.fontFamily,
          fontFamilyFallback: other.fontFamilyFallback,
          overflow: other.overflow,
        );
}

/// TODO any way to optimize it?!?
int findNearestValueIndex(double convertedPosition, List<double> list) {
  if (list.length == 1) return 0;

  List<double> differences = list
      .map<double>((double value) => (value - convertedPosition).abs())
      .toList();
  double minDifference = differences.reduce(
    (previousValue, value) => value < previousValue ? value : previousValue,
  );

  int minDifferenceFirstIndex = differences.indexOf(minDifference);
  int minDifferenceLastIndex = differences.lastIndexOf(minDifference);

  bool hasCollision = minDifferenceLastIndex != minDifferenceFirstIndex;

  if (hasCollision && (convertedPosition > list[minDifferenceFirstIndex])) {
    return minDifferenceLastIndex;
  }
  return minDifferenceFirstIndex;
}
