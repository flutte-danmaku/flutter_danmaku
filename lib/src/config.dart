import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
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

  /// 弹幕场景基于子组件高度的偏移量。是由于子组件高度不一定能整除轨道高度 为了居中展示 需要有一个偏移量
  static double areaOfChildOffsetY = 0;

  // 展示高度
  static double get showAreaHeight => FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent;

  // 剩余可用高度
  static double get remainderHeight => FlutterDanmakuConfig.showAreaHeight - FlutterDanmakuManager.allTrackHeight;

  /// 获取弹幕场景基于子组件高度的偏移量。为了居中展示
  static double getAreaOfChildOffsetY({Size textSize}) {
    Size _textSize = textSize ?? FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText('s');
    return (FlutterDanmakuConfig.areaSize.height % _textSize.height) / 2;
  }
}
