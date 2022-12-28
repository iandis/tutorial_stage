part of tutorial;

class TutorialStage extends StatefulWidget {
  const TutorialStage({
    super.key,
    this.isChildOpaque = true,
    this.shouldMaintainChildState = true,
    required this.child,
  });

  /// See [OverlayEntry.opaque] for more information.
  final bool isChildOpaque;

  /// See [OverlayEntry.maintainState] for more information.
  final bool shouldMaintainChildState;

  final Widget child;

  /// Obtains nearest [TutorialStage]
  ///
  /// It is safe to call this inside a [State].
  /// ```dart
  /// class _MyState extends State<MyWidget> {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return TutorialStage(
  ///       child: (...)
  ///     );
  ///   }
  ///
  ///   void startTutorial() {
  ///     TutorialStage.of(context).start(); // OK
  ///   }
  /// }
  /// ```
  ///
  /// It is also safe to call this inside a [StatelessWidget].
  /// ```dart
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return TutorialStage(
  ///       child: SomeButton(
  ///         // OK
  ///         onPressed: () => TutorialStage.of(context).start(),
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  static TutorialController of(BuildContext context) {
    final TutorialController? controller = _maybeOf(context);
    assert(controller != null, 'No TutorialStage found in the widget tree');
    return controller!;
  }

  /// Obtains nearest [TutorialStage]
  ///
  /// Returns `null` when no TutorialStage found in the widget tree
  static TutorialController? maybeOf(BuildContext context) {
    final TutorialController? controller = _maybeOf(context);
    return controller;
  }

  /// Initiates tutorial [contents] for nearest [TutorialStage].
  /// This will finish and clear any running tutorial if any.
  static TutorialController build({
    required BuildContext context,
    required List<TutorialContent> contents,
  }) {
    assert(() {
      final Set<Object> identifiers = <Object>{};
      for (final TutorialContent content in contents) {
        final Object? identifier = content.identifier;
        if (identifier == null) continue;
        if (identifiers.contains(identifier)) {
          throw StateError(
            'Duplicate tutorial content identifier found: $identifier. '
            'Each tutorial content must have a unique identifier.',
          );
        }
        identifiers.add(identifier);
      }
      return true;
    }());
    final _TutorialStageState? state = _maybeOf(context);
    assert(state != null, 'No TutorialStage found in the widget tree');
    return state!.._initContents(contents);
  }

  static _TutorialStageState? _maybeOf(
    BuildContext context, {
    bool shouldFindBelow = true,
  }) {
    // Try to find the controller below the [context]
    if (shouldFindBelow) {
      final _TutorialStageState? state = _findBelowContext(context);
      if (state != null) return state;
    }

    // Try to find the controller above the [context]
    final _TutorialStageState? state = _findAboveContext(context);
    return state!;
  }

  static _TutorialStageState? _findBelowContext(BuildContext context) {
    assert(
      !context.debugDoingBuild,
      'Cannot obtain TutorialStage during build',
    );

    if (!(context is StatelessElement || context is StatefulElement)) {
      return null;
    }

    _TutorialStageState? state;
    context.visitChildElements((Element element) {
      if (!(element is StatefulElement && element.widget is TutorialStage)) {
        return;
      }
      state = element.state as _TutorialStageState;
    });

    if (state != null) return state!;
    return null;
  }

  static _TutorialStageState? _findAboveContext(BuildContext context) {
    final _TutorialStageScope? scope = context
        .getElementForInheritedWidgetOfExactType<_TutorialStageScope>()
        ?.widget as _TutorialStageScope?;
    return scope?.state;
  }

  @override
  _TutorialStageState createState() => _TutorialStageState();
}

class _TutorialStageState extends State<TutorialStage>
    implements TutorialController {
  @override
  void didUpdateWidget(TutorialStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChildOpaque == widget.isChildOpaque ||
        oldWidget.shouldMaintainChildState == widget.shouldMaintainChildState) {
      return;
    }
    _childEntry?.opaque = widget.isChildOpaque;
    _childEntry?.maintainState = widget.shouldMaintainChildState;
  }

