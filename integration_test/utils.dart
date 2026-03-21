import 'package:flutter/material.dart';
import 'package:flutter_artist_router/flutter_artist_router.dart';
import 'package:flutter_test/flutter_test.dart';

class Utils {
  static FlutterArtistRouter? router;

  static Future<void> pressByKey({
    required WidgetTester tester,
    required String key,
  }) async {
    Finder btnFinder = find.byKey(Key(key));
    await tester.tap(btnFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }
}
