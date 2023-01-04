/*
Copyright (c) 2021 Rex Magana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
part of the_tooltip;

typedef TheTooltipKey = GlobalKey<TheTooltipState>;

/// A widget to display a tooltip over target widget. The tooltip can be
/// displayed on any axis of the widget and fallback to the opposite axis if
/// the tooltip does cannot fit its content.
class TheTooltip extends StatefulWidget {
  const TheTooltip({
    super.key,
    this.targetKey,
    this.alignment = Alignment.center,
    this.transitionDuration = const Duration(milliseconds: 150),
    this.transitionBuilder = defaultTransitionBuilder,
    this.reverseTransitionDuration = const Duration(milliseconds: 75),
    this.reverseTransitionBuilder = defaultReverseTransitionBuilder,
    this.direction = AxisDirection.down,
    this.margin = const EdgeInsets.all(8.0),
    this.position = 0.0,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.tailLength = 16.0,
    this.tailBaseWidth = 32.0,
    this.tailBuilder = defaultTailBuilder,
    this.backgroundColor,
    this.textDirection = TextDirection.ltr,
    this.shadow,
    required this.content,
    required this.child,
  });

  final GlobalKey? targetKey;

  final Alignment alignment;

  final AxisDirection direction;

  final Duration transitionDuration;

  final AnimatedTransitionBuilder transitionBuilder;

  final Duration reverseTransitionDuration;

  final AnimatedTransitionBuilder reverseTransitionBuilder;

  final EdgeInsetsGeometry margin;

  /// {@template tutorial_stage.TheTooltip.position}
  /// The position of [content] along the tail's axis.
  /// It ranges from -1.0 to 1.0, where 0.0 is the center.
  ///
  /// When [direction] is vertical, the greater [position] value is,
  /// the more [content] is positioned to the right.
  ///
  /// When [direction] is horizontal, the greater [position] value is,
  /// the more [content] is positioned to the bottom.
  /// {@endtemplate}
  final double position;

  final double elevation;

  final BorderRadiusGeometry borderRadius;

  final double tailLength;

  final double tailBaseWidth;

  final TailBuilder tailBuilder;

  final Color? backgroundColor;

  final TextDirection textDirection;

  final Shadow? shadow;

  /// The content of the tooltip. Content must be collapsed so it does not
  /// exceed it's constraints. The content's intrinsic `size` is used to first
  /// to get the quadrant of the tooltip. It is then layed out with those
  /// quadrant constraints limiting its size.
  ///
  /// Note that [direction] is not the final [AxisDirection]
  /// but may be placed opposite.
  final Widget content;

  /// The child widget the tooltip will hover over.
  final Widget child;

  static Widget defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget defaultReverseTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
      child: child,
    );
  }

  /// Draws a linear closed triangle path for the tail.
  static Path defaultTailBuilder(Offset tip, Offset point2, Offset point3) {
    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(point2.dx, point2.dy)
      ..lineTo(point3.dx, point3.dy)
      ..close();
  }

  /// Draws a bezier closed triangle path for the tail.
  static Path defaultBezierTailBuilder(
    Offset tip,
    Offset point2,
    Offset point3,
  ) {
    final offsetBetween = Offset(
      lerpDouble(point2.dx, point3.dx, 0.5)!,
      lerpDouble(point2.dy, point3.dy, 0.5)!,
    );

    return Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(
        offsetBetween.dx,
        offsetBetween.dy,
        point2.dx,
        point2.dy,
      )
      ..lineTo(point3.dx, point3.dy)
      ..quadraticBezierTo(
        offsetBetween.dx,
        offsetBetween.dy,
        tip.dx,
        tip.dy,
      )
      ..close();
  }

  @override
  TheTooltipState createState() => TheTooltipState();
}

class TheTooltipState extends State<TheTooltip>
    with SingleTickerProviderStateMixin<TheTooltip> {
  OverlayEntry? _overlayEntry;
  bool get _hasEntry => _overlayEntry != null;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
      reverseDuration: widget.reverseTransitionDuration,
    )..addStatusListener(_handleStatusChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlayEntry();
    super.dispose();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _removeOverlayEntry();
    }
  }

  Future<void> showTooltip() async {
    if (!_hasEntry) {
      _createOverlayEntry();
    }
    await _animationController.forward();
  }

  /// Calls [showTooltip] using [SchedulerBinding.addPostFrameCallback]
  Future<void> scheduleShowTooltip() {
    final Completer<void> tooltipCallbackCompleter = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showTooltip()
          .then(tooltipCallbackCompleter.complete)
          .onError(tooltipCallbackCompleter.completeError);
    });
    return tooltipCallbackCompleter.future;
  }

  Future<void> hideTooltip() async {
    await _animationController.reverse();
    _removeOverlayEntry();
  }

  @override
  void deactivate() {
    if (_hasEntry) {
      _removeOverlayEntry();
    }
    super.deactivate();
  }

  final GlobalKey _childKey = GlobalKey();
  GlobalKey get _targetKey => widget.targetKey ?? _childKey;

  @override
  Widget build(BuildContext context) {
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    return KeyedSubtree(
      key: _childKey,
      child: widget.child,
    );
  }

  @override
  void didUpdateWidget(covariant TheTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldUpdateTooltipOverlay(oldWidget)) {
      _scheduleUpdateOverlayEntry();
    }
  }

  bool _shouldUpdateTooltipOverlay(TheTooltip oldWidget) {
    return oldWidget.alignment != widget.alignment ||
        oldWidget.backgroundColor != widget.backgroundColor ||
        oldWidget.borderRadius != widget.borderRadius ||
        oldWidget.direction != widget.direction ||
        oldWidget.elevation != widget.elevation ||
        oldWidget.margin != widget.margin ||
        oldWidget.position != widget.position ||
        oldWidget.shadow != widget.shadow ||
        oldWidget.tailBaseWidth != widget.tailBaseWidth ||
        oldWidget.tailLength != widget.tailLength ||
        oldWidget.textDirection != widget.textDirection;
  }

  void _scheduleUpdateOverlayEntry() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final OverlayEntry? overlayEntry = _overlayEntry;
      if (!mounted || overlayEntry == null || !overlayEntry.mounted) {
        return;
      }
      overlayEntry.markNeedsBuild();
    });
  }

  void _createOverlayEntry() {
    final OverlayState? overlay = Overlay.of(context);
    if (overlay == null) {
      throw StateError('Cannot find the overlay above this widget');
    }

    final OverlayEntry entry = OverlayEntry(builder: _buildEntry);
    _overlayEntry = entry;
    overlay.insert(entry);
  }

  Widget _buildEntry(BuildContext context) {
    final RenderBoxPosition boxPosition =
        _targetKey.boxPosition ?? RenderBoxPosition.zero;

    final ThemeData theme = Theme.of(context);
    final Shadow defaultShadow = Shadow(
      offset: Offset.zero,
      blurRadius: 0.0,
      color: theme.shadowColor,
    );

    final Material content = Material(
      type: MaterialType.transparency,
      child: widget.content,
    );

    return DualTransitionBuilder(
      animation: _animationController,
      forwardBuilder: widget.transitionBuilder,
      reverseBuilder: widget.reverseTransitionBuilder,
      child: Directionality(
        textDirection: widget.textDirection,
        child: SimpleTooltip(
          rect: boxPosition.rect,
          alignment: widget.alignment,
          direction: widget.direction,
          margin: widget.margin,
          position: widget.position,
          borderRadius: widget.borderRadius,
          tailBaseWidth: widget.tailBaseWidth,
          tailLength: widget.tailLength,
          tailBuilder: widget.tailBuilder,
          backgroundColor: widget.backgroundColor ?? theme.cardColor,
          textDirection: widget.textDirection,
          shadow: widget.shadow ?? defaultShadow,
          elevation: widget.elevation,
          child: content,
        ),
      ),
    );
  }
}
