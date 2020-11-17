import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuConfig {
  static Duration bulletBaseShowDuration = const Duration(seconds: 3);
  static double bulletLableSize = 14;

  static double bulletRate = 1.0;

  static Size areaSize = Size(0, 0);
  // 展示区域百分比
  static double showAreaPercent = 1.0;

  static double opacity = 1.0;

  static bool pause = false;

  static const Color defaultColor = Colors.black;

  static int baseRunDistance = 1;

  static int everyFramerateRunDistanceScale = 150;

  // 展示高度
  static double get showAreaHeight => FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent;

  // 剩余可用高度
  static double get remainderHeight => FlutterDanmakuConfig.showAreaHeight - FlutterDanmakuManager.allTrackHeight;
}
