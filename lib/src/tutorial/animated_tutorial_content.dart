part of tutorial;

Widget _defaultAnimatedTutorialTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: secondaryAnimation,
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

abstract class AnimatedTutorialContent extends FinishableTutorialContent {
  AnimatedTutorialContent({
    super.identifier,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.reverseTransitionDuration = const Duration(milliseconds: 200),
  });

  final Duration transitionDuration;

  final Duration reverseTransitionDuration;

  @override
  @nonVirtual
  _AnimatedTutorialContentBuilder build(BuildContext context) {
    return _AnimatedTutorialContentBuilder(content: this);
  }

  Widget buildContent(BuildContext context);

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _defaultAnimatedTutorialTransitionsBuilder(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Duration>(
        'transitionDuration',
        transitionDuration,
      ))
      ..add(DiagnosticsProperty<Duration>(
        'reverseTransitionDuration',
        reverseTransitionDuration,
      ));
  }
}

enum _AnimatedTutorialBuilderLifecycle {
  entering,
  presenting,
  exiting,
  disposed,
}

class _AnimatedTutorialContentBuilder extends FinishableTutorialWidget {
  const _AnimatedTutorialContentBuilder({
    required this.content,
  });

  @override
  final AnimatedTutorialContent content;

  @override
  _AnimatedTutorialContentBuilderState createState() =>
      _AnimatedTutorialContentBuilderState();
}

class _AnimatedTutorialContentBuilderState
    extends FinishableTutorialWidgetState<_AnimatedTutorialContentBuilder>
    with SingleTickerProviderStateMixin<_AnimatedTutorialContentBuilder> {
  late final AnimationController _animationController;
  late final ProxyAnimation _animation;
  late final ProxyAnimation _secondaryAnimation;

  AnimatedTutorialContent get _content => widget.content;
  Duration get _transitionDuration => _content.transitionDuration;
  Duration get _reverseTransitionDuration => _content.reverseTransitionDuration;

  _AnimatedTutorialBuilderLifecycle _currentState =
      _AnimatedTutorialBuilderLifecycle.entering;
  bool get _shouldIgnoreUserGesture {
    return _currentState != _AnimatedTutorialBuilderLifecycle.presenting;
  }

  bool get _isInactive {
    return _currentState == _AnimatedTutorialBuilderLifecycle.exiting ||
        _currentState == _AnimatedTutorialBuilderLifecycle.disposed;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _transitionDuration,
      reverseDuration: _reverseTransitionDuration,
    );
    _animation = ProxyAnimation(_animationController.view);
    _secondaryAnimation = ProxyAnimation(kAlwaysCompleteAnimation);
    _beginEnterTransition();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return _content.buildTransitions(
          context,
          _animation,
          _secondaryAnimation,
          IgnorePointer(
            ignoring: _shouldIgnoreUserGesture,
            child: child,
          ),
        );
      },
      child: Builder(
        builder: (BuildContext context) {
          return _content.buildContent(context);
        },
      ),
    );
  }

  @override
  void didUpdateContent(covariant AnimatedTutorialContent oldContent) {
    super.didUpdateContent(oldContent);
    _updateAnimation();
    _beginEnterTransition();
  }

  @override
  void dispose() {
    _beginDispose();
    super.dispose();
  }

  void _updateAnimation() {
    _currentState = _AnimatedTutorialBuilderLifecycle.entering;
    _animationController.reset();
    _animationController.duration = _transitionDuration;
    _animationController.reverseDuration = _reverseTransitionDuration;
    _animation.parent = _animationController.view;
    _secondaryAnimation.parent = kAlwaysCompleteAnimation;
  }

  Future<void> _beginEnterTransition() async {
    await _animationController.forward();
    _currentState = _AnimatedTutorialBuilderLifecycle.presenting;
  }

  @override
  Future<void> finish() => _beginExitTransition();

  Future<void> _beginExitTransition() async {
    if (_isInactive) return;
    _currentState = _AnimatedTutorialBuilderLifecycle.exiting;
    final Animation<double>? current = _animation.parent;
    _animation.parent = kAlwaysCompleteAnimation;
    _secondaryAnimation.parent = current;
    return _animationController.reverse();
  }

  void _beginDispose() {
    _currentState = _AnimatedTutorialBuilderLifecycle.disposed;
    _animationController.dispose();
  }
}
