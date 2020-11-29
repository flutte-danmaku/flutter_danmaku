import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';

class FlutterDanmakuRenderManager {
  Timer _timer;

  Timer get timer => _timer;

  void run(Function nextFrame, Function setState) {
    _timer = Timer.periodic(Duration(milliseconds: FlutterDanmakuConfig.unitTimer), (Timer timer) {
      // 暂停不执行
      if (!FlutterDanmakuConfig.pause) {
        nextFrame();
        setState(() {});
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }

  // 渲染下一帧
  List<FlutterDanmakuBulletModel> renderNextFramerate(List<FlutterDanmakuBulletModel> bullets, Function(UniqueKey) allOutLeaveCallBack) {
    print(bullets.length);
    List<FlutterDanmakuBulletModel> _bullets = List.generate(bullets.length, (index) => bullets[index]);
    _bullets.forEach((FlutterDanmakuBulletModel bulletModel) {
      bulletModel.runNextFrame();
      if (bulletModel.allOutLeave) {
        allOutLeaveCallBack(bulletModel.id);
      }
    });
    return _bullets;
  }
}
