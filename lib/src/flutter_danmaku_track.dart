// 弹幕轨道

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuTrack {
  UniqueKey id = UniqueKey();

  UniqueKey lastBulletId;

  UniqueKey bindFixedBulletId; // 绑定的静止定位弹幕ID

  double offsetTop;

  double trackHeight;

  FlutterDanmakuTrack(this.trackHeight, this.offsetTop);
}

class FlutterDanmakuTrackManager {
  static FlutterDanmakuTrack findAvailableTrack(Size bulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    assert(bulletSize.height > 0);
    assert(bulletSize.width > 0);
    FlutterDanmakuTrack _track;
    // 轨道列表为空
    if (FlutterDanmakuManager.tracks.isEmpty) return null;
    // 在现有轨道里找
    for (int i = 0; i < FlutterDanmakuManager.tracks.length; i++) {
      // 轨道是否溢出工作区
      bool isTrackOverflow = FlutterDanmakuTrackManager.isTrackOverflowArea(FlutterDanmakuManager.tracks[i]);
      if (isTrackOverflow) break;
      bool allowInsert = FlutterDanmakuTrackManager.trackAllowInsert(FlutterDanmakuManager.tracks[i], bulletSize, bulletType: bulletType);
      if (allowInsert) {
        _track = FlutterDanmakuManager.tracks[i];
        break;
      }
    }
    return _track;
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
      FlutterDanmakuManager.tracks[i].offsetTop = i * currentLabelSize.height;
      FlutterDanmakuManager.tracks[i].trackHeight = currentLabelSize.height;
      // 把溢出的轨道之后全部删掉
      if (FlutterDanmakuTrackManager.isTrackOverflowArea(FlutterDanmakuManager.tracks[i])) {
        FlutterDanmakuManager.tracks.removeRange(i, FlutterDanmakuManager.tracks.length);
        break;
      }
    }
  }

  // 是否允许建立新轨道
  static bool areaAllowBuildNewTrack(double needBuildTrackHeight) {
    assert(needBuildTrackHeight > 0);
    if (FlutterDanmakuManager.tracks.isEmpty) return true;
    return FlutterDanmakuConfig.showAreaHeight - FlutterDanmakuManager.allTrackHeight >= needBuildTrackHeight;
  }

  // 轨道是否允许被插入
  static bool trackAllowInsert(FlutterDanmakuTrack track, Size needInsertBulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    UniqueKey lastBulletId;
    assert(needInsertBulletSize.height > 0);
    assert(needInsertBulletSize.width > 0);
    if (bulletType == FlutterDanmakuBulletType.fixed) return track.bindFixedBulletId == null;
    if (track.lastBulletId == null) return true;
    lastBulletId = track.lastBulletId;
    FlutterDanmakuBulletModel lastBullet = FlutterDanmakuManager.bulletsMap[lastBulletId];
    if (lastBullet == null) return true;
    // 是否离开了右边的墙壁
    if (!lastBullet.allOutRight) return false;
    return trackInsertBulletHasBump(lastBullet, needInsertBulletSize);
  }

  // 轨道注入子弹是否为碰撞
  static bool trackInsertBulletHasBump(FlutterDanmakuBulletModel trackLastBullet, Size needInsertBulletSize) {
    double willInsertBulletEveryFramerateRunDistance = FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width);
    // 要插入的节点速度比上一个快
    if (willInsertBulletEveryFramerateRunDistance > trackLastBullet.everyFrameRunDistance) {
      // 是否会追尾
      // 将要插入的弹幕全部离开减去上一个弹幕宽度需要的时间
      double willInsertBulletLeaveScreenRemainderTime =
          FlutterDanmakuBulletUtils.remainderTimeLeaveScreen(0, 0, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width));
      return !(trackLastBullet.leaveScreenRemainderTime > willInsertBulletLeaveScreenRemainderTime);
    } else {
      return true;
    }
  }

  // 轨道是否溢出
  static bool isTrackOverflowArea(FlutterDanmakuTrack track) {
    return (track.offsetTop + track.trackHeight) > FlutterDanmakuConfig.showAreaHeight;
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
