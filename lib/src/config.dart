import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';

class FlutterDanmakuConfig {
  static Duration bulletBaseShowDuration = Duration(seconds: 3);
  static double bulletLableSize = 14;
  static final LayerLink danmakuAreaLayerLink = LayerLink();

  static double bulletRate = 1.0;

  static Size areaSize;
  // 展示区域百分比
  static double showAreaPercent = 1.0;
}

class FlutterDanmakuUtils {
  // 获取文字的长度
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
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    renderParagraph.layout(constraints);
    double textwidth = renderParagraph.getMinIntrinsicWidth(FlutterDanmakuConfig.bulletLableSize).ceilToDouble();
    double textheight = renderParagraph.getMinIntrinsicHeight(999).ceilToDouble();
    return Size(textwidth, textheight);
  }

  // 根据文字长度计算展示时间
  static int getBulletShowTime(double bulletWidth) {
    double scale = 5;
    return FlutterDanmakuConfig.bulletBaseShowDuration.inMilliseconds - (bulletWidth * scale).toInt();
  }

  // 轨道是否允许被插入
  static bool trackAllowInsert(FlutterDanmakuTrack track, Size needInsertBulletSize) {
    if (track.lastBullet == null) return true;
    FlutterDanmakuBullet lastBullet = track.lastBullet;
    double lastBulletRunDistance = bulletNowDistance(lastBullet);
    // 如果上一个子弹跑的距离 大于需要注入的子弹宽度
    return lastBulletRunDistance > needInsertBulletSize.width;
  }

  // 算子弹现在跑了多少距离
  static double bulletNowDistance(
    FlutterDanmakuBullet bullet,
  ) {
    int now = DateTime.now().millisecondsSinceEpoch;
    int bulletAppendTime = bullet.config.timestamp;
    int bulletShowTime = (bullet.config.showTime * FlutterDanmakuConfig.bulletRate).toInt();
    // 跑了多久
    int runTime = now - bulletAppendTime;
    return FlutterDanmakuConfig.areaSize.width * (runTime / bulletShowTime);
  }

  // 注入子弹
  static void appendBulletToScreen(BuildContext context, FlutterDanmakuBullet bullet) {
    OverlayEntry oe = buildBulletOE(bullet);
    bullet.dispose = oe.remove;
    Overlay.of(context).insert(oe);
  }

  // 轨道是否溢出
  static bool isTrackOverflowArea(FlutterDanmakuTrack track) {
    return (track.offsetTop + track.trackHeight) > FlutterDanmakuConfig.areaSize.height * FlutterDanmakuConfig.showAreaPercent;
  }

  static OverlayEntry buildBulletOE(FlutterDanmakuBullet bullet) {
    OverlayEntry oe = OverlayEntry(builder: (BuildContext context) {
      return Positioned(
          left: 0, top: 0, child: CompositedTransformFollower(offset: Offset(0, 0), link: FlutterDanmakuConfig.danmakuAreaLayerLink, child: bullet));
    });
    return oe;
  }
}
