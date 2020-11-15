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

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'direction.dart';

class AnimatedToken {
  AnimatedToken({
    @required this.top,
    @required this.center,
    @required this.bottom,
    @required this.direction,
    @required this.topSize,
    @required this.centerSize,
    @required this.bottomSize,
    this.axisY,
    this.axisYOld,
    this.axisX,
    this.axisXTween,
  });

  final String top;
  final String center;
  final String bottom;
  final Direction direction;

  final Size topSize;
  final Size centerSize;
  final Size bottomSize;

  /// Animation in Y axis for new letter
  Animation<double> axisY;

  /// Animation in Y axis for old letter
  Animation<double> axisYOld;

  /// Animation in X axis for the same letter (old == new)
  Animation<double> axisX;
  Tween<double> axisXTween;

  @override
  String toString() => '''AnimatedToken {
    top: $top -> $topSize
    center: $center -> $centerSize
    bottom: $bottom -> $bottomSize
    direction: $direction
  }''';
}
