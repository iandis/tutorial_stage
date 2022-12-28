part of extensions;

class RenderBoxPosition {
  const RenderBoxPosition._({
    required this.offset,
    required this.size,
    required this.rect,
  });

  factory RenderBoxPosition._fromRenderBox(RenderBox renderBox) {
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    return RenderBoxPosition._(
      offset: offset,
      size: size,
      rect: offset & size,
    );
  }

  factory RenderBoxPosition.fromSize(Size size) {
    const Offset offset = Offset.zero;
    final Rect rect = offset & size;
    return RenderBoxPosition._(
      offset: offset,
      size: size,
      rect: rect,
    );
  }

  final Offset offset;
  final Size size;
  final Rect rect;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenderBoxPosition &&
          other.runtimeType == runtimeType &&
          other.offset == offset &&
          other.size == size &&
          other.rect == rect;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        offset.hashCode,
        size.hashCode,
        rect.hashCode,
      );
}
