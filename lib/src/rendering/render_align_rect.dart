part of rendering;

class RenderAlignRect extends RenderRectShiftedBox {
  RenderAlignRect({
    required super.rect,
    super.alignment,
    super.child,
  });

  @pragma('vm:prefer-inline')
  static bool _shouldShrinkWrapWidth(BoxConstraints constraints) {
    return constraints.maxWidth == double.infinity;
  }

  @pragma('vm:prefer-inline')
  static bool _shouldShrinkWrapHeight(BoxConstraints constraints) {
    return constraints.maxHeight == double.infinity;
  }

  // Copied from [RenderPositionedBox.computeDryLayout]
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final bool shrinkWrapWidth = _shouldShrinkWrapWidth(constraints);
    final bool shrinkWrapHeight = _shouldShrinkWrapHeight(constraints);
    if (child != null) {
      final Size childSize = child!.getDryLayout(constraints.loosen());
      return constraints.constrain(Size(
        shrinkWrapWidth ? childSize.width : double.infinity,
        shrinkWrapHeight ? childSize.height : double.infinity,
      ));
    }
    return constraints.constrain(Size(
      shrinkWrapWidth ? 0.0 : double.infinity,
      shrinkWrapHeight ? 0.0 : double.infinity,
    ));
  }

  BoxConstraints computeConstraints(BoxConstraints constraints) {
    return constraints.loosen();
  }

  // Copied from [RenderPositionedBox.performLayout]
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final bool shrinkWrapWidth = _shouldShrinkWrapWidth(constraints);
    final bool shrinkWrapHeight = _shouldShrinkWrapHeight(constraints);

    if (child != null) {
      child!.layout(computeConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(Size(
        shrinkWrapWidth ? child!.size.width : double.infinity,
        shrinkWrapHeight ? child!.size.height : double.infinity,
      ));
      alignChild();
    } else {
      size = constraints.constrain(Size(
        shrinkWrapWidth ? 0.0 : double.infinity,
        shrinkWrapHeight ? 0.0 : double.infinity,
      ));
    }
  }
}
