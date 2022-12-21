part of tutorial;

abstract class TutorialContent with Diagnosticable {
  const TutorialContent({this.identifier});

  /// A unique identifier for this content.
  final Object? identifier;

  /// Starts the content.
  ///
  /// This is called before [build]
  FutureOr<void> start() {}

  Widget build(BuildContext context);

  /// {@template tutorial_stage.TutorialContent.finish}
  /// Finishes the content
  ///
  /// This is called when this content is about to be removed
  /// {@endtemplate}
  FutureOr<void> finish() {}

  /// {@template tutorial_stage.TutorialContent.didFinish}
  /// This is called after [finish]
  ///
  /// This should not be a [Future] method because this might be called
  /// before disposing the [Widget] created by [build]
  /// {@endtemplate}
  void didFinish() {}

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object?>(
      'identifier',
      identifier,
      missingIfNull: false,
    ));
  }
}
