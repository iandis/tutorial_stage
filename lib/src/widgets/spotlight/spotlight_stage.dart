part of spotlight;

class SpotlightStage extends StatelessWidget {
  const SpotlightStage({
    super.key,
    required this.rect,
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
    this.children = const <Widget>[],
  });

  final Rect rect;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  /// Called when user taps on the spotlight and its skrim area
  final VoidCallback? onTap;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        Spotlight(
          rect: rect,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          onTap: onTap,
        ),
        ...children,
      ],
    );
  }
}
