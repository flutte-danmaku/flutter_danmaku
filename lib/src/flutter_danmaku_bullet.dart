// 弹幕子弹
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

enum FlutterDanmakuBulletType { scroll, fixed }
enum FlutterDanmakuBulletPosition { any, bottom }

class FlutterDanmakuBulletModel {
  UniqueKey id;
  UniqueKey trackId;
  Size bulletSize;
  String text;
  double offsetY;
  double _runDistance = 0;
  double everyFrameRunDistance;
  Color color = Colors.black;
  FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any;

  Widget Function(Text) builder;

  FlutterDanmakuBulletType bulletType;

  /// 子弹的x轴位置
  double get offsetX =>
      bulletType == FlutterDanmakuBulletType.scroll ? _runDistance - bulletSize.width : FlutterDanmakuConfig.areaSize.width / 2 - (bulletSize.width / 2);

  /// 子弹最大可跑距离 子弹宽度+墙宽度
  double get maxRunDistance => bulletSize.width + FlutterDanmakuConfig.areaSize.width;

  /// 子弹整体脱离右边墙壁
  bool get allOutRight => _runDistance > bulletSize.width;

  /// 子弹整体离开屏幕
  bool get allOutLeave => _runDistance > maxRunDistance;

  /// 子弹当前执行的距离
  double get runDistance => _runDistance;

  /// 剩余离开的距离
  double get remanderDistance => needRunDistace - runDistance;

  /// 需要走的距离
  double get needRunDistace => FlutterDanmakuConfig.areaSize.width + bulletSize.width;

  /// 离开屏幕剩余需要的时间
  double get leaveScreenRemainderTime => remanderDistance / everyFrameRunDistance;

  /// 子弹执行下一帧
  void runNextFrame() {
    _runDistance += everyFrameRunDistance * FlutterDanmakuConfig.bulletRate;
  }

  FlutterDanmakuBulletModel(
      {this.id,
      this.trackId,
      this.text,
      this.bulletSize,
      this.offsetY,
      this.bulletType = FlutterDanmakuBulletType.scroll,
      this.color,
      this.builder,
      this.position}) {
    everyFrameRunDistance = FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletSize.width);
  }
}

class FlutterDanmakuBullet extends StatelessWidget {
  FlutterDanmakuBullet(this.danmakuId, this.text, {this.color = Colors.black});

  String text;
  UniqueKey danmakuId;
  Color color;

  GlobalKey key;

  /// 构建文字
  Widget buildText() {
    Text textWidget = Text(
      text,
      style: TextStyle(
        fontSize: FlutterDanmakuConfig.bulletLableSize,
        color: color.withOpacity(FlutterDanmakuConfig.opacity),
      ),
    );
    if (FlutterDanmakuManager.bulletsMap[danmakuId] != null && FlutterDanmakuManager.bulletsMap[danmakuId].builder != null) {
      return FlutterDanmakuManager.bulletsMap[danmakuId].builder(textWidget);
    }
    return textWidget;
  }

  /// 构建描边文字
  Widget buildStrokeText() {
    Text textWidget = Text(
      text,
      style: TextStyle(
        fontSize: FlutterDanmakuConfig.bulletLableSize,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.white.withOpacity(FlutterDanmakuConfig.opacity),
      ),
    );
    if (FlutterDanmakuManager.bulletsMap[danmakuId] != null && FlutterDanmakuManager.bulletsMap[danmakuId].builder != null) {
      return FlutterDanmakuManager.bulletsMap[danmakuId].builder(textWidget);
    }
    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        buildStrokeText(),
        // Solid text as fill.
        buildText()
      ],
    );
  }
}
