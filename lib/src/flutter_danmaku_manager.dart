import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';

enum AddBulletResCode { success, noSpace }

class AddBulletResBody {
  AddBulletResCode code = AddBulletResCode.success;
  String message = '';
  dynamic data;
  AddBulletResBody(this.code, {this.message, this.data});
}

class FlutterDanmakuManager {
  static int framerate = 60;
  static int unitTimer = 1000 ~/ FlutterDanmakuManager.framerate;
  static List<FlutterDanmakuTrack> tracks = [];
  static Map<UniqueKey, FlutterDanmakuBulletModel> _bullets = {};

  static List<FlutterDanmakuBulletModel> get bullets => _bullets.values.toList();
  static List<UniqueKey> get bulletKeys => _bullets.keys.toList();
  static Map<UniqueKey, FlutterDanmakuBulletModel> get bulletsMap => _bullets;
  static double get allTrackHeight {
    if (tracks.isEmpty) return 0;
    return tracks.last.offsetTop + tracks.last.trackHeight;
  }

  // 记录子弹到map中
  static recordBullet(FlutterDanmakuBulletModel bullet) {
    _bullets[bullet.id] = bullet;
  }

  static bool hasBulletKey(UniqueKey id) => _bullets.containsKey(id);

  static void removeBulletByKey(UniqueKey id) => _bullets.remove(id);

  static void removeAllBullet() {
    _bullets = {};
  }

  Timer timer;

  void dispose() {
    timer?.cancel();
  }

  void run(Function callBack) {
    timer = Timer.periodic(Duration(milliseconds: unitTimer), (Timer timer) {
      // 暂停不执行
      if (!FlutterDanmakuConfig.pause) {
        for (int i = FlutterDanmakuManager.bullets.length - 1; i >= 0; i--) {
          _nextFramerate(FlutterDanmakuManager.bullets[i]);
        }
        callBack();
      }
    });
  }

  // 成功返回AddBulletResBody.data为bulletId
  AddBulletResBody addDanmaku(BuildContext context, String text,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll,
      Color color,
      FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any}) {
    assert(text.isNotEmpty);
    // 先获取子弹尺寸
    Size bulletSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText(text);
    // 寻找可用的轨道
    FlutterDanmakuTrack track = FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, bulletType: bulletType, position: position);
    // 如果没有找到可用的轨道
    if (track == null)
      return AddBulletResBody(
        AddBulletResCode.noSpace,
      );
    FlutterDanmakuBulletModel bullet = FlutterDanmakuBulletUtils.initBullet(text, track.id, bulletSize, track.offsetTop, bulletType: bulletType, color: color);
    if (bulletType == FlutterDanmakuBulletType.scroll) {
      track.lastBulletId = bullet.id;
    } else {
      track.bindFixedBulletId = bullet.id;
    }
    FlutterDanmakuBulletUtils.buildBulletToScreen(context, bullet);
    return AddBulletResBody(AddBulletResCode.success, data: bullet.id);
  }

  _nextFramerate(FlutterDanmakuBulletModel bulletModel) {
    bulletModel.runNextFrame();
    if (bulletModel.allOutLeave) {
      FlutterDanmakuBulletUtils.removeBulletById(bulletModel.id, bulletType: bulletModel.bulletType);
    }
  }
}
