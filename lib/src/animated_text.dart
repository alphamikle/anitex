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
import 'dart:ui';

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
    this.duration = const Duration(milliseconds: 350),
    this.reversed = false,
    this.positionCurve = Curves.decelerate,
    this.opacityToCurve = Curves.easeInQuart,
    this.opacityFromCurve = Curves.easeOutQuart,
    this.textAlign = TextAlign.left,
    this.useOpacity = true,
  })  : assert(duration != null),
        assert(text != null),
        assert(positionCurve != null && opacityFromCurve != null && opacityToCurve != null),
        super(key: key);

  /// Text, which will we printed
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

  /// Curve, which describes how is switching a tokens in the words
  final Curve positionCurve;

  /// Curve, which describes how is changing opacity of new tokens on their switching
  final Curve opacityToCurve;

  /// Curve, which describes how is changing opacity of old tokens on their switching
  final Curve opacityFromCurve;

  /// Use opacity while tokens switching
  final bool useOpacity;

  /// Text align for not animated widget
  final TextAlign textAlign;

  @override
  _AnimatedTextState createState() {
    return _AnimatedTextState();
  }
}

class _AnimatedTextState extends State<AnimatedText> with TickerProviderStateMixin {
  final List<String> _tokens = [];
  final List<String> _prevTokens = [];
  final List<AnimatedToken> _animatedTokens = [];

  TextStyle get style => widget.style ?? DefaultTextStyle.of(context).style;
  AnimationController _animationController;
  double _prevTotalHeight = 0;
  double _prevTotalWidth = 0;
  Tween<double> _totalWidthTween = Tween(begin: 0, end: 0);
  Tween<double> _totalHeightTween = Tween(begin: 0, end: 0);
  bool _wasChanged = false;

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
    return getTextWidgetSize(token, style);
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
      Tween<double> opacityTween;
      Tween<double> opacityTweenOld;
      if (animatedToken.direction == Direction.none) {
        newElementTween = Tween(begin: 0, end: 0);
        oldElementTween = Tween(begin: 0, end: 0);
        opacityTween = Tween(begin: 1, end: 1);
        opacityTweenOld = Tween(begin: 1, end: 1);
      }
      if (animatedToken.direction == Direction.bottom) {
        newElementTween = Tween(begin: -_totalHeightTween.end, end: 0);
        oldElementTween = Tween(begin: 0, end: _totalHeightTween.end);
        opacityTween = Tween(begin: 0, end: 1);
        opacityTweenOld = Tween(begin: 1, end: 0);
      }
      if (animatedToken.direction == Direction.top) {
        newElementTween = Tween(begin: _totalHeightTween.end, end: 0);
        oldElementTween = Tween(begin: 0, end: -_totalHeightTween.end);
        opacityTween = Tween(begin: 0, end: 1);
        opacityTweenOld = Tween(begin: 1, end: 0);
      }
      final Animation<double> curvedPositionAnimation = CurvedAnimation(curve: widget.positionCurve, parent: _animationController);
      final Animation<double> curvedOpacityAnimation = CurvedAnimation(curve: widget.opacityToCurve, parent: _animationController);
      final Animation<double> curvedOpacityAnimationOld = CurvedAnimation(curve: widget.opacityFromCurve, parent: _animationController);

      animatedToken.axisY = newElementTween.animate(curvedPositionAnimation);
      animatedToken.axisYOld = oldElementTween.animate(curvedPositionAnimation);
      animatedToken.opacity = opacityTween.animate(curvedOpacityAnimation);
      animatedToken.opacityOld = opacityTweenOld.animate(curvedOpacityAnimationOld);
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

  Widget _buildToken(String token, double opacity) {
    final Text text = Text(token, style: style, maxLines: 1);
    if (widget.useOpacity) {
      return Opacity(
        opacity: opacity,
        child: text,
      );
    }
    return text;
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
            child: _buildToken(animatedToken.center, 1),
          ),
        );
      }

      if (animatedToken.direction == Direction.top) {
        centerRow.add(
          Positioned(
            bottom: animatedToken.axisYOld.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.center, animatedToken.opacityOld.value),
          ),
        );

        bottomRow.add(
          Positioned(
            bottom: animatedToken.axisY.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.bottom, animatedToken.opacity.value),
          ),
        );
      }

      if (animatedToken.direction == Direction.bottom) {
        topRow.add(
          Positioned(
            bottom: animatedToken.axisY.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.top, animatedToken.opacity.value),
          ),
        );

        centerRow.add(
          Positioned(
            bottom: animatedToken.axisYOld.value,
            right: animatedToken.axisX.value,
            child: _buildToken(animatedToken.center, animatedToken.opacityOld.value),
          ),
        );
      }
    }
    return [...topRow, ...centerRow, ...bottomRow];
  }

  Future<void> _runAnimations() async {
    _animationController.forward(from: 0);
  }

  Alignment _getStackAlignment() {
    switch (widget.textAlign) {
      case TextAlign.start:
        {
          return Alignment.centerLeft;
        }
      case TextAlign.center:
        {
          return Alignment.center;
        }
      case TextAlign.right:
        {
          return Alignment.centerRight;
        }
      case TextAlign.left:
        {
          return Alignment.centerLeft;
        }
      case TextAlign.end:
        {
          return Alignment.centerRight;
        }
      default:
        {
          throw Exception('${widget.textAlign} not allowed to use in $AnimatedText widget');
        }
    }
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _wasChanged = true;
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
    return _wasChanged
        ? AnimatedBuilder(
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
          )
        : SizedBox(
            height: _getSize(widget.text).height,
            width: _getSize(widget.text).width,
            child: Stack(
              alignment: _getStackAlignment(),
              children: [
                Text(
                  widget.text,
                  style: widget.style,
                  maxLines: 1,
                  textAlign: widget.textAlign,
                ),
              ],
            ),
          );
  }
}
