part of extensions;

extension BuildContextExt on BuildContext {
  RenderBoxPosition? get boxPosition {
    assert(!debugDoingBuild);
    assert(!(this as Element).debugIsDefunct);

    final RenderObject? renderBox = findRenderObject();
    if (renderBox is! RenderBox) return null;
    return RenderBoxPosition._fromRenderBox(renderBox);
  }
}

extension GlobalKeyExt on GlobalKey {
  RenderBoxPosition? get boxPosition => currentContext?.boxPosition;
}
