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

/// Describes a one cell of animated text:
/// We change "100" to "250"
/// Then, we have 3 animated tokens in not reversed flow:
///  1th  2th 3th
/// | 2 | 5 | _ |
/// | 1 | 0 | 0 |
/// | _ | _ | _ |
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
    this.opacity,
    this.opacityOld,
  });

  /// | top |
  /// | center |
  /// | bottom |
  final String top;

  /// | top |
  /// | center |
  /// | bottom |
  final String center;

  /// | top |
  /// | center |
  /// | bottom |
  final String bottom;

  /// Describes in which direction this token will move
  final Direction direction;

  /// Size of top letter
  final Size topSize;

  /// Size of center letter
  final Size centerSize;

  /// Size of bottom letter
  final Size bottomSize;

  /// Animation in Y axis for new letter
  Animation<double> axisY;

  /// Animation in Y axis for old letter
  Animation<double> axisYOld;

  /// Animation in X axis for the same letter (old == new)
  Animation<double> axisX;

  Tween<double> axisXTween;

  /// If token is Direction.bottom - opacity ween will be from
  /// If Direction.top - 0 -> 1
  Animation<double> opacity;

  /// If token is Direction.bottom - opacity ween will be from
  /// If Direction.top - 0 -> 1
  Animation<double> opacityOld;

  @override
  String toString() => '''AnimatedToken {
    top: $top -> $topSize
    center: $center -> $centerSize
    bottom: $bottom -> $bottomSize
    direction: $direction
  }''';
}
