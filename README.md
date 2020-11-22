# 👏 Flutter Danmaku
<img src="https://socialify.git.ci/flutte-danmaku/flutter_danmaku/image?description=1&descriptionEditable=a%20normal%20danmaku%20by%20flutter.%20live%20comment%20hohoho%F0%9F%98%8A%20all%20in%20dart.&font=Source%20Code%20Pro&language=1&pattern=Overlapping%20Hexagons&theme=Light&submit" alt="flutter_danmaku" width="400" />  <br />
[![Coverage Status](https://coveralls.io/repos/github/flutte-danmaku/flutter_danmaku/badge.svg?branch=dev)](https://coveralls.io/github/flutte-danmaku/flutter_danmaku?branch=dev)
![Flutter CI](https://github.com/flutte-danmaku/flutter_danmaku/workflows/Flutter%20CI/badge.svg)
[![pub package](https://img.shields.io/pub/v/flutter_danmaku.svg)](https://pub.dev/packages/flutter_danmaku)
一个普通的flutter弹幕项目。纯dart项目

[![Watch the video](https://i.loli.net/2020/11/18/LCjhTrm56Ypinls.png)](https://youtu.be/APfIEgJct4I)

## Features
* 色彩弹幕
* 静止弹幕
* 滚动弹幕
* 底部弹幕
* 可变速
* 调整大小
* 配置透明度
* 调整展示区域
* 播放 && 暂停
* 自定义弹幕背景
* 弹幕点击回调

## How to use

1. Depend on it
Add this to your package's pubspec.yaml file:

[![pub package](https://img.shields.io/pub/v/flutter_danmaku.svg)](https://pub.dev/packages/flutter_danmaku)

``` json
dependencies:
  flutter_danmaku: ^least
```


2. Install it
You can install packages from the command line:

with Flutter:

``` bash
$ flutter pub get
```

3. Import it

Now in your Dart code, you can use:

``` Dart
import 'package:flutter_danmaku/flutter_danmaku.dart';
```



``` Dart
class _MyHomePageState extends State<MyHomePage> {
    GlobalKey<FlutterDanmakuAreaState> danmakuarea = GlobalKey();

    void addDanmaku () {
        String text = 'hello world!';
        danmakuarea
            .currentState.
            addDanmaku(text);
    }

    @override
    void initState() {
        super.initState();
        // page mounted after
        Future.delayed(Duration(milliseconds: 500), () {
        danmuarea.currentState.init();
        });
    }

    @override
    Widget build (BuildContext context) {
        return FlutterDanmakuArea(key: danmakuarea, child: Container(height: 220, width: double.infinity)),
    }
}
```


# API

## FlutterDanmakuArea

``` dart
@override
Widget build (BuildContext context) {
    return FlutterDanmakuArea(
        key: danmakuarea, 
        // 子弹单击回调
        bulletTapCallBack: handleBulletTap,
        child: Container(height: 220, width: double.infinity)),
}

void handleBulletTap(FlutterDanmakuBulletModel bulletModel) {
    print(bulletModel.text);
}
```

### Widget child
将需要展示在弹幕下方的画面放进去

### Function(FlutterDanmakuBulletModel) bulletTapCallBack;
子弹单击的回调

## FlutterDanmakuAreaState
通过globalKey调用

``` dart
GlobalKey<FlutterDanmakuAreaState> danmakuarea = GlobalKey();

FlutterDanmakuArea(key: danmakuarea, child: Container(height: 220, width: double.infinity)),

danmakuarea.currentState.init()
```

### init
在页面渲染之后 需要初始化的时候调用 会启动定时器渲染

### dipose
页面销毁时调用，会清空数据并且停止定时器

### addDanmaku

``` dart
AddBulletResBody addDanmaku(
    String text,
    {
        Color color,
        FlutterDanmakuBulletType bulletType,
        FlutterDanmakuBulletPosition position,
        Widget Function(Text) builder
    }
)
```

通过调用addDanmaku来将弹幕展示在屏幕上

``` dart
enum AddBulletResBody {
    noSpace, // 没空间
    success // 成功
}
```

| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
|  text  | String |   弹幕的文字（必填  | / |  
|  color  | Color |   弹幕的颜色 | Colors.black|  
| bulletType | FlutterDanmakuBulletType | 弹幕从右边滚动到左边 或者 弹幕居中静止展示 | FlutterDanmakuBulletType.scroll|
| position | FlutterDanmakuBulletPosition | 按顺序注入弹幕 或者 只注入到底部弹幕（注入的弹幕只为静止弹幕 |FlutterDanmakuBulletPosition.any |  
| builder | Widget Function(Text) | 需要自定义弹幕背景 通过编写builder函数来实现 | null |  


### resizeArea

``` dart
void resizeArea({
    Size size // default context.size
})
```

| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
| size | Size | 改变子视图尺寸并等待视图渲染完成后调用 通常用于切换全屏 参数可选 不传默认为子组件context.size | context.size |  

### pause & play

暂停或者播放弹幕

``` dart
void pause()
void play()
```

| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
| / | / | / | / |  

### changeShowArea
改变显示区域百分比
``` dart
void changeShowArea(double parcent)
```
| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
| parcent | double | 展示显示区域百分比 0～1 | 1 |  

### changeRate
改变弹幕播放速率

``` dart
void changeRate(double rate)
```

| Params |  Type | Description | default |
| ------ | -------- | ----------  | ------- |
| rate | double | 修改弹幕播放速率，通常用于倍速播放 大于0即可 1为正常速度 | 1 |

### changeLableSize
改变文字大小

``` dart
void changeLableSize(int fontSize)
```

| Params |  Type | Description | default |
| ------ | -------- | ----------  | ------- |
| fontSize | int | 修改文字大小 会将所有弹幕文字大小调整 | 14

### changeOpacity
改变弹幕透明度

``` dart
void changeOpacity(int opacity)
```

| Params |  Type | Description | default |
| ------ | -------- | ----------  | ------- |
| opacity | double | 修改文字透明度 会将所有弹幕文字透明度调整 0 ～ 1 | 1



<hr>
<hr>

## 感谢

感谢[@sxsdjkk](https://github.com/sxsdjkk)对本项目的code review以及相关指导和修改意见。 


感谢我的直属领导@银翼的魔术师。带领的团队拥有非常open的技术氛围，给予我较为宽松的技术成长环境。