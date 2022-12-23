part of spotlight;

class SpotlightTheme extends ThemeExtension<SpotlightTheme> {
  const SpotlightTheme({
    this.borderRadius = defaultBorderRadius,
    this.backgroundColor = defaultBackgroundColor,
  });

  final BorderRadius borderRadius;
  final Color backgroundColor;

  static const BorderRadius defaultBorderRadius = BorderRadius.zero;
  static const Color defaultBackgroundColor = Colors.black45;

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
          defaultBorderRadius,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ??
          defaultBackgroundColor,
    );
  }
}
