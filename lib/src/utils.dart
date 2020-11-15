import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Size getTextWidgetSize(String text, TextStyle style, {double minWidth = 0, double maxWidth = double.infinity}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.size;
}

extension TryToGetElement on Iterable {
  T tryElementAt<T>(int index) {
    T value;
    try {
      value = elementAt(index);
    } catch (err) {
      // DO NOTHING
    }
    return value;
  }
}
