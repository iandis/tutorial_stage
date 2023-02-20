## TutorialStage

A Flutter package for creating highly customized tutorials.

## Getting Started

1. Add dependency to `pubspec.yaml`

```yaml
dependencies:
  tutorial_stage: <latest-version>
```

2. Import the package

```dart
import 'package:tutorial_stage/tutorial_stage.dart';
```

3. Add `TutorialStage` to your widget tree

```dart
TutorialStage(
  child: SomeWidget(),
)
```

4. Adding `TutorialContent`s

```dart
enum TutorialIdentifier {
  button,
  title,
  counter,
}

class TutorialContentExample extends StatelessWidget {
  const TutorialContentExample({
    super.key,
    required this.key,
    required this.text,
  });

  final GlobalKey key;
  final String text;

  @override
  Widget build(BuildContext context) {
    final Rect rect = key.boxPosition!.rect.withPadding(const EdgeInsets.all(4));
    return SpotlightStage(
      rect: rect,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
        children: <Widget>[
          AlignRect(
            rect: rect,
            alignment: const Alignment(0.0, 2.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ElevatedButton(
                onPressed: () => TutorialStage.of(context).next(),
                child: Text(text),
            ),
          ),
        ),
      ],
    );
  }
}

class ButtonTutorialContent extends AnimatedTutorialContent {
  ButtonTutorialContent(this._buttonKey)
      : super(identifier: TutorialIdentifier.button);

  final GlobalKey _buttonKey;

  @override
  Widget buildContent(BuildContext context) {
    return TutorialContentExample(
      key: _buttonKey,
      text: 'Button',
    );
  }
}

class TitleTutorialContent extends AnimatedTutorialContent {
  TitleTutorialContent(this._titleKey)
      : super(identifier: TutorialIdentifier.title);

  final GlobalKey _titleKey;

  @override
  Widget buildContent(BuildContext context) {
    return TutorialContentExample(
      key: _titleKey,
      text: 'Title',
    );
  }
}

class CounterTutorialContent extends AnimatedTutorialContent {
  CounterTutorialContent(this._counterKey)
      : super(identifier: TutorialIdentifier.counter);

  final GlobalKey _counterKey;

  @override
  Future<void> start() async {
    await Scrollable.ensureVisible(
      _counterKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return TutorialContentExample(
      key: _counterKey,
      text: 'Counter',
    );
  }
}
```

5. Starting the tutorial

```dart
final GlobalKey _buttonKey = GlobalKey();
final GlobalKey _titleKey = GlobalKey();
final GlobalKey _counterKey = GlobalKey();

@override
Widget build(BuildContext context) {
  return TutorialStage(
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          key: _titleKey,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('This is text'),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height,
              ),
            ),
            Text(
              'This the target text',
              key: _counterKey,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _buttonKey,
        onPressed: _startTutorial,
        child: const Text('Start'),
      ),
    ),
  );
}

void _startTutorial() {
  TutorialStage.build(
    context: context,
    contents: <TutorialContent>[
      _ButtonTutorialContent(_buttonKey),
      _TitleTutorialContent(_titleKey),
      _CounterTutorialContent(_counterKey),
    ],
  ).start();
}
```
