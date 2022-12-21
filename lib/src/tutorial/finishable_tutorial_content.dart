part of tutorial;

abstract class FinishableTutorialContent extends TutorialContent {
  FinishableTutorialContent({super.identifier});

  @override
  FinishableTutorialWidget build(BuildContext context);

  final List<_FinishableDelegate> _delegates = <_FinishableDelegate>[];

  void _add(_FinishableDelegate finishable) {
    assert(!_delegates.contains(finishable));
    _delegates.add(finishable);
  }

  void _remove(_FinishableDelegate finishable) {
    if (_delegates.isEmpty) return;
    _delegates.remove(finishable);
  }

  @override
  @mustCallSuper
  FutureOr<void> finish() async {
    if (_delegates.isEmpty) return;
    for (int i = _delegates.length - 1; i >= 0; i--) {
      final _FinishableDelegate finishable = _delegates[i];
      await finishable.finish();
    }
  }

  @override
  @mustCallSuper
  void didFinish() {
    if (_delegates.isEmpty) return;
    for (int i = _delegates.length - 1; i >= 0; i--) {
      final _FinishableDelegate finishable = _delegates[i];
      finishable.didFinish();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<_FinishableDelegate>>(
      'finishables',
      _delegates,
      missingIfNull: false,
    ));
  }
}

abstract class _FinishableDelegate {
  /// {@macro tutorial_stage.TutorialContent.finish}
  FutureOr<void> finish();

  /// {@macro tutorial_stage.TutorialContent.didFinish}
  void didFinish() {}
}
