import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_danmaku/flutter_danmaku.dart';

void main() {
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
      expect(bulletModel.offsetX, bulletModel.runDistance - bulletSize.width);
      bulletModel.bulletType = FlutterDanmakuBulletType.fixed;
      expect(bulletModel.offsetX, FlutterDanmakuConfig.areaSize.width / 2 - bulletSize.width / 2);
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

    test('removeBulletById', () {
      UniqueKey trackId = UniqueKey();
      Size bulletSize = Size(10, 10);
      String bulletText = 'hello world';
      double offsetY = 0;
      FlutterDanmakuBulletModel bullet1 = FlutterDanmakuBulletUtils.initBullet(bulletText, trackId, bulletSize, offsetY);
      UniqueKey bullet1Key = bullet1.id;
      expect(FlutterDanmakuManager.bullets[bullet1Key], bullet1);
      expect(FlutterDanmakuManager.bullets.containsKey(bullet1Key), true);
      FlutterDanmakuBulletUtils.removeBulletById(bullet1Key);
      expect(FlutterDanmakuManager.bullets.containsKey(bullet1Key), false);
    });
  });

  group('bullet', () {
    test('getBulletEveryFramerateRunDistance', () {
      double bulletWidth = 5;
      expect(FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletWidth),
          FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale));
    });
  });

  group('FlutterDanmakuConfig config', () {
    test('showAreaHeight', () {
      double areaHeight = 10;
      FlutterDanmakuConfig.areaSize = Size(10, areaHeight);
      FlutterDanmakuConfig.showAreaPercent = 0.5;
      expect(FlutterDanmakuConfig.showAreaHeight, areaHeight * FlutterDanmakuConfig.showAreaPercent);
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

  group('FlutterDanmakuAreaState', () {
    test('play status', () {
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      expect(flutterDanmakuAreaState.isPause, FlutterDanmakuConfig.pause);
      flutterDanmakuAreaState.play();
      expect(flutterDanmakuAreaState.isPause, FlutterDanmakuConfig.pause);
      expect(flutterDanmakuAreaState.isPause, false);
      flutterDanmakuAreaState.pause();
      expect(flutterDanmakuAreaState.isPause, FlutterDanmakuConfig.pause);
      expect(flutterDanmakuAreaState.isPause, true);
    });

    test('init dispose', () {
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      expect(flutterDanmakuAreaState.inited, false);
      expect(flutterDanmakuAreaState.danmakuManager.timer, null);
      flutterDanmakuAreaState.init();
      expect(flutterDanmakuAreaState.inited, true);
      expect(flutterDanmakuAreaState.danmakuManager.timer.isActive, true);
      flutterDanmakuAreaState.dipose();
      expect(flutterDanmakuAreaState.danmakuManager.timer.isActive, false);
    });

    test('changeShowArea', () {
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      double targetPercent = 0.5;
      flutterDanmakuAreaState.changeShowArea(targetPercent);
      expect(FlutterDanmakuConfig.showAreaPercent, targetPercent);
    });

    test('resizeArea', () {
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      flutterDanmakuAreaState.resizeArea(size: Size(10, 50));
      expect(FlutterDanmakuConfig.areaSize, Size(10, 50));
    });
  });
}
