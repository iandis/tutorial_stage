part of rendering;

abstract class RenderRectShiftedBox extends RenderShiftedBox {
  RenderRectShiftedBox({
    required Rect rect,
    Alignment alignment = Alignment.center,
    RenderBox? child,
  })  : _alignment = alignment,
        _rect = rect,
        super(child);

  Alignment _alignment;
  Alignment get alignment => _alignment;
  set alignment(Alignment value) {
    if (value == _alignment) return;
    _alignment = value;
    markNeedsLayout();
  }

  Rect _rect;
  Rect get rect => _rect;
  set rect(Rect value) {
    if (value == _rect) return;
    _rect = value;
    markNeedsLayout();
  }

  @protected
  void alignChild() {
    assert(child != null);
    assert(!child!.debugNeedsLayout);
    assert(child!.hasSize);
    assert(hasSize);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    // Child's center offset from its top left corner
    final double childX = rect.center.dx - 0.5 * child!.size.width;
    final double childY = rect.center.dy - 0.5 * child!.size.height;

    final double xAlignmentMultiplier = -0.5 * alignment.x;
    final double yAlignmentMultiplier = -0.5 * alignment.y;

    final Offset alignedOffset = Offset(
      childX - xAlignmentMultiplier * rect.size.width,
      childY - yAlignmentMultiplier * rect.size.height,
    );
    childParentData.offset = alignedOffset;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Alignment>('alignment', alignment))
      ..add(DiagnosticsProperty<Rect>('rect', rect));
  }
}
