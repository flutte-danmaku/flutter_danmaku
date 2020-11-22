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
  renderNextFramerate(Map<UniqueKey, FlutterDanmakuBulletModel> bulletMap, Function(UniqueKey) allOutLeaveCallBack) {
    bulletMap.forEach((UniqueKey bulletId, FlutterDanmakuBulletModel bulletModel) {
      bulletModel.runNextFrame();
      if (bulletModel.allOutLeave) {
        allOutLeaveCallBack(bulletId);
      }
    });
  }
}
