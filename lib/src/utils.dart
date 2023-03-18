part of flutter_multi_slider;

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
