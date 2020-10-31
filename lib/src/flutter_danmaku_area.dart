// 弹幕主场景
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';

class FlutterDanmakuArea extends StatefulWidget {
  FlutterDanmakuArea({Key key, @required this.child}) : super(key: key);
  Widget child;
  @override
  State<FlutterDanmakuArea> createState() => FlutterDanmakuAreaState();
}

class FlutterDanmakuAreaState extends State<FlutterDanmakuArea> {
  List<FlutterDanmakuTrack> tracks = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration callback) {
      initArea();
      appendDanmaku('我曹尼啊');
    });
  }

  // 是否允许建立新轨道
  bool areaAllowBuildNewTrack(double needBuildTrackHeight) {
    if (tracks.isEmpty) return true;
    double currentAllTrackHeight = tracks.last.offsetTop + tracks.last.trackHeight;
    return FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent - currentAllTrackHeight >= needBuildTrackHeight;
  }

  void changeRate(double rate) {
    FlutterDanmakuConfig.bulletRate = rate;
  }

  void changeLableSize(double size) {
    FlutterDanmakuConfig.bulletLableSize = size;
    recountTrackOffset();
  }

  void changeShowArea(double percent) {
    if (percent > 1 || percent < 0) return;
    if (percent < FlutterDanmakuConfig.showAreaPercent) {
      for (int i = 0; i < tracks.length; i++) {
        // 把溢出的轨道之后全部删掉
        if (FlutterDanmakuUtils.isTrackOverflowArea(tracks[i])) {
          tracks.removeRange(i, tracks.length);
          break;
        }
      }
    }
    FlutterDanmakuConfig.showAreaPercent = percent;
  }

  // 重新计算轨道高度和距顶
  void recountTrackOffset() {
    Size currentLabelSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText('s');
    for (int i = 0; i < tracks.length; i++) {
      tracks[i].offsetTop = i * currentLabelSize.height;
      tracks[i].trackHeight = currentLabelSize.height;
      // 把溢出的轨道之后全部删掉
      if (FlutterDanmakuUtils.isTrackOverflowArea(tracks[i])) {
        tracks.removeRange(i, tracks.length);
        break;
      }
    }
  }

  void appendDanmaku(String text) {
    // 先获取子弹尺寸
    Size bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(text);
    // 寻找可用的轨道
    FlutterDanmakuTrack track = findAvailableTrack(bulletSize);
    // 如果没有找到可用的轨道
    if (track == null) {
      bool allowNewTrack = areaAllowBuildNewTrack(bulletSize.height);
      if (!allowNewTrack) return;
      track = buildTrack(bulletSize.height);
    }
    FlutterDanmakuBullet bullet = buildBullet(text, bulletSize, track.offsetTop, track);
    track.lastBullet = bullet;
    FlutterDanmakuUtils.appendBulletToScreen(context, bullet);
  }

  FlutterDanmakuBullet buildBullet(String text, Size bulletSize, double offsetY, FlutterDanmakuTrack track) {
    FlutterDanmakuBulletProvider bullet = FlutterDanmakuBulletProvider(bulletSize, FlutterDanmakuUtils.getBulletShowTime(bulletSize.width), offsetY, track);
    return FlutterDanmakuBullet(text, bullet);
  }

  FlutterDanmakuTrack buildTrack(double trackHeight) {
    double trackOffsetTop = 0;
    if (tracks.isNotEmpty) {
      trackOffsetTop = tracks.last.offsetTop + tracks.last.trackHeight;
    }
    FlutterDanmakuTrack track = FlutterDanmakuTrack(trackHeight, trackOffsetTop);
    tracks.add(track);
    return track;
  }

  void initArea() {
    FlutterDanmakuConfig.areaSize = context.size;
  }

  bool needAppendTracks() {
    if (tracks.isEmpty) return true;
    return false;
  }

  FlutterDanmakuTrack findAvailableTrack(Size bulletSize) {
    FlutterDanmakuTrack _track;
    // 轨道列表为空
    if (tracks.isEmpty) return null;
    // 在现有轨道里找
    for (int i = 0; i < tracks.length; i++) {
      bool isTrackOverflow = FlutterDanmakuUtils.isTrackOverflowArea(tracks[i]);
      if (isTrackOverflow) break;
      bool allowInsert = FlutterDanmakuUtils.trackAllowInsert(tracks[i], bulletSize);
      if (allowInsert) {
        _track = tracks[i];
        break;
      }
    }
    return _track;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
        link: FlutterDanmakuConfig.danmakuAreaLayerLink,
        child: ClipRect(
          child: Container(
            child: widget.child,
          ),
        ));
  }
}
