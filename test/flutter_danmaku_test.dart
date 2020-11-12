import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_danmaku/flutter_danmaku.dart';

void main() {
  setUp(() async {
    FlutterDanmakuManager.tracks = [];
  });
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
      double width = 20;
      FlutterDanmakuConfig.areaSize = Size(width, 20);
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
      expect(bulletModel.needRunDistace, width + bulletModel.bulletSize.width);
      expect(bulletModel.remanderDistance, bulletModel.needRunDistace - bulletModel.runDistance);
      expect(bulletModel.leaveScreenRemainderTime, bulletModel.remanderDistance / bulletModel.everyFrameRunDistance);
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
      expect(FlutterDanmakuManager.bulletKeys.isEmpty, true);
      FlutterDanmakuBulletModel bulletModel = FlutterDanmakuBulletUtils.initBullet(text, trackId, bulletSize, offsetY);
      expect(bulletModel.runtimeType, FlutterDanmakuBulletModel);
      expect(bulletModel.id.runtimeType, UniqueKey);
      expect(FlutterDanmakuManager.bullets.length, 1);
      expect(FlutterDanmakuManager.bulletsMap[bulletModel.id], bulletModel);
      expect(FlutterDanmakuManager.bulletKeys[0], bulletModel.id);
      expect(bulletModel.everyFrameRunDistance, FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletSize.width));
      AddBulletResBody addBulletResBody = AddBulletResBody(AddBulletResCode.success);
      expect(addBulletResBody.code, AddBulletResCode.success);
      AddBulletResBody addBulletResBody1 = AddBulletResBody(AddBulletResCode.noSpace);
      expect(addBulletResBody1.code, AddBulletResCode.noSpace);
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
      double areaHeight = 80;
      double trackHeight = 10;
      FlutterDanmakuConfig.areaSize = Size(10, areaHeight);
      FlutterDanmakuConfig.showAreaPercent = 0.5;
      expect(FlutterDanmakuConfig.showAreaHeight, areaHeight * FlutterDanmakuConfig.showAreaPercent);
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(FlutterDanmakuConfig.remainderHeight, FlutterDanmakuConfig.showAreaHeight - trackHeight - trackHeight);
      expect(FlutterDanmakuConfig.bulletBaseShowDuration.runtimeType, Duration);
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
      FlutterDanmakuTrack track = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack trackSecend = FlutterDanmakuManager.tracks.last;
      expect(trackSecend.offsetTop, trackFirst.offsetTop + trackFirst.trackHeight);
      expect(FlutterDanmakuManager.tracks.length, 2);
      double trackHeight2 = 80;
      track.trackHeight = trackHeight2;
      expect(track.offsetTop, FlutterDanmakuManager.allTrackHeight - trackHeight2);
      expect(track.allowInsertFixedBullet, true);
      UniqueKey bulletId = UniqueKey();
      track.bindFixedBulletId = bulletId;
      expect(track.allowInsertFixedBullet, false);
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
    });

    test('areaAllowBuildNewTrack', () {
      FlutterDanmakuManager.tracks = [];
      bool allow = FlutterDanmakuTrackManager.areaAllowBuildNewTrack(50);
      expect(allow, true);
    });

    test('isTrackOverflowArea and isEnableTrackOverflowArea', () {
      Size areaSize = Size(120, 120);
      double trackHeight = 50;
      FlutterDanmakuManager.tracks = [];
      FlutterDanmakuConfig.areaSize = areaSize;
      FlutterDanmakuTrack track = FlutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(FlutterDanmakuTrackManager.isTrackOverflowArea, false);
      expect(FlutterDanmakuTrackManager.isEnableTrackOverflowArea(track), false);
      FlutterDanmakuConfig.showAreaPercent = 0.3;
      expect(FlutterDanmakuTrackManager.isEnableTrackOverflowArea(track), true);
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(FlutterDanmakuTrackManager.isTrackOverflowArea, true);
      FlutterDanmakuConfig.showAreaPercent = 1;
      FlutterDanmakuTrack availableTrack = FlutterDanmakuTrackManager.findAvailableTrack(Size(20, trackHeight));
      expect(availableTrack.id, track.id);
      FlutterDanmakuConfig.showAreaPercent = 0.5;
      expect(FlutterDanmakuTrackManager.areaAllowBuildNewTrack(trackHeight), false);
    });
  });

  group('FlutterDanmakuAreaState', () {
    test('addDanmaku', () {
      FlutterDanmakuManager.removeAllBullet();
      String text = 'text';
      FlutterDanmakuAreaState flutterDanmakuAreaState = FlutterDanmakuAreaState();
      expect(flutterDanmakuAreaState.tracks.isEmpty, true);
      AddBulletResBody resBody = flutterDanmakuAreaState.addDanmaku(text);
      expect(resBody.code, AddBulletResCode.noSpace);
      Size textSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText(text);
      FlutterDanmakuTrack track = FlutterDanmakuTrackManager.buildTrack(textSize.height);
      AddBulletResBody resBody1 = flutterDanmakuAreaState.addDanmaku(text);
      expect(resBody1.code, AddBulletResCode.success);
      expect(track.lastBulletId, FlutterDanmakuManager.bullets[0].id);
    });

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
