// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:tutorial_stage/tutorial_stage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial Stage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Tutorial Stage Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _counterKey = GlobalKey();
  StreamSubscription<TutorialStateUpdate>? _tutorialStateSubscription;

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
              const Text('You have pushed the button this many times:'),
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height,
                ),
              ),
              Text(
                '1',
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
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _unlistenToTutorialStateUpdate();
    super.dispose();
  }

  void _listenToTutorialState() {
    _tutorialStateSubscription ??=
        TutorialStage.of(context).state.listen(_onTutorialStateUpdate);
  }

  void _onTutorialStateUpdate(TutorialStateUpdate update) {
    log(
      '[${update.current.type.name}]\n'
      'Previous Tutorial: ${update.previous?.identifier}\n'
      'Current Tutorial: ${update.current.identifier}',
    );
    if (update.current.type == TutorialStateType.finished) {
      TutorialStage.of(context).reset();
    }
  }

  void _unlistenToTutorialStateUpdate() {
    _tutorialStateSubscription?.cancel();
    _tutorialStateSubscription = null;
  }

  void _startTutorial() {
    TutorialStage.build(
      context: context,
      contents: <TutorialContent>[
        _ButtonTutorialContent(),
        _BodyTutorialContent(),
        _CounterTutorialContent(_counterKey, _goToNextPage),
        _TitleTutorialContent(_titleKey),
      ],
    ).start();
    _listenToTutorialState();
  }

  Future<void> _goToNextPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NextPage()),
    );
    // Wait for the transition animation to finish so that it
    // doesn't mess up the target widget position  
    await Future<void>.delayed(const Duration(milliseconds: 300));
    TutorialStage.of(context).next();
  }
}

enum _TutorialIdentifier {
  button,
  body,
  counter,
  title,
}

class _ButtonTutorialContent extends AnimatedTutorialContent {
  _ButtonTutorialContent()
      : super(
          identifier: _TutorialIdentifier.button,
          reverseTransitionDuration: Duration.zero,
        );

  @override
  Widget buildContent(BuildContext context) {
    return _DialogTutorialContentBuilder(
      content: this,
      direction: AxisDirection.down,
      text: 'Dialog Down',
    );
  }
}

class _BodyTutorialContent extends AnimatedTutorialContent {
  _BodyTutorialContent()
      : super(
          identifier: _TutorialIdentifier.body,
          transitionDuration: Duration.zero,
        );

  @override
  Widget buildContent(BuildContext context) {
    return _DialogTutorialContentBuilder(
      content: this,
      direction: AxisDirection.up,
      text: 'Dialog Up',
    );
  }
}

class _CounterTutorialContent extends AnimatedTutorialContent {
  _CounterTutorialContent(this._counterKey, this._onNextPage)
      : super(identifier: _TutorialIdentifier.counter);

  final GlobalKey _counterKey;
  final VoidCallback _onNextPage;

  @override
  Future<void> start() async {
    await Scrollable.ensureVisible(
      _counterKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final Rect rect =
        _counterKey.boxPosition!.rect.withPadding(const EdgeInsets.all(4));
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
              key: const ValueKey<_TutorialIdentifier>(
                _TutorialIdentifier.title,
              ),
              onPressed: () => TutorialStage.of(context).pause(),
              child: const Text('Counter'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didFinish() {
    _onNextPage();
    super.didFinish();
  }
}

class _TitleTutorialContent extends AnimatedTutorialContent {
  _TitleTutorialContent(this._titleKey)
      : super(identifier: _TutorialIdentifier.title);

  final GlobalKey _titleKey;

  @override
  Widget buildContent(BuildContext context) {
    final Rect rect =
        _titleKey.boxPosition!.rect.withPadding(const EdgeInsets.all(6));
    return SpotlightStage(
      rect: rect,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      children: <Widget>[
        AlignRect(
          rect: rect,
          alignment: const Alignment(0.0, 2.25),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton(
              key: const ValueKey<_TutorialIdentifier>(
                  _TutorialIdentifier.title),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () => TutorialStage.of(context).next(),
              child: const Text('Title'),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogTutorialContentBuilder extends FinishableTutorialWidget {
  const _DialogTutorialContentBuilder({
    required this.content,
    required this.direction,
    required this.text,
  });

  @override
  final FinishableTutorialContent content;
  final AxisDirection direction;
  final String text;

  @override
  _DialogTutorialContentBuilderState createState() =>
      _DialogTutorialContentBuilderState();
}

class _DialogTutorialContentBuilderState
    extends FinishableTutorialWidgetState<_DialogTutorialContentBuilder> {
  final TheTooltipKey _tooltipKey = TheTooltipKey();

  @override
  void initState() {
    super.initState();
    _showTooltip();
  }

  @override
  void didUpdateContent(covariant FinishableTutorialContent oldContent) {
    super.didUpdateContent(oldContent);
    _showTooltip();
  }

  @override
  Widget build(BuildContext context) {
    return TheTooltip(
      key: _tooltipKey,
      preferredDirection: widget.direction,
      content: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Bacon ipsum dolor amet kevin turducken brisket pastrami, '
          'salami ribeye spare ribs tri-tip sirloin shoulder venison '
          'shank burgdoggen chicken pork belly. Short loin filet mignon '
          'shoulder rump beef ribs meatball kevin.',
        ),
      ),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 12.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.text),
              ElevatedButton(
                onPressed: _next,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTooltip() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _tooltipKey.currentState?.showTooltip();
    });
  }

  void _next() {
    TutorialStage.of(context).next();
  }

  @override
  Future<void> finish() async {
    await _tooltipKey.currentState?.hideTooltip();
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key});

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Next Tutorial on Previous Page'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
