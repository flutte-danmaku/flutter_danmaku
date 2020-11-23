import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_render.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_utils.dart';

enum AddBulletResCode { success, noSpace }

class AddBulletResBody {
  AddBulletResCode code = AddBulletResCode.success;
  String message = '';
  dynamic data;
  AddBulletResBody(this.code, {this.message, this.data});
}

class FlutterDanmakuController {
  FlutterDanmakuTrackManager _trackManager = FlutterDanmakuTrackManager();
  FlutterDanmakuBulletManager _bulletManager = FlutterDanmakuBulletManager();
  FlutterDanmakuRenderManager _renderManager = FlutterDanmakuRenderManager();

  BuildContext context;

  List<FlutterDanmakuTrack> get tracks => _trackManager.tracks;
  List<FlutterDanmakuBulletModel> get bullets => _bulletManager.bullets;

  Function setState;

  /// 是否暂停
  bool get isPause => FlutterDanmakuConfig.pause;

  /// 是否初始化过
  bool get inited => _inited;
  bool _inited = false;

  /// 清除定时器
  void dispose() => _renderManager.dispose();

  // 成功返回AddBulletResBody.data为bulletId
  AddBulletResBody addDanmaku(String text,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll,
      Color color,
      Widget Function(Text) builder,
      FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any}) {
    assert(text.isNotEmpty);
    // 先获取子弹尺寸
    Size bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(text);
    // 寻找可用的轨道
    FlutterDanmakuTrack track = _findAvailableTrack(bulletSize, bulletType: bulletType, position: position);
    // 如果没有找到可用的轨道
    if (track == null)
      return AddBulletResBody(
        AddBulletResCode.noSpace,
      );
    FlutterDanmakuBulletModel bullet =
        _bulletManager.initBullet(text, track.id, bulletSize, track.offsetTop, position: position, bulletType: bulletType, color: color, builder: builder);
    if (bulletType == FlutterDanmakuBulletType.scroll) {
      track.lastBulletId = bullet.id;
    } else {
      // 底部弹幕 不记录到轨道上
      // 查询是否可注入弹幕时 底部弹幕 和普通被注入到底部的静止弹幕可重叠
      if (position == FlutterDanmakuBulletPosition.any) {
        track.loadFixedBulletId(bullet.id);
      }
    }
    return AddBulletResBody(AddBulletResCode.success, data: bullet.id);
  }

  void init({Size size}) {
    resizeArea(size: size);
    _trackManager.buildTrackFullScreen();
    if (_inited) return;
    _inited = true;
    _run();
  }

  void removeAllBullet() {
    _bulletManager.removeAllBullet();
  }

  // 暂停
  void pause() {
    FlutterDanmakuConfig.pause = true;
  }

  // 播放
  void play() {
    FlutterDanmakuConfig.pause = false;
  }

  // 修改弹幕速率
  void changeRate(double rate) {
    assert(rate > 0);
    FlutterDanmakuConfig.bulletRate = rate;
  }

  void setBulletTapCallBack(Function(FlutterDanmakuBulletModel) cb) {
    FlutterDanmakuConfig.bulletTapCallBack = cb;
  }

  void changeOpacity(double opacity) {
    assert(opacity <= 1);
    assert(opacity >= 0);
    FlutterDanmakuConfig.opacity = opacity;
  }

  // 修改文字大小
  void changeLableSize(int size) {
    assert(size > 0);
    FlutterDanmakuConfig.bulletLableSize = size.toDouble();
    FlutterDanmakuConfig.areaOfChildOffsetY = FlutterDanmakuConfig.getAreaOfChildOffsetY();
    _trackManager.recountTrackOffset();
    _recountBulletsOffset();
  }

  // 改变视图尺寸后调用，比如全屏
  void resizeArea({Size size}) {
    FlutterDanmakuConfig.areaSize = size ?? context.size;
    FlutterDanmakuConfig.areaOfChildOffsetY = FlutterDanmakuConfig.getAreaOfChildOffsetY();
    _trackManager.recountTrackOffset();
    if (FlutterDanmakuConfig.pause) {
      _renderManager.renderNextFramerate(_bulletManager.bulletsMap, _allOutLeaveCallBack);
    }
  }

  // 修改弹幕最大可展示场景的百分比
  void changeShowArea(double percent) {
    assert(percent <= 1);
    assert(percent >= 0);
    FlutterDanmakuConfig.showAreaPercent = percent;
    _trackManager.buildTrackFullScreen();
  }

  void delBulletById(UniqueKey bulletId) {
    _bulletManager.removeBulletByKey(bulletId);
    _trackManager.removeTrackBindIdByBulletId(bulletId);
  }

  void _allOutLeaveCallBack(UniqueKey bulletId) {
    _bulletManager.bulletsMap.remove(bulletId);
    _trackManager.removeTrackBindIdByBulletId(bulletId);
  }

  void _run() => _renderManager.run(() {
        _renderManager.renderNextFramerate(_bulletManager.bulletsMap, _allOutLeaveCallBack);
      }, setState);

  // 获取允许注入的轨道
  FlutterDanmakuTrack _findAllowInsertTrack(Size bulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    FlutterDanmakuTrack _track;
    // 在现有轨道里找
    for (int i = 0; i < tracks.length; i++) {
      // 当前轨道溢出可用轨道
      if (FlutterDanmakuUtils.isEnableTrackOverflowArea(tracks[i])) break;
      bool allowInsert = _trackAllowInsert(tracks[i], bulletSize, bulletType: bulletType);
      if (allowInsert) {
        _track = tracks[i];
        break;
      }
    }
    return _track;
  }

  // 查询该轨道是否允许注入
  bool _trackAllowInsert(FlutterDanmakuTrack track, Size needInsertBulletSize, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    UniqueKey lastBulletId;
    assert(needInsertBulletSize.height > 0);
    assert(needInsertBulletSize.width > 0);
    // 非底部弹幕 超出配置的可视区域 就不可注入
    if (bulletType == FlutterDanmakuBulletType.fixed) return track.allowInsertFixedBullet;
    if (track.lastBulletId == null) return true;
    lastBulletId = track.lastBulletId;
    FlutterDanmakuBulletModel lastBullet = _bulletManager.bulletsMap[lastBulletId];
    if (lastBullet == null) return true;
    return !FlutterDanmakuUtils.trackInsertBulletHasBump(lastBullet, needInsertBulletSize);
  }

  FlutterDanmakuTrack _findAvailableTrack(Size bulletSize,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll, FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any}) {
    assert(bulletSize.height > 0);
    assert(bulletSize.width > 0);
    if (position == FlutterDanmakuBulletPosition.any) {
      return _findAllowInsertTrack(bulletSize, bulletType: bulletType);
    } else {
      return _findAllowInsertBottomTrack(bulletSize);
    }
  }

  // 查找允许注入的底部轨道
  FlutterDanmakuTrack _findAllowInsertBottomTrack(Size bulletSize) {
    FlutterDanmakuTrack _track;
    // 在现有轨道里找
    // 底部弹幕 指的是 最后几条轨道 从最底下往上发
    for (int i = tracks.length - 1; i >= tracks.length - 3; i--) {
      // 从当前的弹幕里找 有没有在这个轨道上的
      FlutterDanmakuBulletModel bullet = _bulletManager.bottomBullets.firstWhere((element) => element.trackId == tracks[i].id, orElse: () => null);
      if (bullet == null) {
        _track = tracks[i];
        break;
      }
    }
    return _track;
  }

  // 重制子弹数值
  _recountBulletsOffset() {
    // 写的非常脏 但是太累了
    bullets.forEach((FlutterDanmakuBulletModel bullet) {
      FlutterDanmakuTrack track = tracks.firstWhere((element) => element.id == bullet.trackId, orElse: () => null);
      if (track == null) return;
      bullet.offsetY = track.offsetTop;
      bullet.bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(bullet.text);
    });
  }
}
