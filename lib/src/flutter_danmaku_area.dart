// 弹幕主场景
import 'package:flutter/material.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:flutter_danmaku/src/config.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_bullet_manager.dart';
import 'package:flutter_danmaku/src/flutter_danmaku_controller.dart';

class FlutterDanmakuArea extends StatefulWidget {
  FlutterDanmakuArea({Key key, @required this.child, @required this.controller}) : super(key: key);

  final Widget child;

  FlutterDanmakuController controller;

  Function(FlutterDanmakuBulletModel) bulletTapCallBack;

  @override
  State<FlutterDanmakuArea> createState() => FlutterDanmakuAreaState();
}

class FlutterDanmakuAreaState extends State<FlutterDanmakuArea> {
  FlutterDanmakuController controller;

  @override
  void initState() {
    super.initState();
    assert(widget.controller != null);
    widget.controller.setState = setState;
    widget.controller.context = context;
    controller = widget.controller;
  }

  // 构建全部的子弹
  List<Widget> buildAllBullet(BuildContext context) {
    return List.generate(controller.bullets.length, (index) => buildBulletToScreen(context, controller.bullets[index]));
  }

  // 构建子弹
  Widget buildBulletToScreen(BuildContext context, FlutterDanmakuBulletModel bulletModel) {
    FlutterDanmakuBullet bullet = FlutterDanmakuBullet(bulletModel.id, bulletModel.text, color: bulletModel.color, builder: bulletModel.builder);
    return Positioned(
        right: bulletModel.offsetX,
        top: bulletModel.offsetY + FlutterDanmakuConfig.areaOfChildOffsetY,
        child: FlutterDanmakuConfig.bulletTapCallBack == null
            ? bullet
            : GestureDetector(onTap: () => FlutterDanmakuConfig.bulletTapCallBack(bulletModel), child: bullet));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: widget.child,
        ),
        ...buildAllBullet(context)
      ],
    );
  }
}
