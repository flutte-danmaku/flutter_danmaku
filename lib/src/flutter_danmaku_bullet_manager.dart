import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';

class FlutterDanmakuBulletUtils {
  // 计算文字尺寸
  static Size getDanmakuBulletSizeByText(String text) {
    final constraints = BoxConstraints(
      maxWidth: 999.0, // maxwidth calculated
      minHeight: 0.0,
      minWidth: 0.0,
    );
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: text,
        style: TextStyle(
          fontSize: FlutterDanmakuConfig.bulletLableSize,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    renderParagraph.layout(constraints);
    double textwidth = renderParagraph.getMinIntrinsicWidth(FlutterDanmakuConfig.bulletLableSize).ceilToDouble();
    double textheight = renderParagraph.getMinIntrinsicHeight(999).ceilToDouble();
    return Size(textwidth, textheight);
  }

  // 初始化一个子弹
  static FlutterDanmakuBulletModel initBullet(String text, UniqueKey trackId, Size bulletSize, double offsetY) {
    UniqueKey bulletId = UniqueKey();
    double everyRunDistance = FlutterDanmakuBulletUtils.getBulletEveryFramerateRunDistance(bulletSize.width);
    FlutterDanmakuBulletModel bullet = FlutterDanmakuBulletModel(
        id: bulletId, trackId: trackId, text: text, bulletSize: bulletSize, offsetY: offsetY, everyFrameRunDistance: everyRunDistance);
    // 记录到表上
    FlutterDanmakuManager.bullets[bullet.id] = bullet;
    return bullet;
  }

  // 根据文字长度计算每一帧需要run多少距离
  static double getBulletEveryFramerateRunDistance(double bulletWidth) {
    double baseRunDistance = 1;
    return baseRunDistance + (bulletWidth / 150);
  }

  static void removeBulletById(UniqueKey bulletId) {
    FlutterDanmakuManager.bullets.remove(bulletId);
    FlutterDanmakuManager.tracks.removeWhere((element) => element.lastBulletId == bulletId);
  }

  // 剩余多少帧离开屏幕
  static double remainderTimeLeaveScreen(double runDistance, double textWidth, double everyFramerateDistance) {
    double remanderDistance = (FlutterDanmakuConfig.areaSize.width + textWidth) - runDistance;
    return remanderDistance / everyFramerateDistance;
  }

  // 构建子弹
  static Widget buildBulletToScreen(BuildContext context, FlutterDanmakuBulletModel bulletModel) {
    FlutterDanmakuBullet bullet = FlutterDanmakuBullet(bulletModel.id, bulletModel.text);
    return Positioned(right: bulletModel.runDistance - bulletModel.bulletSize.width, top: bulletModel.offsetY, child: bullet);
  }

  static List<Widget> buildAllBullet(BuildContext context) {
    return FlutterDanmakuManager.bullets.values.toList().map((e) => buildBulletToScreen(context, e)).toList();
  }
}
