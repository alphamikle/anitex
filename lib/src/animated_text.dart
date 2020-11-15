/*
 * MIT License
 *
 * Copyright (c) 2020 Mikhail Alpha <alphamikle@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:math';

import 'package:flutter/widgets.dart';

import 'animated_token.dart';
import 'direction.dart';
import 'utils.dart';

/// Animated text widget
class AnimatedText extends StatefulWidget {
  const AnimatedText(
    this.text, {
    Key key,
    this.style,
    this.duration = const Duration(milliseconds: 300),
    this.reversed = false,
  })  : assert(duration != null),
        assert(text != null),
        super(key: key);

  final String text;

  /// If non-null, the style to use for this text.
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle style;

  /// The duration over which to animate the parameters of this container.
  final Duration duration;

  /// If [reversed] is true, then letter, which was greater in [letter.compareTo(oldLetter)]
  /// will be at bottom, if false - at top.
  /// [reversed] is false
  /// 0       _
  /// 1   ->  0
  /// _       1
  /// [reversed] is true
  /// 1       _
  /// 0   ->  1
  /// _       0
  final bool reversed;

  @override
  _AnimatedTextState createState() {
    return _AnimatedTextState();
  }
}

class _AnimatedTextState extends State<AnimatedText> with TickerProviderStateMixin {
  final List<String> _tokens = [];
  final List<String> _prevTokens = [];
  final List<AnimatedToken> _animatedTokens = [];
  AnimationController _animationController;
  double _prevTotalHeight = 0;
  double _prevTotalWidth = 0;
  Tween<double> _totalWidthTween = Tween(begin: 0, end: 0);
  Tween<double> _totalHeightTween = Tween(begin: 0, end: 0);

  Map<int, Direction> get _directions => {
        -1: widget.reversed ? Direction.top : Direction.bottom,
        0: Direction.none,
        1: widget.reversed ? Direction.bottom : Direction.top,
      };

  void _initTokens() {
    _prevTokens.clear();
    _prevTokens.addAll(_tokens);
    _tokens.clear();
    _tokens.addAll(widget.text.split(''));
    _computeTokens();
    _computePositions();
    _computeAnimations();
    _runAnimations();
  }

  void _computePositions() {
    double totalHeight = 0;
    double totalWidth = 0;
    for (final AnimatedToken animatedToken in _animatedTokens) {
      final double maxHeight = max(max(animatedToken.topSize.height, animatedToken.centerSize.height), animatedToken.bottomSize.height);
      double maxWidth;
      if (animatedToken.direction == Direction.none) {
        maxWidth = animatedToken.centerSize.width;
      }
      if (animatedToken.direction == Direction.bottom) {
        maxWidth = animatedToken.topSize.width;
      }
      if (animatedToken.direction == Direction.top) {
        maxWidth = animatedToken.bottomSize.width;
      }
      if (maxHeight > totalHeight) {
        totalHeight = maxHeight;
      }
      totalWidth += maxWidth;
    }
    _totalWidthTween = Tween(begin: _prevTotalWidth, end: totalWidth);
    _totalHeightTween = Tween(begin: _prevTotalHeight, end: totalHeight);
    _prevTotalHeight = totalHeight;
    _prevTotalWidth = totalWidth;
  }

  Size _getSize(String token) {
    return getTextWidgetSize(token, widget.style);
  }

  void _computeTokens() {
    _animatedTokens.clear();
    final bool shorterToLonger = _tokens.length >= _prevTokens.length;
    final List<String> longestTokens = shorterToLonger ? _tokens : _prevTokens;
    for (int i = 0; i < longestTokens.length; i++) {
      final String token = _tokens.tryElementAt(i) ?? '';
      final String prevToken = _prevTokens.tryElementAt(i) ?? '';
      final Direction direction = _directions[token.compareTo(prevToken)];
      String top;
      String center;
      String bottom;
      Size topSize;
      Size centerSize;
      Size bottomSize;

      /// Not empty strings replaces by '', when [shorterToLonger == false]
      if (direction == Direction.bottom) {
        top = token;
        center = prevToken;
        bottom = '';
        topSize = _getSize(top);
        centerSize = _getSize(center.isEmpty ? top : center);
        bottomSize = topSize;
      }
      if (direction == Direction.top) {
        top = '';
        center = prevToken;
        bottom = token;
        topSize = _getSize(bottom);
        centerSize = _getSize(center.isEmpty ? bottom : center);
        bottomSize = topSize;
      }
      if (direction == Direction.none) {
        top = '';
        center = token;
        bottom = '';
        topSize = _getSize(center);
        centerSize = topSize;
        bottomSize = topSize;
      }
      _animatedTokens.add(AnimatedToken(
        top: top,
        center: center,
        bottom: bottom,
        direction: direction,
        topSize: topSize,
        centerSize: centerSize,
        bottomSize: bottomSize,
      ));
    }
  }

  void _computeAnimations() {
    AnimatedToken prevAnimatedToken;
    for (final AnimatedToken animatedToken in _animatedTokens.reversed.toList()) {
      Tween<double> newElementTween;
      Tween<double> oldElementTween;
      if (animatedToken.direction == Direction.none) {
        newElementTween = Tween(begin: 0, end: 0);
        oldElementTween = Tween(begin: 0, end: 0);
      }
      if (animatedToken.direction == Direction.bottom) {
        newElementTween = Tween(begin: -_totalHeightTween.end, end: 0);
        oldElementTween = Tween(begin: 0, end: _totalHeightTween.end);
      }
      if (animatedToken.direction == Direction.top) {
        newElementTween = Tween(begin: _totalHeightTween.end, end: 0);
        oldElementTween = Tween(begin: 0, end: -_totalHeightTween.end);
      }
      animatedToken.axisY = newElementTween.animate(_animationController);
      animatedToken.axisYOld = oldElementTween.animate(_animationController);
      Tween<double> axisXTween = Tween(begin: 0, end: 0);
      if (prevAnimatedToken != null) {
        if (prevAnimatedToken.direction == Direction.none) {
          axisXTween = Tween(
            begin: prevAnimatedToken.centerSize.width + prevAnimatedToken.axisXTween.begin,
            end: prevAnimatedToken.centerSize.width + prevAnimatedToken.axisXTween.end,
          );
        }

        if (prevAnimatedToken.direction == Direction.bottom) {
          axisXTween = Tween(
            begin: prevAnimatedToken.centerSize.width + prevAnimatedToken.axisXTween.begin,
            end: prevAnimatedToken.topSize.width + prevAnimatedToken.axisXTween.end,
          );
        }

        if (prevAnimatedToken.direction == Direction.top) {
          axisXTween = Tween(
            begin: prevAnimatedToken.centerSize.width + prevAnimatedToken.axisXTween.begin,
            end: prevAnimatedToken.bottomSize.width + prevAnimatedToken.axisXTween.end,
          );
        }
      }
      animatedToken.axisX = axisXTween.animate(_animationController);
      animatedToken.axisXTween = axisXTween;
      prevAnimatedToken = animatedToken;
    }
  }

  Text _buildToken(String token) {
    return Text(token, style: widget.style ?? DefaultTextStyle.of(context), maxLines: 1);
  }

  List<Widget> _buildSpans() {
    final List<Widget> topRow = [];
    final List<Widget> centerRow = [];
    final List<Widget> bottomRow = [];
    for (final AnimatedToken animatedToken in _animatedTokens.reversed.toList()) {
      if (animatedToken.direction == Direction.none) {
        centerRow.add(
          Positioned(
            bottom: 0,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.center),
          ),
        );
      }

      if (animatedToken.direction == Direction.top) {
        centerRow.add(
          Positioned(
            bottom: animatedToken.axisYOld.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.center),
          ),
        );

        bottomRow.add(
          Positioned(
            bottom: animatedToken.axisY.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.bottom),
          ),
        );
      }

      if (animatedToken.direction == Direction.bottom) {
        topRow.add(
          Positioned(
            bottom: animatedToken.axisY.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.top),
          ),
        );

        centerRow.add(
          Positioned(
            bottom: animatedToken.axisYOld.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.center),
          ),
        );
      }
    }
    return [...topRow, ...centerRow, ...bottomRow];
  }

  Future<void> _runAnimations() async {
    _animationController.forward(from: 0);
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initTokens();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initTokens();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget child) {
        return SizedBox(
          height: _totalHeightTween.animate(_animationController).value,
          width: _totalWidthTween.animate(_animationController).value,
          child: Stack(
            children: _buildSpans(),
          ),
        );
      },
    );
  }
}
