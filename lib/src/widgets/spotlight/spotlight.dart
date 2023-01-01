part of spotlight;

class Spotlight extends StatelessWidget {
  /// Creates a spotlight resembling target [rect].
  ///
  /// [rect] can be obtained via [GlobalKeyExt.boxPosition] or
  /// [BuildContextExt.boxPosition].
  ///
  /// [rect] with [EdgeInsets] can created via [RectExt.withPadding].
  ///
  /// circular [borderRadius] can be created via [RectExt.borderRadius].
  ///
  /// Example:
  /// ```dart
  /// class MyParentWidgetState extends State<MyParentWidget> {
  ///   final GlobalKey _targetKey = GlobalKey();
  ///
  ///   Widget get _spotlight {
  ///     final Rect rect = _targetKey.boxPosition!.rect;
  ///     final Rect targetRect = rect.withPadding(const EdgeInsets.all(8));
  ///     final BorderRadius borderRadius = targetRect.borderRadius;
  ///     return Spotlight(
  ///       rect: targetRect,
  ///       borderRadius: borderRadius,
  ///     );
  ///   }
  /// }
  /// ```
  /// **WARNING:**
  /// Any call to [GlobalKeyExt.boxPosition] or [BuildContextExt.boxPosition]
  /// should be done after the target has been built.
  /// Doing otherwise will throw an error.
  const Spotlight({
    super.key,
    required this.rect,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  });

  final Rect rect;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SpotlightTheme? theme = Theme.of(context).extension<SpotlightTheme>();
    final BorderRadius borderRadius = this.borderRadius ??
        theme?.borderRadius ??
        SpotlightTheme._defaultBorderRadius;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipPath(
        clipper: RRectClipper(
          rect: rect,
          borderRadius: borderRadius,
        ),
        child: SpotlightSkrim(backgroundColor: backgroundColor),
      ),
    );
  }
}
