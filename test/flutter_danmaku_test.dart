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
      FlutterDanmakuBulletModel bulletModel = FlutterDanmakuBulletModel(id: danmakuId, bulletSize: bulletSize, trackId: trackId, text: danmakuText, offsetY: 0);
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
      expect(bulletModel.allOutRight, false);
    });

    test("bullet model handle", () {
      FlutterDanmakuConfig.areaSize = Size(20, 20);
      UniqueKey danmakuId = UniqueKey();
      UniqueKey trackId = UniqueKey();
      String danmakuText = 'hello world';
      FlutterDanmakuBullet bullet = FlutterDanmakuBullet(danmakuId, danmakuText);
      Size bulletSize = Size(10, 10);
      FlutterDanmakuBulletModel bulletModel = FlutterDanmakuBulletModel(id: danmakuId, bulletSize: bulletSize, trackId: trackId, text: danmakuText, offsetY: 0);

      expect(bulletModel.everyFrameRunDistance, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletSize.width));
      bulletModel.runNextFrame();
      expect(bulletModel.runDistance, bulletModel.everyFrameRunDistance * FlutterDanmakuConfig.bulletRate);
      bulletModel.runNextFrame();
      expect(bulletModel.runDistance, bulletModel.everyFrameRunDistance * FlutterDanmakuConfig.bulletRate * 2);
      double runDistance = bulletModel.runDistance;
      expect(runDistance > bulletModel.maxRunDistance, bulletModel.allOutLeave);
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
      expect(FlutterDanmakuManager.bulletsMap[bulletModel.id], bulletModel);
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
      expect(FlutterDanmakuManager.bulletsMap[bullet1Key], bullet1);
      expect(FlutterDanmakuManager.bulletsMap.containsKey(bullet1Key), true);
      FlutterDanmakuBulletUtils.removeBulletById(bullet1Key);
      expect(FlutterDanmakuManager.bulletsMap.containsKey(bullet1Key), false);
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
    test('findAvailableTrack', () async {
      // FlutterDanmakuConfig.areaSize = Size(999, 999);
      double trackHeight = 10;
      Size bulletSize = Size(10, trackHeight);
      expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize), null);
      FlutterDanmakuTrack track1 = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack track2 = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack track3 = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack track4 = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack track5 = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, position: FlutterDanmakuBulletPosition.bottom).id, track5.id);
      UniqueKey bulletId = UniqueKey();
      track5.bindFixedBulletId = bulletId;
      expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, position: FlutterDanmakuBulletPosition.bottom).id, track4.id);
      // expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, position: FlutterDanmakuBulletPosition.any).id, track1.id);
      // UniqueKey bulletId1 = UniqueKey();
      // track1.lastBulletId = bulletId1;
      // expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize).id, track2.id);
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

    test('changeRate', () {
      double rate = 5;
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      flutterDanmakuAreaState.changeRate(rate);
      expect(FlutterDanmakuConfig.bulletRate, rate);
    });

    test('changeOpacity', () {
      double opacity = 0.6;
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      flutterDanmakuAreaState.changeOpacity(opacity);
      expect(FlutterDanmakuConfig.opacity, opacity);
    });

    test('changeLableSize', () {
      int size = 12;
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      flutterDanmakuAreaState.changeLableSize(size);
      expect(FlutterDanmakuConfig.bulletLableSize, size);
    });
  });
}
