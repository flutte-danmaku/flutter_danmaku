import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_danmaku/flutter_danmaku.dart';

void main() {
  // test('test something', () {
  //   Size bulletSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText('hello world!');
  //   assert(bulletSize.runtimeType == Size);
  //   FlutterDanmakuTrack track = FlutterDanmakuTrackManager.findAvailableTrack(bulletSize);
  //   assert(track == null);
  //   track = FlutterDanmakuTrackManager.buildTrack(bulletSize.height);
  //   assert(FlutterDanmakuManager.tracks.length == 1);
  //   assert(track.offsetTop == 0);
  //   assert(track.trackHeight == bulletSize.height);
  //   assert(track.id.runtimeType == UniqueKey);
  //   assert(track.lastBulletId == null);
  //   assert(track.bindFixedBulletId == null);
  // });

  group('bullet', () {
    test("bullet default prototype", () {
      FlutterDanmakuConfig.areaSize = Size(20, 20);
      UniqueKey danmakuId = UniqueKey();
      UniqueKey trackId = UniqueKey();
      String danmakuText = 'hello world';
      FlutterDanmakuBullet bullet = FlutterDanmakuBullet(danmakuId, danmakuText);
      Size bulletSize = Size(10, 10);
      FlutterDanmakuBulletModel bulletModel =
          FlutterDanmakuBulletModel(id: danmakuId, bulletSize: bulletSize, trackId: trackId, text: danmakuText, offsetY: 0, everyFrameRunDistance: 0);
      expect(bullet.text, danmakuText);
      expect(bullet.danmakuId, danmakuId);
      expect(bulletModel.id, danmakuId);
      expect(bulletModel.bulletSize, bulletSize);
      expect(bulletModel.trackId, trackId);
      expect(bulletModel.text, danmakuText);
      expect(bulletModel.maxRunDistance, bulletModel.bulletSize.width + FlutterDanmakuConfig.areaSize.width);
    });
  });

  group('FlutterDanmakuBulletUtils', () {
    test('getDanmakuBulletSizeByText', () {
      expect(FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText('hello world').runtimeType, Size);
    });

    test('initBullet', () {
      FlutterDanmakuConfig.areaSize = Size(20, 20);
      UniqueKey trackId = UniqueKey();
      Size bulletSize = Size(10, 10);
      String text = 'hello world';
      double offsetY = 0;
      FlutterDanmakuBulletModel bulletModel = FlutterDanmakuBulletUtils.initBullet(text, trackId, bulletSize, offsetY);
      expect(bulletModel.runtimeType, FlutterDanmakuBulletModel);
      expect(bulletModel.id.runtimeType, UniqueKey);
      expect(FlutterDanmakuManager.bullets.length, 1);
      expect(FlutterDanmakuManager.bullets[bulletModel.id], bulletModel);
      expect(bulletModel.everyFrameRunDistance, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletSize.width));
    });

    test('getBulletEveryFramerateRunDistance', () {
      double bulletWidth = 5;
      expect(FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletWidth),
          FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale));
    });
  });

  group('bullet', () {
    test('getBulletEveryFramerateRunDistance', () {
      double bulletWidth = 5;
      expect(FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletWidth),
          FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale));
    });
  });

  group('FlutterDanmakuTrackManager', () {
    test('buildTrack', () {
      double trackHeight = 10;
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(FlutterDanmakuManager.tracks.length, 1);
      FlutterDanmakuTrack trackFirst = FlutterDanmakuManager.tracks.first;
      expect(trackFirst.offsetTop, 0);
      expect(trackFirst.trackHeight, trackHeight);
      trackFirst.offsetTop = 0;
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack trackSecend = FlutterDanmakuManager.tracks.last;
      expect(trackSecend.offsetTop, trackFirst.offsetTop + trackFirst.trackHeight);
      expect(FlutterDanmakuManager.tracks.length, 2);
    });
  });
}
