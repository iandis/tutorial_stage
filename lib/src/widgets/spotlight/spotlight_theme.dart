part of spotlight;

class SpotlightTheme extends ThemeExtension<SpotlightTheme> {
  const SpotlightTheme({
    this.borderRadius = _defaultBorderRadius,
    this.backgroundColor = _defaultBackgroundColor,
  });

  final BorderRadius borderRadius;
  final Color backgroundColor;

  static const BorderRadius _defaultBorderRadius = BorderRadius.zero;
  static const Color _defaultBackgroundColor = Colors.black45;

  @override
  SpotlightTheme copyWith({
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return SpotlightTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  SpotlightTheme lerp(covariant SpotlightTheme? other, double t) {
    if (other == null) return this;
    return SpotlightTheme(
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t) ??
          _defaultBorderRadius,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ??
          _defaultBackgroundColor,
    );
  }
}
