import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';

class FlutterDanmakuUtils {
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

  // 根据文字长度计算每一帧需要run多少距离
  static double getBulletEveryFramerateRunDistance(double bulletWidth) {
    assert(bulletWidth > 0);
    return FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale);
  }

  // 算轨道相对可用区域是否溢出
  static bool isEnableTrackOverflowArea(FlutterDanmakuTrack track) => track.offsetTop + track.trackHeight > FlutterDanmakuConfig.showAreaHeight;

  // 轨道注入子弹是否会碰撞
  static bool trackInsertBulletHasBump(FlutterDanmakuBulletModel trackLastBullet, Size needInsertBulletSize) {
    // 是否离开了右边的墙壁
    if (!trackLastBullet.allOutRight) return true;
    double willInsertBulletEveryFramerateRunDistance = FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width);
    // 要注入的节点速度比上一个快
    if (willInsertBulletEveryFramerateRunDistance > trackLastBullet.everyFrameRunDistance) {
      // 是否会追尾
      // 将要注入的弹幕全部离开减去上一个弹幕宽度需要的时间
      double willInsertBulletLeaveScreenRemainderTime =
          remainderTimeLeaveScreen(0, 0, FlutterDanmakuUtils.getBulletEveryFramerateRunDistance(needInsertBulletSize.width));
      return trackLastBullet.leaveScreenRemainderTime > willInsertBulletLeaveScreenRemainderTime;
    } else {
      return false;
    }
  }

  // 子弹剩余多少帧离开屏幕
  static double remainderTimeLeaveScreen(double runDistance, double textWidth, double everyFramerateDistance) {
    assert(runDistance >= 0);
    assert(textWidth >= 0);
    assert(everyFramerateDistance > 0);
    double remanderDistance = (FlutterDanmakuConfig.areaSize.width + textWidth) - runDistance;
    return remanderDistance / everyFramerateDistance;
  }
}
