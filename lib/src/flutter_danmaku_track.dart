// 弹幕轨道
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuTrack {
  UniqueKey id = UniqueKey();

  UniqueKey lastBulletId;

  UniqueKey bindFixedBulletId; // 绑定的静止定位弹幕ID

  FlutterDanmakuTrack(this._trackHeight, this.offsetTop);

  double offsetTop;

  double _trackHeight;

  double get trackHeight => _trackHeight;

  // 允许插入静止弹幕
  bool get allowInsertFixedBullet => bindFixedBulletId == null;

  set trackHeight(double height) {
    _trackHeight = height;
  }
}

class FlutterDanmakuTrackManager {
  static FlutterDanmakuTrack findAvailableTrack(Size bulletSize,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll, FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any}) {
    assert(bulletSize.height > 0);
    assert(bulletSize.width > 0);
    if (position == FlutterDanmakuBulletPosition.any) {
      return _findAllowInsertTrack(bulletSize, bulletType: bulletType);
    } else {
      return _findAllowInsertBottomTrack(bulletSize);
    }
  }

  // 算轨道相对区域是否溢出
  static bool get isTrackOverflowArea => FlutterDanmakuManager.allTrackHeight > FlutterDanmakuConfig.areaSize.height;
  // 算轨道相对可用区域是否溢出
  static bool isEnableTrackOverflowArea(FlutterDanmakuTrack track) => track.offsetTop + track.trackHeight > FlutterDanmakuConfig.showAreaHeight;

  // 查找允许插入的底部轨道
  static FlutterDanmakuTrack _findAllowInsertBottomTrack(Size bulletSize) {
    FlutterDanmakuTrack _track;
    // 在现有轨道里找
    // 底部弹幕 指的是 最后几条轨道 从最底下往上发
    for (int i = FlutterDanmakuManager.tracks.length - 1; i >= FlutterDanmakuManager.tracks.length - 3; i--) {
      // 从当前的弹幕里找 有没有在这个轨道上的
      FlutterDanmakuBulletModel bullet =
          FlutterDanmakuManager.bottomBullets.firstWhere((element) => element.trackId == FlutterDanmakuManager.tracks[i].id, orElse: () => null);
      if (bullet == null) {
        _track = FlutterDanmakuManager.tracks[i];
        break;
      }
    }
    return _track;
  }

  static FlutterDanmakuTrack _findAllowInsertTrack(Size bulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    FlutterDanmakuTrack _track;
    // 在现有轨道里找
    for (int i = 0; i < FlutterDanmakuManager.tracks.length; i++) {
      // 当前轨道溢出可用轨道
      if (FlutterDanmakuTrackManager.isEnableTrackOverflowArea(FlutterDanmakuManager.tracks[i])) break;
      bool allowInsert = FlutterDanmakuTrackManager.trackAllowInsert(FlutterDanmakuManager.tracks[i], bulletSize, bulletType: bulletType);
      if (allowInsert) {
        _track = FlutterDanmakuManager.tracks[i];
        break;
      }
    }
    return _track;
  }

  // 补足屏幕内轨道
  static void buildTrackFullScreen() {
    Size singleTextSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText('s');
    while (FlutterDanmakuManager.allTrackHeight < (FlutterDanmakuConfig.areaSize.height - singleTextSize.height)) {
      buildTrack(singleTextSize.height);
    }
  }

  static FlutterDanmakuTrack buildTrack(double trackHeight) {
    assert(trackHeight > 0);
    FlutterDanmakuTrack track = FlutterDanmakuTrack(trackHeight, FlutterDanmakuManager.allTrackHeight);
    FlutterDanmakuManager.tracks.add(track);
    return track;
  }

  // 重新计算轨道高度和距顶
  static void recountTrackOffset() {
    Size currentLabelSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText('s');
    for (int i = 0; i < FlutterDanmakuManager.tracks.length; i++) {
      FlutterDanmakuManager.tracks[i].trackHeight = currentLabelSize.height;
      FlutterDanmakuManager.tracks[i].offsetTop = currentLabelSize.height * i;
      // 把溢出可用区域的轨道之后全部删掉
      if (FlutterDanmakuTrackManager.isTrackOverflowArea) {
        FlutterDanmakuManager.tracks.removeRange(i, FlutterDanmakuManager.tracks.length);
        break;
      }
    }
    buildTrackFullScreen();
  }

  // 是否允许建立新轨道
  static bool areaAllowBuildNewTrack(double needBuildTrackHeight) {
    assert(needBuildTrackHeight > 0);
    if (FlutterDanmakuManager.tracks.isEmpty) return true;
    return FlutterDanmakuConfig.remainderHeight >= needBuildTrackHeight;
  }

  // 轨道是否允许被插入
  static bool trackAllowInsert(FlutterDanmakuTrack track, Size needInsertBulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    UniqueKey lastBulletId;
    assert(needInsertBulletSize.height > 0);
    assert(needInsertBulletSize.width > 0);
    // 非底部弹幕 超出配置的可视区域 就不可插入
    if (bulletType == FlutterDanmakuBulletType.fixed) return track.allowInsertFixedBullet;
    if (track.lastBulletId == null) return true;
    lastBulletId = track.lastBulletId;
    FlutterDanmakuBulletModel lastBullet = FlutterDanmakuManager.bulletsMap[lastBulletId];
    if (lastBullet == null) return true;
    return !trackInsertBulletHasBump(lastBullet, needInsertBulletSize);
  }

  // 轨道注入子弹是否会碰撞
  static bool trackInsertBulletHasBump(FlutterDanmakuBulletModel trackLastBullet, Size needInsertBulletSize) {
    // 是否离开了右边的墙壁
    if (!trackLastBullet.allOutRight) return true;
    double willInsertBulletEveryFramerateRunDistance = FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width);
    // 要插入的节点速度比上一个快
    if (willInsertBulletEveryFramerateRunDistance > trackLastBullet.everyFrameRunDistance) {
      // 是否会追尾
      // 将要插入的弹幕全部离开减去上一个弹幕宽度需要的时间
      double willInsertBulletLeaveScreenRemainderTime =
          FlutterDanmakuBulletUtils.remainderTimeLeaveScreen(0, 0, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width));
      return trackLastBullet.leaveScreenRemainderTime > willInsertBulletLeaveScreenRemainderTime;
    } else {
      return false;
    }
  }

  static void removeTrackByBulletId(UniqueKey bulletId) {
    int lastBulletIdx;
    lastBulletIdx = FlutterDanmakuManager.tracks.indexWhere((element) => element.lastBulletId == bulletId || element.bindFixedBulletId == bulletId);
    if (lastBulletIdx == -1) return;
    if (FlutterDanmakuManager.tracks[lastBulletIdx].bindFixedBulletId == bulletId) {
      FlutterDanmakuManager.tracks[lastBulletIdx].bindFixedBulletId = null;
    } else {
      FlutterDanmakuManager.tracks[lastBulletIdx].lastBulletId = null;
    }
  }
}
