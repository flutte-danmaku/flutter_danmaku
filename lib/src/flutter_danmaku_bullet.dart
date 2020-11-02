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

  FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll;

  double get maxRunDistance => bulletSize.width + FlutterDanmakuConfig.areaSize.width;

  FlutterDanmakuBulletModel({this.id, this.trackId, this.text, this.bulletSize, this.offsetY, this.everyFrameRunDistance, this.bulletType});
}

class FlutterDanmakuBullet extends StatelessWidget {
  FlutterDanmakuBullet(this.danmakuId, this.text);

  String text;
  UniqueKey danmakuId;

  GlobalKey key;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: key,
      style: TextStyle(fontSize: FlutterDanmakuConfig.bulletLableSize, color: Colors.blueGrey),
    );
  }
}
