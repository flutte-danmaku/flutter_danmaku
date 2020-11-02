// 弹幕主场景
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuArea extends StatefulWidget {
  FlutterDanmakuArea({this.key, @required this.child}) : super(key: key);
  Widget child;
  GlobalKey<FlutterDanmakuAreaState> key;
  @override
  State<FlutterDanmakuArea> createState() => FlutterDanmakuAreaState();
}

class FlutterDanmakuAreaState extends State<FlutterDanmakuArea> {
  List<FlutterDanmakuTrack> tracks = [];
  FlutterDanmakuManager danmakuMagaer = FlutterDanmakuManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      initArea();
      danmakuMagaer.addDanmaku(context, '我曹尼啊');
      Future.delayed(Duration(milliseconds: 300), () {
        danmakuMagaer.run(() {
          setState(() {});
        });
      });
    });
  }

  void addDanmaku(String text, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    widget.key.currentState.danmakuMagaer.addDanmaku(context, text, bulletType: bulletType);
  }

  void changeRate(double rate) {
    FlutterDanmakuConfig.bulletRate = rate;
  }

  void changeLableSize(double size) {
    FlutterDanmakuConfig.bulletLableSize = size;
    FlutterDanmakuTrackManager.recountTrackOffset();
    FlutterDanmakuBulletUtils.recountBulletsOffset();
  }

  void changeShowArea(double percent) {
    if (percent > 1 || percent < 0) return;
    if (percent < FlutterDanmakuConfig.showAreaPercent) {
      for (int i = 0; i < tracks.length; i++) {
        // 把溢出的轨道之后全部删掉
        if (FlutterDanmakuTrackManager.isTrackOverflowArea(tracks[i])) {
          tracks.removeRange(i, tracks.length);
          break;
        }
      }
    }
    FlutterDanmakuConfig.showAreaPercent = percent;
  }

  void initArea() {
    FlutterDanmakuConfig.areaSize = context.size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: widget.child,
        ),
        ...FlutterDanmakuBulletUtils.buildAllBullet(context)
      ],
    );
  }
}
