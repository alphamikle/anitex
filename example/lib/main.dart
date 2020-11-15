import 'dart:math';

import 'package:anitex/anitex.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const _counters = [
  19,
  20,
  21,
  22,
  1375,
  2184,
  21849,
  35410,
  35411,
];

const _titles = [
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'Animated text Demo',
  'In any place',
];

const _smallTitles = [
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You have pushed the button this many times:',
  'You can animate any text:',
  'You can animate any text:',
];

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 18;
  String _title = 'Animated text Demo';
  String _smallTitle = 'You have pushed the button this many times:';
  bool _secondPhase = false;
  String _secondPhaseTitle = 'This';
  Duration _secondPhaseDuration = const Duration(milliseconds: 500);
  TextStyle _secondPhaseTextStyle;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
    });
  }

  Future<void> _wait(int ms) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  Future<void> _run() async {
    await _wait(5000);
    for (int i = 0; i < _counters.length; i++) {
      await _wait(Random().nextInt(600) + 400);
      setState(() {
        _counter = _counters[i];
      });
      if (_counter > 35410) {
        setState(() {
          _title = _titles[i];
        });
        await _wait(Random().nextInt(600) + 1000);
        setState(() {
          _smallTitle = _smallTitles[i];
        });
        await _wait(Random().nextInt(600) + 2000);
      }
    }
    setState(() {
      _secondPhase = true;
      _title = 'Animated text Demo';
    });
    await _wait(1200);
    setState(() {
      _secondPhaseTitle = 'is';
    });
    await _wait(800);
    setState(() {
      _secondPhaseTitle = 'Animated Text';
    });
    await _wait(510);
    setState(() {
      _secondPhaseDuration = const Duration(milliseconds: 250);
      _secondPhaseTextStyle = _secondPhaseTextStyle.copyWith(color: Colors.blue);
    });
    await _wait(600);

    Future<void> upd(int i, String letter) async {
      setState(() {
        _secondPhaseTitle = _secondPhaseTitle.replaceRange(i, i + 1, letter);
      });
      int multiplier = (i + 1) * 30;
      await _wait(300 + multiplier);
    }

    // Animated text:
    await upd(0, ' '); // -->  nimated text
    await upd(0, ''); // --> nimated text
    await upd(0, ' '); // --> imated text
    await upd(0, ''); // --> imated text
    await upd(0, 'A'); // --> Amated text
    await upd(1, ' '); // --> Aated text
    await upd(1, ''); // --> Aated text
    await upd(1, 'n'); // --> ANted text
    await upd(2, 'i'); // --> ANIed text
    await upd(3, ' '); // --> ANId text
    await upd(3, ''); // --> ANId text
    await upd(3, ' '); // --> ANI text
    await upd(3, ''); // --> ANI text
    await upd(3, 't'); // --> ANITtext
    await upd(4, ' '); // --> ANIText
    await upd(4, ''); // --> ANIText
    await upd(4, 'e'); // --> ANITExt
    await upd(5, ' '); // --> ANITEt
    await upd(5, ''); // --> ANITEt
    await upd(5, 'x'); // --> ANITEX
    await _wait(2000);
    setState(() {
      _title = 'Anitex Demo';
      _secondPhase = false;
    });
  }

  Widget _buildFirstPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedText(
          _smallTitle,
          duration: const Duration(seconds: 2),
        ),
        AnimatedText(
          '$_counter',
          style: Theme.of(context).textTheme.headline4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              color: Colors.blue,
              highlightColor: Colors.transparent,
              splashColor: Colors.blue.withOpacity(0.25),
              onPressed: _incrementCounter,
              icon: Icon(Icons.add),
            ),
            IconButton(
              color: Colors.red,
              highlightColor: Colors.transparent,
              splashColor: Colors.red.withOpacity(0.25),
              onPressed: _decrementCounter,
              icon: Icon(Icons.remove),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSecondPhase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          maxLines: 1,
          style: _secondPhaseTextStyle,
          child: Builder(
            builder: (BuildContext context) => AnimatedText(
              _secondPhaseTitle,
              duration: _secondPhaseDuration,
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    assert(_counters.length == _titles.length && _counters.length == _smallTitles.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _secondPhaseTextStyle = Theme.of(context).textTheme.headline4;
    _run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedText(
          _title,
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
          duration: const Duration(seconds: 1),
          reversed: true,
        ),
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _secondPhase ? _buildSecondPhase() : _buildFirstPhase(),
        ),
      ),
    );
  }
}
