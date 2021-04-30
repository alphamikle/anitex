import 'package:flutter/animation.dart';
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
    required this.top,
    required this.center,
    required this.bottom,
    required this.direction,
    required this.topSize,
    required this.centerSize,
    required this.bottomSize,
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
  late Animation<double> axisY;

  /// Animation in Y axis for old letter
  late Animation<double> axisYOld;

  /// Animation in X axis for the same letter (old == new)
  late Animation<double> axisX;

  late Tween<double> axisXTween;

  /// If token is Direction.bottom - opacity ween will be from
  /// If Direction.top - 0 -> 1
  late Animation<double> opacity;

  /// If token is Direction.bottom - opacity ween will be from
  /// If Direction.top - 0 -> 1
  late Animation<double> opacityOld;

  @override
  String toString() => '''AnimatedToken {
    top: $top -> $topSize
    center: $center -> $centerSize
    bottom: $bottom -> $bottomSize
    direction: $direction
  }''';
}
