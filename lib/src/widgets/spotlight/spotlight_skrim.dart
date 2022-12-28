part of spotlight;

class SpotlightSkrim extends StatelessWidget {
  const SpotlightSkrim({
    super.key,
    this.backgroundColor,
    this.child,
  });

  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final SpotlightTheme? theme = Theme.of(context).extension<SpotlightTheme>();
    final Color backgroundColor = this.backgroundColor ??
        theme?.backgroundColor ??
        SpotlightTheme._defaultBackgroundColor;

    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: ColoredBox(
        color: backgroundColor,
        child: child,
      ),
    );
  }
}
