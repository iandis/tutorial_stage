part of widgets;

/// Same as `IntrinsicWidth` except that when this widget is instructed
/// to `computeDryLayout()`, it doesn't invoke that on its child, instead
/// it computes the child's intrinsic width.
///
/// This widget is useful in situations where the `child` does not
/// support dry layout, e.g., `TextField` as of 01/02/2021.
///
/// See https://github.com/flutter/flutter/issues/71687
/// and https://gist.github.com/matthew-carroll/65411529a5fafa1b527a25b7130187c6
class DryIntrinsicWidth extends SingleChildRenderObjectWidget {
  const DryIntrinsicWidth({super.key, super.child});

  @override
  RenderDryIntrinsicWidth createRenderObject(BuildContext context) =>
      RenderDryIntrinsicWidth();
}

class RenderDryIntrinsicWidth extends RenderIntrinsicWidth {
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final double width =
          child!.computeMinIntrinsicWidth(constraints.maxHeight);
      final double height = child!.computeMinIntrinsicHeight(width);
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }
}
