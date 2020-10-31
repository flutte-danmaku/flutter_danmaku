// 弹幕子弹
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';

class FlutterDanmakuBulletProvider {
  Size bulletSize;
  int showTime;
  double offsetY;
  FlutterDanmakuTrack track;
  final int timestamp = DateTime.now().millisecondsSinceEpoch;

  FlutterDanmakuBulletProvider(this.bulletSize, this.showTime, this.offsetY, this.track);
}

class FlutterDanmakuBullet extends StatefulWidget {
  FlutterDanmakuBullet(this.text, this.config);
  String text;
  FlutterDanmakuBulletProvider config;

  Function dispose;

  @override
  State<FlutterDanmakuBullet> createState() => FlutterDanmakuBulletState();
}

class FlutterDanmakuBulletState extends State<FlutterDanmakuBullet> with SingleTickerProviderStateMixin {
  double offsetX = 0;

  AnimationController controller;
  Animation<double> curve;
  Animation<double> animation;

  double rate = FlutterDanmakuConfig.bulletRate;

  @override
  void initState() {
    super.initState();
    initAnimation();
  }

  void initAnimation() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: (widget.config.showTime * rate).toInt()));
    curve = CurvedAnimation(parent: controller, curve: Curves.linear);
    animation = Tween<double>(begin: FlutterDanmakuConfig.areaSize.width, end: -widget.config.bulletSize.width).animate(curve)..addListener(animationListener);
    controller.forward();
  }

  updateBulletConfig() {
    widget.config.bulletSize = FlutterDanmakuUtils.getDanmakuBulletSizeByText(widget.text);
    widget.config.showTime = FlutterDanmakuUtils.getBulletShowTime(widget.config.bulletSize.width);
  }

  void animationListener() {
    bool needChangeOffset = false;
    // 轨道数值有变
    if (widget.config.offsetY != widget.config.track.offsetTop) {
      // 超出屏幕的弹幕直接销毁
      if (FlutterDanmakuUtils.isTrackOverflowArea(widget.config.track)) return _dispose();
      updateBulletConfig();
      needChangeOffset = true;
    }
    setState(() {
      offsetX = animation.value;
      if (needChangeOffset) widget.config.offsetY = widget.config.track.offsetTop;
    });
    if (rate != FlutterDanmakuConfig.bulletRate) {
      resetRate();
    }
    if (animation.isCompleted) {
      _dispose();
    }
  }

  resetRate() {
    controller.stop();
    controller.duration = Duration(milliseconds: (widget.config.showTime * FlutterDanmakuConfig.bulletRate).toInt());
    controller.forward();
  }

  void _dispose() {
    controller.dispose();
    widget.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(offsetX, widget.config.offsetY),
      child: Text(
        widget.text,
        style: TextStyle(fontSize: FlutterDanmakuConfig.bulletLableSize, color: Colors.blueGrey, fontWeight: FontWeight.normal),
      ),
    );
  }
}
