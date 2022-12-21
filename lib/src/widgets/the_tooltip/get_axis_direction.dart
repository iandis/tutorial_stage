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

AxisDirection _getAxisDirection({
  required Size size,
  required Size targetSize,
  required Size childSize,
  required Offset target,
  required AxisDirection preferredDirection,

  /// This should include both the offset and the tailLength
  required double offsetAndTail,
  required EdgeInsets margin,
  required ScrollPosition? scrollPosition,
}) {
  switch (preferredDirection) {
    case AxisDirection.left:
    case AxisDirection.right:
      final preferLeft = preferredDirection == AxisDirection.left;
      final childAndOffsetWidth = offsetAndTail + childSize.width;
      final targetWidthRadius = targetSize.width / 2;
      final rightTargetEdge = target.dx + targetWidthRadius;
      final leftTargetEdge = target.dx - targetWidthRadius;
      final spaceAvailableLeft = leftTargetEdge - margin.left;
      final spaceAvailableRight = size.width - rightTargetEdge - margin.right;

      // LTE = leftTargetEdge
      // |margin.L          child+offset            LTE                        |
      var fitsLeft = spaceAvailableLeft >= childAndOffsetWidth;

      //                                   size.width
      // |              RTE                      child+offset          margin.R|
      var fitsRight = spaceAvailableRight >= childAndOffsetWidth;

      // It it doesn't fit in either direction, let's check again adding to the
      // fact that we have the scroll space not included in the viewport
      if (!fitsLeft &&
          !fitsRight &&
          scrollPosition != null &&
          scrollPosition.axis == Axis.horizontal) {
        fitsLeft = spaceAvailableLeft + scrollPosition.extentBefore >=
            childAndOffsetWidth;
        fitsRight = spaceAvailableRight + scrollPosition.extentAfter >=
            childAndOffsetWidth;
      }

      final tooltipLeft =
          preferLeft ? fitsLeft || !fitsRight : !(fitsRight || !fitsLeft);

      return tooltipLeft ? AxisDirection.left : AxisDirection.right;

    case AxisDirection.up:
    case AxisDirection.down:
      final preferAbove = preferredDirection == AxisDirection.up;
      final childAndOffsetHeight = offsetAndTail + childSize.height;
      final targetHeightRadius = targetSize.height / 2;
      final bottomTargetEdge = target.dy + targetHeightRadius;
      final topTargetEdge = target.dy - targetHeightRadius;
      final spaceAvailableAbove = topTargetEdge - margin.top;
      final spaceAvailableBelow =
          size.height - bottomTargetEdge - margin.bottom;

      var fitsAbove = spaceAvailableAbove >= childAndOffsetHeight;
      var fitsBelow = spaceAvailableBelow >= childAndOffsetHeight;

      if (!fitsAbove &&
          !fitsBelow &&
          scrollPosition != null &&
          scrollPosition.axis == Axis.vertical) {
        fitsBelow = spaceAvailableBelow + scrollPosition.extentAfter >=
            childAndOffsetHeight;
        fitsAbove = spaceAvailableAbove + scrollPosition.extentBefore >=
            childAndOffsetHeight;
      }

      final tooltipAbove =
          preferAbove ? fitsAbove || !fitsBelow : !(fitsBelow || !fitsAbove);

      return tooltipAbove ? AxisDirection.up : AxisDirection.down;
  }
}
