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
    this.transitionDuration = const Duration(milliseconds: 150),
    this.transitionBuilder = defaultTransitionBuilder,
    this.reverseTransitionDuration = const Duration(milliseconds: 75),
    this.reverseTransitionBuilder = defaultReverseTransitionBuilder,
    this.preferredDirection = AxisDirection.down,
    this.margin = const EdgeInsets.all(8.0),
    this.offset = 0.0,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.tailLength = 16.0,
    this.tailBaseWidth = 32.0,
    this.tailBuilder = defaultTailBuilder,
    this.backgroundColor,
    this.textDirection = TextDirection.ltr,
    this.shadow,
    this.showWhenUnlinked = false,
    required this.content,
    required this.child,
  });

  final AxisDirection preferredDirection;

  final Duration transitionDuration;

  final AnimatedTransitionBuilder transitionBuilder;

  final Duration reverseTransitionDuration;

  final AnimatedTransitionBuilder reverseTransitionBuilder;

  final EdgeInsetsGeometry margin;

  final double offset;

  final double elevation;

  final BorderRadiusGeometry borderRadius;

  final double tailLength;

  final double tailBaseWidth;

  final TailBuilder tailBuilder;

  final Color? backgroundColor;

  final TextDirection textDirection;

  final Shadow? shadow;

  final bool showWhenUnlinked;

  /// The content of the tooltip. Content must be collapsed so it does not
  /// exceed it's constraints. The content's intrinsic `size` is used to first
  /// to get the quadrant of the tooltip. It is then layed out with those
  /// quadrant constraints limiting its size.
  ///
  /// Note that [preferredDirection] is not the final [AxisDirection]
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

class TheTooltipState extends State<TheTooltip> {
  OverlayEntry? _overlayEntry;
  bool get _hasEntry => _overlayEntry != null;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: TutorialStage.tickerOf(context),
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

  final LayerLink _layerLink = LayerLink();
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyedSubtree(
        key: _childKey,
        child: widget.child,
      ),
    );
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
    final _TargetInformation targetInfo =
        _TargetInformation.from(_childKey.currentContext);
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

    return CompositedTransformFollower(
      showWhenUnlinked: widget.showWhenUnlinked,
      offset: targetInfo.offsetToTarget,
      link: _layerLink,
      child: DualTransitionBuilder(
        animation: _animationController,
        forwardBuilder: widget.transitionBuilder,
        reverseBuilder: widget.reverseTransitionBuilder,
        child: Directionality(
          textDirection: widget.textDirection,
          child: PositionedTooltip(
            margin: widget.margin,
            targetSize: targetInfo.size,
            target: targetInfo.target,
            offset: widget.offset,
            preferredDirection: widget.preferredDirection,
            offsetToTarget: targetInfo.offsetToTarget,
            borderRadius: widget.borderRadius,
            tailBaseWidth: widget.tailBaseWidth,
            tailLength: widget.tailLength,
            tailBuilder: widget.tailBuilder,
            backgroundColor: widget.backgroundColor ?? theme.cardColor,
            textDirection: widget.textDirection,
            shadow: widget.shadow ?? defaultShadow,
            elevation: widget.elevation,
            scrollPosition: null,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _TargetInformation {
  const _TargetInformation({
    required this.size,
    required this.target,
    required this.offsetToTarget,
  });

  factory _TargetInformation.from(BuildContext? context) {
    final RenderObject? box = context?.findRenderObject();
    if (box is! RenderBox) return _TargetInformation.zero;
    final Size size = box.getDryLayout(
      const BoxConstraints.tightForFinite(),
    );
    final Offset target = box.localToGlobal(
      box.size.center(Offset.zero),
    );
    // TODO: Instead of this, change the alignment on
    // [CompositedTransformFollower]. That way we can allow a user configurable
    // alignment on where the tooltip ends up.
    final Offset offsetToTarget = Offset(
      -target.dx + box.size.width / 2,
      -target.dy + box.size.height / 2,
    );
    return _TargetInformation(
      size: size,
      target: target,
      offsetToTarget: offsetToTarget,
    );
  }

  final Size size;

  final Offset target;

  final Offset offsetToTarget;

  static const _TargetInformation zero = _TargetInformation(
    size: Size.zero,
    target: Offset.zero,
    offsetToTarget: Offset.zero,
  );
}
