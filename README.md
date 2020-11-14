# 👏 Flutter Danmaku
<img src="https://socialify.git.ci/flutte-danmaku/flutter_danmaku/image?description=1&descriptionEditable=a%20normal%20danmaku%20by%20flutter.%20live%20comment%20hohoho%F0%9F%98%8A%20all%20in%20dart.&font=Source%20Code%20Pro&language=1&pattern=Overlapping%20Hexagons&theme=Light" alt="flutter_danmaku" width="300" />  <br />
[![Coverage Status](https://coveralls.io/repos/github/flutte-danmaku/flutter_danmaku/badge.svg?branch=dev)](https://coveralls.io/github/flutte-danmaku/flutter_danmaku?branch=dev)
![Flutter CI](https://github.com/flutte-danmaku/flutter_danmaku/workflows/Flutter%20CI/badge.svg)

A normal Flutter danmaku project. live comment hohoho😊 all in dart.

## Features
* Color barrag
* Floating barrage
* Scroll barrage
* Bottom barrage
* Variable speed
* Variable font size
* Configure transparency
* Display area ratio
* pause & play


## How to use

``` Dart
import 'package:flutter_danmaku/flutter_danmaku.dart';
```

``` Dart
class _MyHomePageState extends State<MyHomePage> {
    GlobalKey<FlutterDanmakuAreaState> danmakuarea = GlobalKey();

    void addDanmaku () {
        int random = Random().nextInt(20);
        danmakuarea.currentState.addDanmaku('s' + 's' * random, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
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