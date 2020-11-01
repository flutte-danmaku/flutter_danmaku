// 弹幕轨道

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

enum FlutterDanmakuTrackType { scroll, fixed }

class FlutterDanmakuTrack {
  UniqueKey id;

  UniqueKey lastBulletId;

  double offsetTop;

  double trackHeight;

  FlutterDanmakuTrackType trackType = FlutterDanmakuTrackType.scroll;

  FlutterDanmakuTrack(this.trackHeight, this.offsetTop);
}

class FlutterDanmakuTrackManager {
  static FlutterDanmakuTrack findAvailableTrack(Size bulletSize) {
    FlutterDanmakuTrack _track;
    // 轨道列表为空
    if (FlutterDanmakuManager.tracks.isEmpty) return null;
    // 在现有轨道里找
    for (int i = 0; i < FlutterDanmakuManager.tracks.length; i++) {
      // 轨道是否溢出工作区
      bool isTrackOverflow = FlutterDanmakuTrackManager.isTrackOverflowArea(FlutterDanmakuManager.tracks[i]);
      if (isTrackOverflow) break;
      bool allowInsert = FlutterDanmakuTrackManager.trackAllowInsert(FlutterDanmakuManager.tracks[i], bulletSize);
      if (allowInsert) {
        _track = FlutterDanmakuManager.tracks[i];
        break;
      }
    }
    return _track;
  }

  static FlutterDanmakuTrack buildTrack(double trackHeight) {
    double trackOffsetTop = 0;
    if (FlutterDanmakuManager.tracks.isNotEmpty) {
      trackOffsetTop = FlutterDanmakuManager.tracks.last.offsetTop + FlutterDanmakuManager.tracks.last.trackHeight;
    }
    FlutterDanmakuTrack track = FlutterDanmakuTrack(trackHeight, trackOffsetTop);
    FlutterDanmakuManager.tracks.add(track);
    return track;
  }

  // 重新计算轨道高度和距顶
  static void recountTrackOffset() {
    Size currentLabelSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText('s');
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
    if (FlutterDanmakuManager.tracks.isEmpty) return true;
    double currentAllTrackHeight = FlutterDanmakuManager.tracks.last.offsetTop + FlutterDanmakuManager.tracks.last.trackHeight;
    return FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent - currentAllTrackHeight >= needBuildTrackHeight;
  }

  // 轨道是否允许被插入
  static bool trackAllowInsert(FlutterDanmakuTrack track, Size needInsertBulletSize) {
    if (track.lastBulletId == null) return true;
    UniqueKey lastBulletId = track.lastBulletId;
    FlutterDanmakuBulletModel lastBullet = FlutterDanmakuManager.bullets[lastBulletId];
    // 是否离开了右边的墙壁
    bool hasAllOutRight = lastBullet.runDistance > lastBullet.bulletSize.width;
    if (!hasAllOutRight) return false;
    double willInsertBulletEveryFramerateRunDistance = FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width);
    // 要插入的节点速度比上一个快
    if (willInsertBulletEveryFramerateRunDistance > lastBullet.everyFrameRunDistance) {
      // 是否会追尾
      // 上一个弹幕全部离开需要的时间
      double lastLeaveScreenRemainderTime =
          FlutterDanmakuBulletUtils.remainderTimeLeaveScreen(lastBullet.runDistance, lastBullet.bulletSize.width, lastBullet.everyFrameRunDistance);
      // 将要插入的弹幕全部离开减去上一个弹幕宽度需要的时间
      double willInsertBulletLeaveScreenRemainderTime =
          FlutterDanmakuBulletUtils.remainderTimeLeaveScreen(0, 0, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width));
      return !(lastLeaveScreenRemainderTime > willInsertBulletLeaveScreenRemainderTime);
    } else {
      return true;
    }
  }

  // 轨道是否溢出
  static bool isTrackOverflowArea(FlutterDanmakuTrack track) {
    return (track.offsetTop + track.trackHeight) > FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent;
  }
}
