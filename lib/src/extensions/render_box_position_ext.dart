part of extensions;

extension BuildContextExt on BuildContext {
  RenderBoxPosition? get boxPosition {
    assert(!debugDoingBuild);
    assert(!(this as Element).debugIsDefunct);

    final RenderObject? renderBox = findRenderObject();
    if (renderBox is! RenderBox) return null;
    return RenderBoxPosition._fromRenderBox(renderBox);
  }

  RenderBoxPosition get mediaQueryBoxPosition {
    return RenderBoxPosition.fromSize(MediaQuery.of(this).size);
  }
}

extension GlobalKeyExt on GlobalKey {
  RenderBoxPosition? get boxPosition => currentContext?.boxPosition;
}
