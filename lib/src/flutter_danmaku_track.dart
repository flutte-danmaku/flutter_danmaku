// 弹幕轨道
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_controller.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_utils.dart';

class FlutterDanmakuTrack {
  UniqueKey id = UniqueKey();

  UniqueKey lastBulletId;

  UniqueKey _bindFixedBulletId; // 绑定的静止定位弹幕ID

  UniqueKey get bindFixedBulletId => _bindFixedBulletId;

  FlutterDanmakuTrack(this._trackHeight, this.offsetTop);

  double offsetTop;

  double _trackHeight;

  double get trackHeight => _trackHeight;

  // 允许注入静止弹幕
  bool get allowInsertFixedBullet => bindFixedBulletId == null;

  void set trackHeight(double height) {
    _trackHeight = height;
  }

  // 卸载静止定位的子弹
  void unloadFixedBulletId() {
    _bindFixedBulletId = null;
  }

  void unloadLastBulletId() {
    lastBulletId = null;
  }

  void loadFixedBulletId(UniqueKey bulletId) {
    assert(bulletId != null);
    _bindFixedBulletId = bulletId;
  }
}

class FlutterDanmakuTrackManager {
  List<FlutterDanmakuTrack> tracks = [];

  double get allTrackHeight {
    if (tracks.isEmpty) return 0;
    return tracks.last.offsetTop + tracks.last.trackHeight;
  }

  // 剩余可用高度
  double get remainderHeight => FlutterDanmakuConfig.showAreaHeight - allTrackHeight;

  // 算轨道相对区域是否溢出
  bool get isTrackOverflowArea => allTrackHeight > FlutterDanmakuConfig.areaSize.height;

  // 补足屏幕内轨道
  void buildTrackFullScreen() {
    Size singleTextSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText('s');
    while (allTrackHeight < (FlutterDanmakuConfig.areaSize.height - singleTextSize.height)) {
      buildTrack(singleTextSize.height);
    }
  }

  FlutterDanmakuTrack buildTrack(double trackHeight) {
    assert(trackHeight > 0);
    FlutterDanmakuTrack track = FlutterDanmakuTrack(trackHeight, allTrackHeight);
    tracks.add(track);
    return track;
  }

  // 重新计算轨道高度和距顶
  void recountTrackOffset() {
    Size currentLabelSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText('s');
    for (int i = 0; i < tracks.length; i++) {
      tracks[i].trackHeight = currentLabelSize.height;
      tracks[i].offsetTop = currentLabelSize.height * i;
      // 把溢出可用区域的轨道之后全部删掉
      if (isTrackOverflowArea) {
        tracks.removeRange(i, tracks.length);
        break;
      }
    }
    buildTrackFullScreen();
  }

  // 是否允许建立新轨道
  bool areaAllowBuildNewTrack(double needBuildTrackHeight) {
    assert(needBuildTrackHeight > 0);
    if (tracks.isEmpty) return true;
    return remainderHeight >= needBuildTrackHeight;
  }

  // 删除轨道上绑定的子弹ID
  void removeTrackBindIdByBulletId(UniqueKey bulletId) {
    int lastBulletIdx;
    lastBulletIdx = tracks.indexWhere((element) => element.lastBulletId == bulletId || element.bindFixedBulletId == bulletId);
    if (lastBulletIdx == -1) return;
    if (tracks[lastBulletIdx].bindFixedBulletId == bulletId) {
      tracks[lastBulletIdx].unloadFixedBulletId();
    } else {
      tracks[lastBulletIdx].unloadLastBulletId();
    }
  }
}
