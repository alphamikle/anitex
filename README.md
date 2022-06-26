## <span style="color:#3892fa">Ani</span>mated<span style="color:#3892fa">Tex</span>tWidget

### Getting started
**Anitex** - is a simple package, which give you access to implicitly animate any text. The most impressive animation is achieve if the old and new lines are the same length, or don't differ too much in length.


#### Example of usage:
```dart
  /// ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedText(
          title, // This is just a [String]
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
          duration: const Duration(seconds: 1),
        ),
      ),
      body: Center(
        child: AnimatedText(
          content,
          reversed: true,
        ),
      ),
    );
  }
```

<img src="https://github.com/alphamikle/anitex/raw/master/demo.gif" width="400">