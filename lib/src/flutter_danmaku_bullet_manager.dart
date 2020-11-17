import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_track.dart';

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
  static FlutterDanmakuBulletModel initBullet(String text, UniqueKey trackId, Size bulletSize, double offsetY,
      {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll,
      FlutterDanmakuBulletPosition position,
      Color color,
      Widget Function(Text) builder}) {
    assert(bulletSize.height > 0);
    assert(bulletSize.width > 0);
    assert(offsetY >= 0);
    UniqueKey bulletId = UniqueKey();
    FlutterDanmakuBulletModel bullet = FlutterDanmakuBulletModel(
        color: color,
        id: bulletId,
        trackId: trackId,
        text: text,
        position: position,
        bulletSize: bulletSize,
        offsetY: offsetY,
        bulletType: bulletType,
        builder: builder);
    // 记录到表上
    FlutterDanmakuManager.recordBullet(bullet);
    return bullet;
  }

  // 根据文字长度计算每一帧需要run多少距离
  static double getBulletEveryFramerateRunDistance(double bulletWidth) {
    assert(bulletWidth > 0);
    return FlutterDanmakuConfig.baseRunDistance + (bulletWidth / FlutterDanmakuConfig.everyFramerateRunDistanceScale);
  }

  static void removeBulletById(UniqueKey bulletId, {FlutterDanmakuBulletType bulletType = FlutterDanmakuBulletType.scroll}) {
    assert(FlutterDanmakuManager.hasBulletKey(bulletId));
    FlutterDanmakuManager.removeBulletByKey(bulletId);
    FlutterDanmakuTrackManager.removeTrackByBulletId(bulletId);
  }

  // 构建子弹
  static Widget buildBulletToScreen(BuildContext context, FlutterDanmakuBulletModel bulletModel, {Widget Function(Text) builder}) {
    FlutterDanmakuBullet bullet = FlutterDanmakuBullet(bulletModel.id, bulletModel.text, color: bulletModel.color);
    return Positioned(right: bulletModel.offsetX, top: bulletModel.offsetY, child: bullet);
  }

  static List<Widget> buildAllBullet(BuildContext context) {
    return FlutterDanmakuManager.bullets.map((e) => buildBulletToScreen(context, e)).toList();
  }

  // 剩余多少帧离开屏幕
  static double remainderTimeLeaveScreen(double runDistance, double textWidth, double everyFramerateDistance) {
    assert(runDistance >= 0);
    assert(textWidth >= 0);
    assert(everyFramerateDistance > 0);
    double remanderDistance = (FlutterDanmakuConfig.areaSize.width + textWidth) - runDistance;
    return remanderDistance / everyFramerateDistance;
  }

  // 重制子弹数值
  static recountBulletsOffset() {
    // 写的非常脏 但是太累了
    FlutterDanmakuManager.bullets.map((FlutterDanmakuBulletModel bullet) {
      FlutterDanmakuTrack track = FlutterDanmakuManager.tracks.firstWhere((element) => element.id == bullet.trackId, orElse: () => null);
      if (track == null) return;
      bullet.offsetY = track.offsetTop;
      bullet.bulletSize = FlutterDanmakuBulletUtils.getDanmakuBulletSizeByText(bullet.text);
    });
  }
}
