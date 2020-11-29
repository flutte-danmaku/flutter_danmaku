import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_danmaku/flutter_danmaku.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  enableFlutterDriverExtension();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool heng = false;

  Size get areaSize => heng ? MediaQuery.of(context).size : Size(MediaQuery.of(context).size.width, 220);

  FlutterDanmakuController flutterDanmakuController = FlutterDanmakuController();

  void clearScreen() {
    flutterDanmakuController.clearScreen();
  }

  void changeShowAreaP(double p) {
    flutterDanmakuController.changeShowArea(p);
  }

  void changeRate(double rate) {
    flutterDanmakuController.changeRate(rate);
  }

  void changeLableSize(int size) {
    flutterDanmakuController.changeLableSize(size);
  }

  void changeShowOpacity(double opacity) {
    flutterDanmakuController.changeOpacity(opacity);
  }

  void parsud() {
    if (flutterDanmakuController.isPause) {
      flutterDanmakuController.play();
    } else {
      flutterDanmakuController.pause();
    }
  }

  addDanmaku() {
    int random = Random().nextInt(20);
    flutterDanmakuController.addDanmaku('s' + 's' * random, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    int random1 = Random().nextInt(20);
    flutterDanmakuController.addDanmaku('s' + 's' * random1,
        bulletType: FlutterDanmakuBulletType.fixed, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
  }

  handleBulletTap(BuildContext context, FlutterDanmakuBulletModel bulletModel) {
    print(bulletModel.text);
  }

  danmakuSeek() {
    flutterDanmakuController.clearScreen();
    random100().forEach((randomInt) {
      addOffsetDanmaku(randomInt);
    });
  }

  List<int> random100() {
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

  addBuilderDanmaku() {
    int random = Random().nextInt(20);
    flutterDanmakuController.addDanmaku('s' + 's' * random, builder: (Text textWidget) {
      return Container(
        child: textWidget,
        decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      );
    }, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
  }

  setBulletTapCallBack(FlutterDanmakuBulletModel bulletModel) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: bulletModel.text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: bulletModel.color,
        fontSize: 16.0);
  }

  void _incrementCounter() {
    addDanmaku();
    addDanmaku();
    addBuilderDanmaku();
    int random = Random().nextInt(20);
    flutterDanmakuController.addDanmaku('s' + 's' * random,
        bulletType: FlutterDanmakuBulletType.fixed, color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      flutterDanmakuController.init(areaSize);
      flutterDanmakuController.setBulletTapCallBack(setBulletTapCallBack);
      this.addDanmaku();
      this.addBuilderDanmaku();
      this.dibudanmu();
      this.addDanmaku();
      this.addBuilderDanmaku();
      this.dibudanmu();
      this.addDanmaku();
      this.addBuilderDanmaku();
      this.dibudanmu();
    });
  }

  hengshuping() {
    // 强制横屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    setState(() {
      heng = true;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      flutterDanmakuController.resizeArea(areaSize);
    });
  }

  void dibudanmu() {
    flutterDanmakuController.addDanmaku('我是底部弹幕我是底部弹幕',
        bulletType: FlutterDanmakuBulletType.fixed,
        position: FlutterDanmakuBulletPosition.bottom,
        color: Colors.primaries[Random().nextInt(Colors.primaries.length)]);
  }

  resethengshuping() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() {
      heng = false;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      flutterDanmakuController.resizeArea(areaSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
      home: Scaffold(
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: SingleChildScrollView(
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: [
                    Container(color: Colors.black, height: areaSize.height, width: areaSize.width),
                    FlutterDanmakuArea(controller: flutterDanmakuController),
                  ],
                ),
                Container(
                    height: 500,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, //横轴三个子widget
                          childAspectRatio: 3),
                      children: [
                        MaterialButton(onPressed: () => danmakuSeek(), child: Text('弹幕seek')),
                        MaterialButton(onPressed: () => dibudanmu(), child: Text('底部弹幕')),
                        MaterialButton(onPressed: () => resethengshuping(), child: Text('复原横屏')),
                        MaterialButton(onPressed: () => clearScreen(), child: Text('清除全部弹幕')),
                        MaterialButton(onPressed: () => changeRate(0.5), child: Text('变倍率0.5')),
                        MaterialButton(onPressed: () => changeRate(0.8), child: Text('变倍率0.8')),
                        MaterialButton(onPressed: () => changeRate(1.2), child: Text('变倍率1.2')),
                        MaterialButton(onPressed: () => changeRate(1.5), child: Text('变倍率1.5')),
                        MaterialButton(onPressed: () => changeRate(3), child: Text('变倍率3')),
                        MaterialButton(onPressed: () => changeLableSize(12), child: Text('change lable Size 12')),
                        MaterialButton(onPressed: () => changeLableSize(16), child: Text('change lable Size 24')),
                        MaterialButton(onPressed: () => changeLableSize(24), child: Text('change lable Size 48')),
                        MaterialButton(onPressed: () => changeShowAreaP(0.3), child: Text('change show area 0.3')),
                        MaterialButton(onPressed: () => changeShowAreaP(0.5), child: Text('change show area 0.5')),
                        MaterialButton(onPressed: () => changeShowAreaP(1.0), child: Text('change show area 1')),
                        MaterialButton(onPressed: () => changeShowOpacity(1.0), child: Text('change show opacity 1')),
                        MaterialButton(onPressed: () => changeShowOpacity(0.5), child: Text('change show opacity 0.5')),
                        MaterialButton(onPressed: () => changeShowOpacity(0.2), child: Text('change show opacity 0.2')),
                        MaterialButton(onPressed: () => hengshuping(), child: Text('横屏')),
                        MaterialButton(onPressed: () => parsud(), child: Text('暂停'))
                      ],
                    )),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: Key('incrementBullet'),
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
