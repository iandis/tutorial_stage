part of widgets;

/// Same as `IntrinsicHeight` except that when this widget is instructed
/// to `computeDryLayout()`, it doesn't invoke that on its child, instead
/// it computes the child's intrinsic height.
///
/// This widget is useful in situations where the `child` does not
/// support dry layout, e.g., `TextField` as of 01/02/2021.
///
/// See https://github.com/flutter/flutter/issues/71687
/// and https://gist.github.com/matthew-carroll/65411529a5fafa1b527a25b7130187c6
class DryIntrinsicHeight extends SingleChildRenderObjectWidget {
  const DryIntrinsicHeight({super.key, super.child});

  @override
  RenderDryIntrinsicHeight createRenderObject(BuildContext context) =>
      RenderDryIntrinsicHeight();
}

class RenderDryIntrinsicHeight extends RenderIntrinsicHeight {
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (child != null) {
      final double height =
          child!.computeMinIntrinsicHeight(constraints.maxWidth);
      final double width = child!.computeMinIntrinsicWidth(height);
      return Size(width, height);
    } else {
      return Size.zero;
    }
  }
}
