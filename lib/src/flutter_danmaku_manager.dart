import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';

class FlutterDanmakuManager {
  static int framerate = 60;
  static int unitTimer = 1000 ~/ FlutterDanmakuManager.framerate;
  static List<FlutterDanmakuTrack> tracks = [];
  static Map<UniqueKey, FlutterDanmakuBulletModel> bullets = {};

  Timer timer;

  void run(Function callBack) {
    timer = Timer(Duration(milliseconds: unitTimer), () {
      // 防止数据在迭代时删除
      Map<UniqueKey, FlutterDanmakuBulletModel> bulletsCopy = Map.from(FlutterDanmakuManager.bullets);
      bulletsCopy.forEach((UniqueKey key, FlutterDanmakuBulletModel value) => nextFramerate(value));
      callBack();
      run(callBack);
    });
  }

  nextFramerate(FlutterDanmakuBulletModel bulletModel) {
    bulletModel.runDistance += bulletModel.everyFrameRunDistance * FlutterDanmakuConfig.bulletRate;
    if (bulletModel.runDistance > bulletModel.maxRunDistance) {
      FlutterDanmakuBulletUtils.removeBulletById(bulletModel.id);
    }
  }

  void addDanmaku(BuildContext context, String text) {
    // 先获取子弹尺寸
    Size bulletSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText(text);
    // 寻找可用的轨道
    FlutterDanmakuTrack track = FlutterDanmakuTrackManager.findAvailableTrack(bulletSize);
    // 如果没有找到可用的轨道
    if (track == null) {
      // 是否允许新建轨道
      bool allowNewTrack = FlutterDanmakuTrackManager.areaAllowBuildNewTrack(bulletSize.height);
      if (!allowNewTrack) return null;
      track = FlutterDanmakuTrackManager.buildTrack(bulletSize.height);
    }
    FlutterDanmakuBulletModel bullet = FlutterDanmakuBulletUtils.initBullet(text, track.id, bulletSize, track.offsetTop);
    track.lastBulletId = bullet.id;
    FlutterDanmakuBulletUtils.buildBulletToScreen(context, bullet);
  }
}
