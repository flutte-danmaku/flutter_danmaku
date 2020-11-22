import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_controller.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_render.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_danmaku/flutter_danmaku.dart';

void main() {
  FlutterDanmakuController flutterDanmakuController;
  FlutterDanmakuBulletManager flutterDanmakuBulletManager;
  FlutterDanmakuTrackManager flutterDanmakuTrackManager;
  setUp(() async {
    flutterDanmakuController = FlutterDanmakuController();
    flutterDanmakuBulletManager = FlutterDanmakuBulletManager();
    flutterDanmakuTrackManager = FlutterDanmakuTrackManager();
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

      expect(bulletModel.everyFrameRunDistance, FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(bulletSize.width));
      bulletModel.runNextFrame();
      expect(bulletModel.runDistance, bulletModel.everyFrameRunDistance * FlutterDanmakuConfig.bulletRate);
      bulletModel.runNextFrame();
      expect(bulletModel.runDistance, bulletModel.everyFrameRunDistance * FlutterDanmakuConfig.bulletRate * 2);
      double runDistance = bulletModel.runDistance;
      expect(runDistance > bulletModel.maxRunDistance, bulletModel.allOutLeave);
      expect(bulletModel.needRunDistace, width + bulletModel.bulletSize.width);
      expect(bulletModel.remanderDistance, bulletModel.needRunDistace - bulletModel.runDistance);
      expect(bulletModel.leaveScreenRemainderTime, bulletModel.remanderDistance / bulletModel.everyFrameRunDistance);
      expect(bullet.buildText().runtimeType, Text);
      flutterDanmakuController.resizeArea(size: Size(500, 500));
      AddBulletResBody addRes = flutterDanmakuController.addDanmaku('hello world', builder: (Text textWidget) => Container(child: textWidget));
      FlutterDanmakuBulletModel bullet1 = flutterDanmakuController.bullets.firstWhere((element) => element.id == addRes.data, orElse: () => null);
      expect(bullet1.builder(Text('hello world')).runtimeType, Container);
      flutterDanmakuController.changeLableSize(10);
      expect(flutterDanmakuController.bullets.isEmpty, false);
      flutterDanmakuController.removeAllBullet();
      expect(flutterDanmakuController.bullets.isEmpty, true);
    });
  });

  group('FlutterDanmakuBulletManager', () {
    test('getDanmakuBulletSizeByText', () {
      expect(FlutterDanmakuUtils.getDanmakuBulletSizeByText('hello world').runtimeType, Size);
    });

    test('initBullet', () {
      FlutterDanmakuBulletManager flutterDanmakuBulletManager = FlutterDanmakuBulletManager();
      FlutterDanmakuConfig.areaSize = Size(20, 20);
      flutterDanmakuBulletManager.removeAllBullet();
      UniqueKey trackId = UniqueKey();
      Size bulletSize = Size(10, 10);
      String text = 'hello world';
      double offsetY = 0;
      expect(flutterDanmakuBulletManager.bulletKeys.isEmpty, true);
      FlutterDanmakuBulletModel bulletModel = flutterDanmakuBulletManager.initBullet(text, trackId, bulletSize, offsetY);
      expect(bulletModel.runtimeType, FlutterDanmakuBulletModel);
      expect(bulletModel.id.runtimeType, UniqueKey);
      expect(flutterDanmakuBulletManager.bullets.length, 1);
      expect(flutterDanmakuBulletManager.bulletsMap[bulletModel.id], bulletModel);
      expect(flutterDanmakuBulletManager.bulletKeys[0], bulletModel.id);
      expect(bulletModel.everyFrameRunDistance, FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(bulletSize.width));
      AddBulletResBody addBulletResBody = AddBulletResBody(AddBulletResCode.success);
      expect(addBulletResBody.code, AddBulletResCode.success);
      AddBulletResBody addBulletResBody1 = AddBulletResBody(AddBulletResCode.noSpace);
      expect(addBulletResBody1.code, AddBulletResCode.noSpace);
    });

    test('getBulletEveryFramerateRunDistance', () {
      double bulletWidth = 5;
      expect(FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(bulletWidth),
          FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale));
    });

    test('removeBulletById', () {
      UniqueKey trackId = UniqueKey();
      Size bulletSize = Size(10, 10);
      String bulletText = 'hello world';
      double offsetY = 0;
      FlutterDanmakuBulletModel bullet1 = flutterDanmakuBulletManager.initBullet(bulletText, trackId, bulletSize, offsetY);
      UniqueKey bullet1Key = bullet1.id;
      expect(flutterDanmakuBulletManager.bulletsMap[bullet1Key], bullet1);
      expect(flutterDanmakuBulletManager.bulletsMap.containsKey(bullet1Key), true);
      flutterDanmakuBulletManager.removeBulletByKey(bullet1Key);
      expect(flutterDanmakuBulletManager.bulletsMap.containsKey(bullet1Key), false);
    });

    test('remainderTimeLeaveScreen', () {
      FlutterDanmakuConfig.areaSize = Size(500, 500);
      double remainderFrame = FlutterDanmakuUtils.remainderTimeLeaveScreen(80, 10, 5);
      expect(remainderFrame, ((500 + 10) - 80) / 5);
    });

    test('recountBulletsOffset', () {
      flutterDanmakuController.resizeArea(size: Size(500, 500));
      flutterDanmakuController.addDanmaku('hello world');
      flutterDanmakuController.addDanmaku('hello world');
      flutterDanmakuController.addDanmaku('hello world');
      flutterDanmakuController.addDanmaku('hello world');
      // flutterDanmakuController.recountBulletsOffset();
    });
  });

  group('bullet', () {
    test('getBulletEveryFramerateRunDistance', () {
      double bulletWidth = 5;
      expect(FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(bulletWidth),
          FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale));
    });

    testWidgets('FlutterDanmakuBullet', (WidgetTester tester) async {
      String text = 'hello world';
      // Create the widget by telling the tester to build it.
      await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: FlutterDanmakuBullet(
            UniqueKey(),
            text,
            color: Colors.red,
          )));
    });
  });

  group('FlutterDanmakuConfig config', () {
    test('showAreaHeight', () {
      double areaHeight = 80;
      double trackHeight = 10;
      FlutterDanmakuConfig.areaSize = Size(10, areaHeight);
      FlutterDanmakuConfig.showAreaPercent = 0.5;
      expect(FlutterDanmakuConfig.showAreaHeight, areaHeight * FlutterDanmakuConfig.showAreaPercent);
      flutterDanmakuTrackManager.buildTrack(trackHeight);
      flutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(flutterDanmakuTrackManager.remainderHeight, FlutterDanmakuConfig.showAreaHeight - trackHeight - trackHeight);
      expect(FlutterDanmakuConfig.bulletBaseShowDuration.runtimeType, Duration);
      Size textSize = Size(10, 10);
      expect(FlutterDanmakuConfig.getAreaOfChildOffsetY(textSize: textSize), (areaHeight % textSize.height) / 2);
    });
  });

  group('FlutterDanmakuTrackManager', () {
    test('buildTrack', () {
      double trackHeight = 10;
      flutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(flutterDanmakuTrackManager.tracks.length, 1);
      FlutterDanmakuTrack trackFirst = flutterDanmakuTrackManager.tracks.first;
      expect(trackFirst.offsetTop, 0);
      expect(trackFirst.trackHeight, trackHeight);
      trackFirst.offsetTop = 0;
      FlutterDanmakuTrack track = flutterDanmakuTrackManager.buildTrack(trackHeight);
      FlutterDanmakuTrack trackSecend = flutterDanmakuTrackManager.tracks.last;
      expect(trackSecend.offsetTop, trackFirst.offsetTop + trackFirst.trackHeight);
      expect(flutterDanmakuTrackManager.tracks.length, 2);
      double trackHeight2 = 80;
      track.trackHeight = trackHeight2;
      expect(track.offsetTop, flutterDanmakuTrackManager.allTrackHeight - trackHeight2);
      expect(track.allowInsertFixedBullet, true);
      UniqueKey bulletId = UniqueKey();
      track.loadFixedBulletId(bulletId);
      expect(track.allowInsertFixedBullet, false);
    });
    test('findAvailableTrack', () async {
      FlutterDanmakuConfig.areaSize = Size(999, 999);
      // String bulletText = 'hello world';
      // Size bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(bulletText);
      // AddBulletResBody resBoyd1 = flutterDanmakuController.addDanmaku(bulletText);
      // expect(resBoyd1.code, AddBulletResCode.success);
      // expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, position: FlutterDanmakuBulletPosition.bottom).id, track5.id);
      // flutterDanmakuController.addDanmaku('底部弹幕', position: FlutterDanmakuBulletPosition.bottom, bulletType: FlutterDanmakuBulletType.fixed);
      // expect(FlutterDanmakuTrackManager.findAvailableTrack(bulletSize, position: FlutterDanmakuBulletPosition.bottom).id, track4.id);
      // expect(flutterDanmakuBulletManager.bottomBullets.firstWhere((element) => element.trackId == track5.id).trackId, track5.id);
    });

    test('areaAllowBuildNewTrack', () {
      flutterDanmakuTrackManager.tracks = [];
      // bool allow = FlutterDanmakuTrackManager.areaAllowBuildNewTrack(50);
      // expect(allow, true);
    });

    test('isTrackOverflowArea and isEnableTrackOverflowArea', () {
      Size areaSize = Size(120, 120);
      double trackHeight = 50;
      flutterDanmakuTrackManager.tracks = [];
      FlutterDanmakuConfig.areaSize = areaSize;
      FlutterDanmakuTrack track = flutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(flutterDanmakuTrackManager.isTrackOverflowArea, false);
      expect(FlutterDanmakuUtils.isEnableTrackOverflowArea(track), false);
      FlutterDanmakuConfig.showAreaPercent = 0.3;
      expect(FlutterDanmakuUtils.isEnableTrackOverflowArea(track), true);
      flutterDanmakuTrackManager.buildTrack(trackHeight);
      flutterDanmakuTrackManager.buildTrack(trackHeight);
      expect(flutterDanmakuTrackManager.isTrackOverflowArea, true);
      FlutterDanmakuConfig.showAreaPercent = 1;
      // FlutterDanmakuTrack availableTrack = FlutterDanmakuTrackManager.findAvailableTrack(Size(20, trackHeight));
      // expect(availableTrack.id, track.id);
      FlutterDanmakuConfig.showAreaPercent = 0.5;
      expect(flutterDanmakuTrackManager.areaAllowBuildNewTrack(trackHeight), false);
    });

    test('trackInsertBulletHasBump', () async {
      // String text = 'hello world';
      // Size textSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(text);
      // flutterDanmakuController.resizeArea(size: Size(500, 500));
      // AddBulletResBody bulletResBody = flutterDanmakuController.addDanmaku(text);
      // FlutterDanmakuBulletModel bullet = flutterDanmakuBulletManager.bulletsMap[bulletResBody.data];
      // expect(bullet.runtimeType, FlutterDanmakuBulletModel);
      // bool willBump = FlutterDanmakuUtils.trackInsertBulletHasBump(bullet, textSize);
      // expect(willBump, true);
      // bool willBump2 = FlutterDanmakuUtils.trackInsertBulletHasBump(bullet, FlutterDanmakuUtils.getDanmakuBulletSizeByText(text * 2));
      // expect(willBump2, true);
      // for (int i = 0; i < 200; i++) {
      //   bullet.runNextFrame();
      // }
      // bool willBump1 = FlutterDanmakuUtils.trackInsertBulletHasBump(bullet, textSize);
      // expect(willBump1, false);
      // expect(FlutterDanmakuUtils.trackAllowInsert(FlutterDanmakuController.tracks[0], textSize), true);
      // expect(flutterDanmakuTrackManager.tracks.where((element) => element.id == bullet.trackId).first.lastBulletId, null);
      // AddBulletResBody bulletResBody1 = flutterDanmakuController.addDanmaku(text, bulletType: FlutterDanmakuBulletType.fixed);
      // expect(flutterDanmakuTrackManager.tracks.where((element) => element.id == bullet.trackId).first.bindFixedBulletId, null);
      // FlutterDanmakuTrackManager.recountTrackOffset();
    });
  });

  group('FlutterDanmakuController', () {
    test('run', () async {
      int mycount = 0;
      // flutterDanmakuController.run(() => {if (mycount == 3) flutterDanmakuManager.dispose(), mycount += 1});
      // await Future.delayed(Duration(seconds: 1));
      // expect(mycount, 4);
    });
  });

  group('FlutterDanmakuAreaState', () {
    test('addDanmaku', () {
      // flutterDanmakuBulletManager.removeAllBullet();
      // String text = 'text';
      // expect(flutterDanmakuTrackManager.tracks.isEmpty, true);
      // AddBulletResBody resBody = flutterDanmakuController.addDanmaku(text);
      // expect(resBody.code, AddBulletResCode.noSpace);
      // Size textSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(text);
      // FlutterDanmakuTrack track = flutterDanmakuTrackManager.buildTrack(textSize.height);
      // AddBulletResBody resBody1 = flutterDanmakuController.addDanmaku(text);
      // expect(resBody1.code, AddBulletResCode.success);
      // expect(track.lastBulletId, flutterDanmakuBulletManager.bullets[0].id);
      // FlutterDanmakuArea(child: Container(height: 500, width: 500));
    });

    //     testWidgets('FlutterDanmakuBullet', (WidgetTester tester) async {
    //   String text = 'hello world';
    //   // Create the widget by telling the tester to build it.
    //   await tester.pumpWidget(Directionality(
    //       textDirection: TextDirection.ltr,
    //       child: FlutterDanmakuBullet(
    //         UniqueKey(),
    //         text,
    //         color: Colors.red,
    //       )));
    // });

    testWidgets('FlutterDanmakuArea', (WidgetTester tester) async {
      // Widget childArea = Container(height: 400, width: 400);
      // await tester.pumpWidget(Directionality(
      //     textDirection: TextDirection.ltr,
      //     child: FlutterDanmakuArea(
      //       child: childArea,
      //     )));
    });

    test('play status', () {
      expect(flutterDanmakuController.isPause, FlutterDanmakuConfig.pause);
      flutterDanmakuController.play();
      expect(flutterDanmakuController.isPause, FlutterDanmakuConfig.pause);
      expect(flutterDanmakuController.isPause, false);
      flutterDanmakuController.pause();
      expect(flutterDanmakuController.isPause, FlutterDanmakuConfig.pause);
      expect(flutterDanmakuController.isPause, true);
    });

    test('init dispose', () {
      FlutterDanmakuRenderManager renderManager = FlutterDanmakuRenderManager();
      expect(flutterDanmakuController.inited, false);
      expect(renderManager.timer, null);
      flutterDanmakuController.init(size: Size(500, 500));
      expect(flutterDanmakuController.inited, true);
      // expect(renderManager.timer.isActive, true);
      renderManager.dispose();
      // expect(renderManager.timer.isActive, false);
    });

    test('changeShowArea', () {
      double targetPercent = 0.5;
      flutterDanmakuController.changeShowArea(targetPercent);
      expect(FlutterDanmakuConfig.showAreaPercent, targetPercent);
    });

    test('resizeArea', () {
      flutterDanmakuController.resizeArea(size: Size(10, 50));
      expect(FlutterDanmakuConfig.areaSize, Size(10, 50));
    });

    test('changeRate', () {
      double rate = 5;
      flutterDanmakuController.changeRate(rate);
      expect(FlutterDanmakuConfig.bulletRate, rate);
    });

    test('changeOpacity', () {
      double opacity = 0.6;
      flutterDanmakuController.changeOpacity(opacity);
      expect(FlutterDanmakuConfig.opacity, opacity);
    });

    test('changeLableSize', () {
      int size = 12;
      flutterDanmakuController.changeLableSize(size);
      expect(FlutterDanmakuConfig.bulletLableSize, size);
    });
  });
}
