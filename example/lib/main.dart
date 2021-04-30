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
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 18;
  int _times = 1;

  void _updateTimes() {
    _times++;
  }

  Future<void> _wait(int ms) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _updateTimes();
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      _updateTimes();
    });
  }

  void _randomCounter() {
    setState(() {
      _counter = Random().nextInt(10000);
      _updateTimes();
    });
  }

  void _setCounter(int counter) {
    setState(() {
      _counter = counter;
    });
  }

  Future<void> _run() async {
    const int delay = 700;
    await _wait(delay);
    _incrementCounter();
    await _wait(delay);
    _incrementCounter();
    await _wait(delay);
    _incrementCounter();
    await _wait(delay);
    _incrementCounter();
    await _wait(delay);
    _setCounter(90);
    await _wait(delay);
    _setCounter(349);
    await _wait(delay);
    _setCounter(166);
    await _wait(delay);
    _setCounter(939);
    _randomCounter();
    await _wait(delay);
    _randomCounter();
  }

  Widget _buildAnimation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedText(
          _times % 7 == 0 ? 'You can really animate any text:' : 'You can animate any text:',
          duration: const Duration(milliseconds: 700),
        ),
        AnimatedText(
          '$_counter',
          style: Theme.of(context).textTheme.headline4,
          useOpacity: true,
          duration: const Duration(milliseconds: 350),
          reversed: true,
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
              color: Colors.green,
              highlightColor: Colors.transparent,
              splashColor: Colors.blue.withOpacity(0.25),
              onPressed: _randomCounter,
              icon: Icon(Icons.refresh),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedText(
          _times % 7 == 0 ? 'Any text' : 'Anitex demo',
          duration: const Duration(milliseconds: 700),
        ),
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildAnimation(),
        ),
      ),
    );
  }
}