  void _debugCheckStageReadiness() {
    assert(() {
      if (_isStageReady && (_overlayKey == null || _childEntry == null)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'Stage is ready but overlay key and/or child overlay entry is null',
          ),
          ErrorDescription(
            'This is most likely a bug in this library. Please file an issue '
            'with the reproducible steps.',
          ),
        ]);
      }

      if (!_isStageReady && (_overlayKey != null || _childEntry != null)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'Stage is not ready but overlay key and/or child overlay entry is not null',
          ),
          ErrorDescription(
            'This is most likely a bug in this library. Please file an issue '
            'with the reproducible steps.',
          ),
        ]);
      }

      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    _debugCheckStageReadiness();
    return _TutorialStageScope(
      state: this,
      child: _isStageReady
          ? Overlay(
              key: _overlayKey,
              initialEntries: <OverlayEntry>[_childEntry!],
            )
          : _child,
    );
  }

  bool _debugDisposed = false;

  @override
  void dispose() {
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    _stateController.close();
    super.dispose();
  }

  void _debugCheckDisposed() {
    assert(() {
      if (!_debugDisposed) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'TutorialController@$hashCode has been disposed.',
        ),
        ErrorDescription(
          'Make sure to never keep a copy of `TutorialController` and '
          'always obtain it using `TutorialStage.of` or `TutorialStage.maybeOf`.\n'
          'This is because TutorialStage might have been removed from '
          'the widget tree in during widget rebuilds',
        ),
      ]);
    }());
  }

  // Child Overlay
  /// Should only be enabled when [_currentContent] is null
  bool _isChildEnabled = true;
  OverlayEntry? _childEntry;

  late final Widget _child = KeyedSubtree(
    key: GlobalKey(),
    child: widget.child,
  );
  Widget _buildChild(BuildContext context) {
    return IgnorePointer(
      ignoring: !_isChildEnabled,
      child: _child,
    );
  }

  void _updateChild({required bool isEnabled}) {
    if (_isChildEnabled == isEnabled) return;
    _isChildEnabled = isEnabled;
    _childEntry?.markNeedsBuild();
  }

  void _initContents(List<TutorialContent> contents) {
    _debugCheckDisposed();
    if (_currentContent != null) {
      _finish();
    }
    assert(_currentContentIndex == -1);
    assert(_currentContent == null);
    assert(_currentContentOverlay == null);
    assert(_isChildEnabled);
    _contents = contents;
    _prepareStage();
  }

  bool _isStageReady = false;
  void _prepareStage() {
    if (_isStageReady) return;
    setState(() {
      _overlayKey = GlobalKey<OverlayState>();
      _childEntry = OverlayEntry(
        opaque: widget.isChildOpaque,
        maintainState: widget.shouldMaintainChildState,
        builder: _buildChild,
      );
      _isStageReady = true;
    });
  }

  void _destroyStage() {
    if (!_isStageReady) return;
    setState(() {
      _overlayKey = null;
      _childEntry = null;
      _isStageReady = false;
    });
  }

  // Tutorial Content
  int _currentContentIndex = -1;
  List<TutorialContent> _contents = const <TutorialContent>[];
  TutorialContent? _currentContent;
  OverlayEntry? _currentContentOverlay;

  // Tutorial Overlay
  GlobalKey<OverlayState>? _overlayKey;
  OverlayState? get _overlay => _overlayKey?.currentState;

  Widget _buildContent(BuildContext context) {
    assert(_currentContent != null);
    return _currentContent!.build(context);
  }

  void _insertCurrentContentOverlay() {
    assert(_overlay != null);
    final OverlayEntry newEntry = OverlayEntry(builder: _buildContent);
    _currentContentOverlay = newEntry;
    _overlay!.insert(newEntry);
  }

  void _updateCurrentContentOverlay() {
    assert(_currentContentOverlay != null);
    _currentContentOverlay!.markNeedsBuild();
  }

  void _upsertCurrentContentOverlay() {
    if (_currentContentOverlay == null) {
      _insertCurrentContentOverlay();
    } else {
      _updateCurrentContentOverlay();
    }
  }

  void _removeCurrentContentOverlay() {
    _currentContentOverlay?.remove();
    _currentContentOverlay = null;
  }

  // Tutorial State
  final BehaviorSubject<TutorialStateUpdate> _stateController =
      BehaviorSubject<TutorialStateUpdate>();
  @override
  ValueStream<TutorialStateUpdate> get state => _stateController.stream;
  TutorialStateType? _currentState;

  TutorialStateUpdate _createStateUpdate(
    TutorialStateType type,
    TutorialContent content,
  ) {
    final TutorialState? previous = state.valueOrNull?.current;
    final TutorialState current = TutorialState(
      type: type,
      identifier: content.identifier,
    );
    return TutorialStateUpdate(
      previous: previous,
      current: current,
    );
  }

  void _updateState(TutorialStateType type, {TutorialContent? forContent}) {
    final TutorialContent? content = forContent ?? _currentContent;
    if (content == null) return;
    if (kDebugMode) _currentState = type;
    _stateController.add(_createStateUpdate(type, content));
  }

  void _removeContent() {
    _removeCurrentContentOverlay();
    _currentContent = null;
    _updateChild(isEnabled: true);
  }

  Future<void> _createContent() async {
    final TutorialContent newContent = _contents[_currentContentIndex];
    await newContent.start();
    _currentContent = newContent;
  }

  Future<void> _changeContent() async {
    if (_contents.isEmpty) return;
    if (_currentContentIndex == -1) {
      _removeContent();
      return;
    }
    _updateChild(isEnabled: false);
    await _createContent();
    _upsertCurrentContentOverlay();
  }

  Future<void> _finishCurrentContent() async {
    final TutorialContent? content = _currentContent;
    if (content == null) return;
    await content.finish();
  }

  void _didFinishCurrentContent() {
    final TutorialContent? content = _currentContent;
    if (content == null) return;
    final Object? debugCheckForReturnedFuture = content.didFinish() as dynamic;
    assert(() {
      if (debugCheckForReturnedFuture is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('${content.runtimeType}.didFinish() returned a Future.'),
          ErrorDescription(
            'TutorialContent.didFinish() must be a void method without an `async` keyword.',
          ),
        ]);
      }
      return true;
    }());
  }

  Future<void> _beginChangeContent(
    int Function(int currentIndex) onChangeIndex,
    TutorialStateType type,
  ) async {
    await _finishCurrentContent();
    _didFinishCurrentContent();
    if (_contents.isEmpty) return;
    _currentContentIndex = onChangeIndex(_currentContentIndex);
    await _changeContent();
    _updateState(type);
  }

  int? _getIdentifierIndex(Object? identifier) {
    if (identifier == null) return null;
    assert(_contents.isNotEmpty, 'No TutorialContent has been built.');
    final int identifierIndex = _contents.indexWhere(
      (TutorialContent content) => content.identifier == identifier,
    );
    if (identifierIndex == -1) {
      assert(() {
        throw StateError(
          'No TutorialContent with identifier "$identifier" found.',
        );
      }());
      return null;
    }
    return identifierIndex;
  }

  /// Compares [index] against [currentIndex] and validate according to
  /// [expectedIndexDifference].
  ///
  /// Set [expectedIndexDifference] to:
  /// * 1 -> [index] must be greater than [currentIndex]
  /// * -1 -> [index] must be less than [currentIndex]
  ///
  /// Returns null if [index] is null.
  /// Otherwise, returns [index] if it is valid, throws an error when invalid.
  @pragma('vm:prefer-inline')
  static int? _validateIdentifierIndex(
    int? index,
    int currentIndex,
    int expectedIndexDifference,
  ) {
    if (index == null) return null;
    assert(
      expectedIndexDifference == 1 || expectedIndexDifference == -1,
      'Invalid expectedIndexDifference: $expectedIndexDifference. '
      'Must be 1 or -1.',
    );
    assert(() {
      final int indexDifference = index.compareTo(currentIndex);
      if (indexDifference != expectedIndexDifference) {
        final String expectedIndexComparison =
            expectedIndexDifference > 0 ? 'after' : 'before';
        throw StateError(
          'Unexpected TutorialContent identifier index: $index. '
          'Target TutorialContent should be $expectedIndexComparison current content.',
        );
      }
      return true;
    }());
    return index;
  }

  bool _isChanging = false;
  void _toggleIsChanging() {
    _isChanging = !_isChanging;
  }

  @override
  Future<void> start({Object? at}) async {
    _debugCheckDisposed();
    if (_isChanging || _currentContentIndex != -1) {
      return;
    }

    _toggleIsChanging();
    final Completer<void> startCompleter = Completer<void>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _beginChangeContent(
        (_) => _getIdentifierIndex(at) ?? 0,
        TutorialStateType.started,
      ).then(startCompleter.complete).onError(startCompleter.completeError);
    });
    await startCompleter.future;
    _toggleIsChanging();
  }

  @override
  Future<void> next({Object? to}) async {
    _debugCheckDisposed();
    if (_currentContentIndex == _contents.length - 1) {
      return finish();
    }
    if (_isChanging) return;

    _toggleIsChanging();
    await _beginChangeContent(
      (int currentIndex) =>
          _validateIdentifierIndex(_getIdentifierIndex(to), currentIndex, 1) ??
          currentIndex + 1,
      TutorialStateType.movedNext,
    );
    _toggleIsChanging();
  }

  @override
  Future<void> pause() async {
    _debugCheckDisposed();
    if (_isChanging || _currentContentIndex == -1 || _contents.isEmpty) {
      return;
    }

    _toggleIsChanging();
    await _finishCurrentContent();
    _didFinishCurrentContent();
    final TutorialContent lastContent = _currentContent!;
    _currentContent = const _EmptyTutorialContent();
    _updateCurrentContentOverlay();
    _updateState(TutorialStateType.paused, forContent: lastContent);
    _toggleIsChanging();
  }

  @override
  Future<void> previous({Object? to}) async {
    _debugCheckDisposed();
    if (_isChanging || _currentContentIndex == 0) {
      return;
    }

    _toggleIsChanging();
    await _beginChangeContent(
      (int currentIndex) =>
          _validateIdentifierIndex(_getIdentifierIndex(to), currentIndex, -1) ??
          currentIndex - 1,
      TutorialStateType.movedPrevious,
    );
    _toggleIsChanging();
  }

  void _finish() {
    final int lastContentIndex = _currentContentIndex;
    _currentContentIndex = -1;
    _changeContent();
    final TutorialContent content = _contents[lastContentIndex];
    if (kDebugMode) _currentState = TutorialStateType.finished;
    _stateController.add(_createStateUpdate(
      TutorialStateType.finished,
      content,
    ));
  }

  @override
  Future<void> finish() async {
    _debugCheckDisposed();
    if (_isChanging || _currentContentIndex == -1) {
      return;
    }

    _toggleIsChanging();
    await _finishCurrentContent();
    _didFinishCurrentContent();
    _finish();
    _destroyStage();
    _toggleIsChanging();
  }

  @override
  void reset() {
    _debugCheckDisposed();
    _removeCurrentContentOverlay();
    assert(_currentContentOverlay == null);
    _currentContent = null;
    _currentContentIndex = -1;
    _contents = const <TutorialContent>[];
    if (kDebugMode) _currentState = null;
    _destroyStage();
    _updateChild(isEnabled: true);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<TutorialStateType>(
        'currentState',
        _currentState,
        ifNull: 'initialized',
        missingIfNull: false,
      ))
      ..add(FlagProperty(
        'isChildEnabled',
        value: _isChildEnabled,
        ifTrue: 'enabled',
        ifFalse: 'disabled',
        showName: true,
      ))
      ..add(IntProperty('currentTargetIndex', _currentContentIndex))
      ..add(DiagnosticsProperty<TutorialContent>(
        'currentContent',
        _currentContent,
        missingIfNull: false,
      ));
  }
}

class _TutorialStageScope extends InheritedWidget {
  const _TutorialStageScope({
    required this.state,
    required super.child,
  });

  final _TutorialStageState state;

  @override
  bool updateShouldNotify(_TutorialStageScope oldWidget) => false;
}
