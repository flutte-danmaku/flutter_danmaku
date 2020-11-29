import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_controller.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';

class FlutterDanmakuBulletManager {
  Map<UniqueKey, FlutterDanmakuBulletModel> _bullets = {};

  List<FlutterDanmakuBulletModel> get bullets => _bullets.values.toList();
  // 返回所有的底部弹幕
  List<FlutterDanmakuBulletModel> get bottomBullets => bullets.where((element) => element.position == FlutterDanmakuBulletPosition.bottom).toList();
  List<UniqueKey> get bulletKeys => _bullets.keys.toList();
  Map<UniqueKey, FlutterDanmakuBulletModel> get bulletsMap => _bullets;

  // 记录子弹到map中
  recordBullet(FlutterDanmakuBulletModel bullet) {
    _bullets[bullet.id] = bullet;
  }

  void removeBulletByKey(UniqueKey id) => _bullets.remove(id);

  void removeAllBullet() {
    _bullets = {};
  }

  // 初始化一个子弹
  FlutterDanmakuBulletModel initBullet(String text, UniqueKey trackId, Size bulletSize, double offsetY,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll,
      FlutterDanmakuBulletPosition position,
      Color color,
      UniqueKey prevBulletId,
      int offsetMS = 0,
      Widget Function(Text) builder}) {
    assert(bulletSize.height > 0);
    assert(bulletSize.width > 0);
    assert(offsetY >= 0);
    UniqueKey bulletId = UniqueKey();
    FlutterDanmakuBulletModel bullet = FlutterDanmakuBulletModel(
        color: color,
        id: bulletId,
        trackId: trackId,
        text: text,
        position: position,
        bulletSize: bulletSize,
        offsetY: offsetY,
        offsetMS: offsetMS,
        prevBulletId: prevBulletId,
        bulletType: bulletType,
        builder: builder);
    // 记录到表上
    recordBullet(bullet);
    return bullet;
  }
}
