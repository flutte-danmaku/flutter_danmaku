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
  FlutterDanmakuManager danmakuManager = FlutterDanmakuManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      _initArea();
      Future.delayed(Duration(milliseconds: 300), () {
        danmakuManager.run(() {
          setState(() {});
        });
      });
    });
  }

  // 是否暂停
  bool get isPause => FlutterDanmakuConfig.pause;

  // 添加弹幕
  void addDanmaku(String text, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll, Color color = FlutterDanmakuConfig.defaultColor}) {
    widget.key.currentState.danmakuManager.addDanmaku(context, text, bulletType: bulletType, color: color);
  }

  // 暂停
  void pause() {
    FlutterDanmakuConfig.pause = true;
  }

  // 播放
  void play() {
    FlutterDanmakuConfig.pause = false;
  }

  // 修改弹幕速率 0~1
  void changeRate(double rate) {
    FlutterDanmakuConfig.bulletRate = rate;
  }

  void changeOpacity(double opacity) {
    FlutterDanmakuConfig.opacity = opacity;
  }

  // 修改文字大小
  void changeLableSize(int size) {
    FlutterDanmakuConfig.bulletLableSize = size.toDouble();
    FlutterDanmakuTrackManager.recountTrackOffset();
    FlutterDanmakuBulletUtils.recountBulletsOffset();
  }

  // 改变视图尺寸后调用，比如全屏
  void resizeArea() {
    _initArea();
  }

  // 修改弹幕最大可展示场景的百分比
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

  void _initArea() {
    FlutterDanmakuConfig.areaSize = context.size;
  }

  // 销毁前需要调用取消监听器
  void dipose() {
    danmakuManager.timer.cancel();
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
