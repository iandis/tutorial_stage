part of tutorial;

enum TutorialStateType {
  started,
  movedNext,
  paused,
  movedPrevious,
  finished,
}

class TutorialState {
  const TutorialState({
    required this.type,
    required this.identifier,
  });

  final TutorialStateType type;
  final Object? identifier;
}

class TutorialStateUpdate {
  const TutorialStateUpdate({
    required this.previous,
    required this.current,
  });

  final TutorialState? previous;
  final TutorialState current;
}
