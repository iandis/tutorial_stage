part of tutorial;

abstract class FinishableTutorialWidget extends StatefulWidget {
  const FinishableTutorialWidget({super.key});

  FinishableTutorialContent get content;

  @override
  FinishableTutorialWidgetState<FinishableTutorialWidget> createState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FinishableTutorialContent>(
      'content',
      content,
    ));
  }
}

abstract class FinishableTutorialWidgetState<S extends FinishableTutorialWidget>
    extends State<S> with _FinishableDelegate {
  @override
  void initState() {
    super.initState();
    _setContentFinishCallback();
  }

  @override
  void didUpdateWidget(covariant S oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      didUpdateContent(oldWidget.content);
    }
  }

  @override
  void dispose() {
    _removeContentFinishCallback();
    super.dispose();
  }

  @mustCallSuper
  @protected
  void didUpdateContent(covariant FinishableTutorialContent oldContent) {
    _removeCallback(oldContent);
    _setContentFinishCallback();
  }

  void _addCallback(FinishableTutorialContent content) {
    content._add(this);
  }

  void _removeCallback(FinishableTutorialContent content) {
    content._remove(this);
  }

  void _setContentFinishCallback() {
    _addCallback(widget.content);
  }

  void _removeContentFinishCallback() {
    _removeCallback(widget.content);
  }
}
