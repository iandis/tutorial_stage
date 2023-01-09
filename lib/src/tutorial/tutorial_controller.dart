part of tutorial;

abstract class TutorialController {
  /// Current tutorial state.
  Stream<TutorialStateUpdate> get state;

  /// Starts tutorial from content with identifier of [at].
  void start({Object? at});

  /// Moves to **next** content with identifier of [to].
  /// If [to] is null, it will move to the **next** content.
  /// Identifier [to] should not be **before** current content, otherwise it will
  /// throw a [StateError] on debug mode.
  void next({Object? to});

  /// Pauses tutorial.
  void pause();

  /// Moves to **previous** content with identifier of [to].
  /// If [to] is null, it will move to the **previous** content.
  /// Identifier [to] should not be **after** current content, otherwise it will
  /// throw a [StateError] on debug mode.
  void previous({Object? to});

  /// Finishes tutorial.
  void finish();

  /// Resets tutorial.
  /// This will remove all contents.
  void reset();
}
