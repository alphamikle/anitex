## Anitex

Animated text widget package for flutter

### Getting started
Anitex - is a simple package, which give you possibility to implicitly
animate any text. The most impressive animation is achieve if the old
and new lines are the same length, or don't differ too much in length.

The widget has a limitation - it is possible to write text in only one 
line, and it is also desirable to explicitly specify the text styles
(you can get textStyle from context and pass it to `AnimatedText`).


#### Example of usage:
```dart
  /// ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedText(
          title,
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
          duration: const Duration(seconds: 1),
        ),
      ),
      body: Center(
        child: AnimatedText(
          content,
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
          reversed: true,
        ),
      ),
    );
  }
```