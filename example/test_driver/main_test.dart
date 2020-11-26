// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('send bullet', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('send more bullet', () async {
      await Future.delayed(Duration(seconds: 3));
      final bulletFinder = find.byValueKey('incrementBullet');
      // Record a performance profile as the app scrolls through
      // the list of items.
      final timeline = await driver.traceAction(() async {
        for (int i = 0; i < 100; i++) {
          await driver.tap(bulletFinder);
        }
      });

      await Future.delayed(Duration(seconds: 3));

      // Convert the Timeline into a TimelineSummary that's easier to
      // read and understand.
      final summary = new TimelineSummary.summarize(timeline);

      // Then, save the summary to disk.
      await summary.writeSummaryToFile('tap_summary', pretty: true);

      // Optionally, write the entire timeline to disk in a json format.
      // This file can be opened in the Chrome browser's tracing tools
      // found by navigating to chrome://tracing.
      await summary.writeTimelineToFile('tap_summary_timeline', pretty: true);
    });
  });
}
