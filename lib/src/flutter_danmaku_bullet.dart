// 弹幕子弹
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

enum FlutterDanmakuBulletType { scroll, fixed }

class FlutterDanmakuBulletModel {
  UniqueKey id;
  UniqueKey trackId;
  Size bulletSize;
  String text;
  double offsetY;
  double runDistance = 0;
  double everyFrameRunDistance = 1;
  Color color = Colors.black;

  FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll;

  double get maxRunDistance => bulletSize.width + FlutterDanmakuConfig.areaSize.width;

  FlutterDanmakuBulletModel({this.id, this.trackId, this.text, this.bulletSize, this.offsetY, this.everyFrameRunDistance, this.bulletType, this.color});
}

class FlutterDanmakuBullet extends StatelessWidget {
  FlutterDanmakuBullet(this.danmakuId, this.text, {this.color});

  String text;
  UniqueKey danmakuId;
  Color color = Colors.black;

  GlobalKey key;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
            fontSize: FlutterDanmakuConfig.bulletLableSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = Colors.white,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: FlutterDanmakuConfig.bulletLableSize,
            color: color.withOpacity(FlutterDanmakuConfig.opacity),
          ),
        ),
      ],
    );
  }
}
