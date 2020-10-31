// 弹幕轨道

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';

enum FlutterDanmakuTrackType { scroll, fixed }

class FlutterDanmakuTrack {
  static FlutterDanmakuTrack flutterDanmakuTrackBuilder(BuildContext context) {}

  FlutterDanmakuBullet lastBullet;

  double offsetTop;

  double trackHeight;

  FlutterDanmakuTrack(this.trackHeight, this.offsetTop);
}
