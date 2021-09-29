# 👏 Flutter Danmaku
<img src="https://socialify.git.ci/flutte-danmaku/flutter_danmaku/image?description=1&descriptionEditable=a%20normal%20danmaku%20by%20flutter.%20live%20comment%20hohoho%F0%9F%98%8A%20all%20in%20dart.&font=Source%20Code%20Pro&language=1&pattern=Overlapping%20Hexagons&theme=Light&submit" alt="flutter_danmaku" width="400" />  <br />
[![Coverage Status](https://coveralls.io/repos/github/flutte-danmaku/flutter_danmaku/badge.svg?branch=dev)](https://coveralls.io/github/flutte-danmaku/flutter_danmaku?branch=dev)
![Flutter CI](https://github.com/flutte-danmaku/flutter_danmaku/workflows/Flutter%20CI/badge.svg)
[![pub package](https://img.shields.io/pub/v/flutter_danmaku.svg)](https://pub.dev/packages/flutter_danmaku)
一个普通的flutter弹幕项目。纯dart项目

[https://github.com/a62527776a/read-record/issues/5](https://github.com/a62527776a/read-record/issues/5) 设计思路

- [👏 Flutter Danmaku](#-flutter-danmaku)
  - [Features](#features)
  - [live&nbsp;demo](#livedemo)
  - [How to use](#how-to-use)
- [API](#api)
  - [FlutterDanmakuArea](#flutterdanmakuarea)
    - [Widget child](#widget-child)
  - [FlutterDanmakuController](#flutterdanmakucontroller)
    - [init(Size size)](#initsize-size)
    - [dipose](#dipose)
    - [addDanmaku](#adddanmaku)
    - [resizeArea](#resizearea)
    - [pause&play](#pauseplay)
    - [changeShowArea](#changeshowarea)
    - [changeRate](#changerate)
    - [changeLableSize](#changelablesize)
    - [changeOpacity](#changeopacity)
    - [setBulletTapCallBack](#setbullettapcallback)
    - [clearScreen](#clearscreen)
  - [Tip](#tip)
    - [如何seek弹幕](#如何seek弹幕)
  - [感谢](#感谢)

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

## live&nbsp;demo

https://a62527776a.github.io/flutter_danmaku_demo/index.html  web demo

[![Watch the video](https://i.loli.net/2020/11/18/LCjhTrm56Ypinls.png)](https://youtu.be/APfIEgJct4I)

## How to use

1. Depend on it
Add this to your package's pubspec.yaml file:

[![pub package](https://img.shields.io/pub/v/flutter_danmaku.svg)](https://pub.dev/packages/flutter_danmaku)

``` json
dependencies:
  flutter_danmaku: ^latest
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
    FlutterDanmakuController flutterDanmakuController = FlutterDanmakuController();

    void addDanmaku () {
        String text = 'hello world!';
        flutterDanmakuController.
            addDanmaku(text);
    }

    // 幕布尺寸
    Size get areaSize => Size(MediaQuery.of(context).size.width, 220)

    @override
    void initState() {
        super.initState();
        // page mounted after
        Future.delayed(Duration(milliseconds: 500), () {
          // 初始化弹幕
        flutterDanmakuController.init(areaSize);
        flutterDanmakuController.addDanmaku('hello world')
        });
    }

    @override
    Widget build (BuildContext context) {
        return Stack(
            children: [
              // 比如这个是在弹幕下面的播放器
              Container(height: areaSize.height, width: areaSize.width),
              FlutterDanmakuArea(controller: flutterDanmakuController),
            ],
          ),
    }
}
```


# API

## FlutterDanmakuArea

``` dart
@override
Widget build (BuildContext context) {
    return Stack(
        children: [
          // 比如这个是在弹幕下面的播放器
          Container(height: 220, width: areaSize.width),
          FlutterDanmakuArea(controller: flutterDanmakuController),
        ],
      ),
}
```

### Widget child
将需要展示在弹幕下方的画面放进去

## FlutterDanmakuController

``` dart
Stack(
  children: [
    // 比如这个是在弹幕下面的播放器
    Container(height: 220, width: MediaQuery.of(context).size.width),
    FlutterDanmakuArea(controller: flutterDanmakuController),
  ],
)
// 需要在页面渲染完之后初始化
flutterDanmakuController.init(Size(MediaQuery.of(context).size.width, 220))

```

### init(Size size)
在页面渲染之后 需要初始化的时候调用 会启动定时器渲染

| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
| size | Size | 初始化幕布 宽高不能用double.infinity | / |  

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
        int offsetMS
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
| offsetMS | int | 弹幕偏移量 | 插入弹幕偏移量 用于弹幕seek 需要先清空屏幕 然后按照偏移量从大到小的顺序插入 |  


### resizeArea

``` dart
void resizeArea(Size size)
```

| Params |  Type | Description | default |  
| ------ | -------- | ----------  | ------- |  
| size | Size | 改变视图尺寸并等待视图渲染完成后调用 通常用于切换全屏 宽高不能用double.infinity | / |  

### pause&play

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

### setBulletTapCallBack
设置子弹单击事件

``` dart
void setBulletTapCallBack(Function(FlutterDanmakuBulletModel))
```

### clearScreen
清空全部弹幕

``` dart
void clearScreen()
```

<hr>
<hr>

## Tip

### 如何seek弹幕  
比如视频seek到3:10:55  
需要取出3:07:55 ~ 3:10:55这三秒内的所有弹幕
按照最早到最晚的排序 调用addDanmaku 传入offsetMS参数
就能实现按照时间轴seek弹幕

``` dart

  danmakuSeek() {
    // 先清空屏幕
    flutterDanmakuController.clearScreen();
    // 取出seek前3秒到seek时间区间的所有弹幕
    // 需要按照时间偏移量从早到晚排序好
    random100().forEach((randomInt) {
      addOffsetDanmaku(randomInt);
    });
  }

  List<int> random100() {
    // 模拟seek时间的毫秒偏移量
    List<int> randomList = List.generate(100, (index) => Random().nextInt(3000))..sort();
    return randomList.reversed.toList();
  }

  addOffsetDanmaku(int offsetMS) {
    int random = Random().nextInt(20);
    flutterDanmakuController.addDanmaku('s' + 's' * random, offsetMS: offsetMS, builder: (Text textWidget) {
      return Container(
        child: textWidget,
        decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      );
    }, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
  }

```


## 感谢

感谢[@sxsdjkk](https://github.com/sxsdjkk)对本项目的code review以及相关指导和修改意见。 


感谢我的直属领导@银翼的魔术师。带领的团队拥有非常open的技术氛围，给予我较为宽松的技术成长环境。
