// 弹幕主场景
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuArea extends StatefulWidget {
  FlutterDanmakuArea({this.key, @required this.child}) : super(key: key);

  final Widget child;

  final GlobalKey<FlutterDanmakuAreaState> key;

  @override
  State<FlutterDanmakuArea> createState() => FlutterDanmakuAreaState();
}

class FlutterDanmakuAreaState extends State<FlutterDanmakuArea> {
  List<FlutterDanmakuTrack> _tracks = [];
  FlutterDanmakuManager _danmakuManager = FlutterDanmakuManager();

  bool get inited => _inited;
  FlutterDanmakuManager get danmakuManager => _danmakuManager;
  List<FlutterDanmakuTrack> get tracks => _tracks;

  bool _inited = false;

  void _initArea() {
    resizeArea();
    FlutterDanmakuTrackManager.buildTrackFullScreen();
    if (_inited) return;
    _inited = true;
    runDanmukaEngine(() {
      setState(() {});
    });
  }

  runDanmukaEngine(Function callBack) {
    _danmakuManager.run(callBack);
  }

  @override
  void initState() {
    super.initState();
  }

  // 是否暂停
  bool get isPause => FlutterDanmakuConfig.pause;

  // 添加弹幕
  AddBulletResBody addDanmaku(String text,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll,
      Color color = FlutterDanmakuConfig.defaultColor,
      FlutterDanmakuBulletPosition position = FlutterDanmakuBulletPosition.any,
      Widget Function(Text) builder}) {
    assert(text.isNotEmpty);
    if (builder != null) print('builder');
    return _danmakuManager.addDanmaku(context, text, bulletType: bulletType, color: color, position: position, builder: builder);
  }

  // 初始化
  void init() {
    _initArea();
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

  void changeOpacity(double opacity) {
    assert(opacity <= 1);
    assert(opacity >= 0);
    FlutterDanmakuConfig.opacity = opacity;
  }

  // 修改文字大小
  void changeLableSize(int size) {
    assert(size > 0);
    FlutterDanmakuConfig.bulletLableSize = size.toDouble();
    FlutterDanmakuTrackManager.recountTrackOffset();
    FlutterDanmakuBulletUtils.recountBulletsOffset();
  }

  // 改变视图尺寸后调用，比如全屏
  void resizeArea({Size size = const Size(0, 0)}) {
    FlutterDanmakuConfig.areaSize = context?.size ?? size;
    FlutterDanmakuTrackManager.recountTrackOffset();
    if (FlutterDanmakuConfig.pause) {
      _danmakuManager.randerNextFrame();
      setState(() {});
    }
  }

  // 修改弹幕最大可展示场景的百分比
  void changeShowArea(double percent) {
    assert(percent <= 1);
    assert(percent >= 0);
    FlutterDanmakuConfig.showAreaPercent = percent;
    FlutterDanmakuTrackManager.buildTrackFullScreen();
  }

  // 销毁前需要调用取消监听器
  void dipose() {
    _danmakuManager.dispose();
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
