part of widgets;

class AlignRect extends SingleChildRenderObjectWidget {
  const AlignRect({
    super.key,
    required this.rect,
    this.alignment = Alignment.center,
    super.child,
  });

  final Rect rect;
  final Alignment alignment;

  @override
  RenderAlignRect createRenderObject(BuildContext context) {
    return RenderAlignRect(
      rect: rect,
      alignment: alignment,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAlignRect renderObject) {
    renderObject
      ..rect = rect
      ..alignment = alignment;
  }
}

class CenterRect extends AlignRect {
  const CenterRect({super.key, required super.rect, super.child});
}