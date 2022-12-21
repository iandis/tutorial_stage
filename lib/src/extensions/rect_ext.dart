part of extensions;

extension RectExt on Rect {
  Rect withPadding(EdgeInsets padding) {
    return Rect.fromLTRB(
      left - padding.left,
      top - padding.top,
      right + padding.right,
      bottom + padding.bottom,
    );
  }

  /// Returns a [BorderRadius] half the size of this maximum length
  BorderRadius get borderRadius {
    final double maxLength = math.max(width, height);
    return BorderRadius.circular(0.5 * maxLength);
  }
}
