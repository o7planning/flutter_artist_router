part of '../__router_main_test.dart';

// Đi: /home -> /filter -> /song.
// Tại /song, gọi off('/supplier'). Stack nội bộ: [/home, /filter, /supplier].
// Nhấn BACK lần 1: Về /filter (OK). Stack: [/home, /filter].
// Nhấn BACK lần 2: Mong đợi về /home, nhưng thực tế đang bị kẹt.

class OffHomePage extends BasePage {
  static const String path = "/home";

  const OffHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toFilter"),
    onPressed: () => Utils.router!.to("/filter"),
    child: const Text("Go to Filter"),
  );
}

class OffFilterPage extends BasePage {
  static const String path = "/filter";

  const OffFilterPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toSong"),
    onPressed: () => Utils.router!.to("/song"),
    child: const Text("Go to Song"),
  );
}

class OffSongPage extends BasePage {
  static const String path = "/song";

  const OffSongPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("offToSupplier"),
    onPressed: () => Utils.router!.off("/supplier"),
    child: const Text("Off to Supplier"),
  );
}

class OffSupplierPage extends BasePage {
  static const String path = "/supplier";

  const OffSupplierPage({super.key});

  @override
  Widget buildBody(BuildContext context) => const Text("Supplier Page");
}

Future<void> runOffSyncTests() async {
  testWidgets('Navigation: Off sync with Browser History test', (
    WidgetTester tester,
  ) async {
    print("*** START: runOffSyncTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const OffHomePage()),
        FaRoute(path: "/filter", builder: (c, s) => const OffFilterPage()),
        FaRoute(path: "/song", builder: (c, s) => const OffSongPage()),
        FaRoute(path: "/supplier", builder: (c, s) => const OffSupplierPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();
    bridge.activeIds.add(Utils.router!.stack.first.id);

    // 1. Đi theo luồng: Home -> Filter -> Song
    await Utils.pressByKey(tester: tester, key: 'toFilter');
    bridge.activeIds.add(Utils.router!.stack.last.id);
    await tester.pumpAndSettle();

    await Utils.pressByKey(tester: tester, key: 'toSong');
    bridge.activeIds.add(Utils.router!.stack.last.id);
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 3);
    print("Step 1: Stack is [Home, Filter, Song]");

    // 2. Thực hiện OFF: Song -> Supplier (Thay thế Song bằng Supplier)
    await Utils.pressByKey(tester: tester, key: 'offToSupplier');
    bridge.activeIds.add(Utils.router!.stack.last.id);
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 3);
    expect(Utils.router!.stack[2].path, "/supplier");
    expect(Utils.router!.stack.any((k) => k.path == "/song"), isFalse);
    print("Step 2: Stack is [Home, Filter, Supplier]");

    // 3. GIẢ LẬP NHẤN BACK LẦN 1 (Từ Supplier về Filter)
    // Step 3: Back 1 (Supplier -> Filter)
    print("Step 3: Back 1 (Supplier -> Filter)");

    // Tìm delegate một cách an toàn hơn:
    final delegate = tester.allElements
        .where((e) => e.widget is Router)
        .map(
          (e) =>
              (e.widget as Router).routerDelegate
                  as FlutterArtistRouterDelegate,
        )
        .first; // Không dùng .single để tránh lỗi nếu có nhiều router ẩn

    await tester.runAsync(() async {
      // Giả lập trình duyệt báo về URL /filter
      await delegate.setNewRoutePath(const RouteKey("/filter", "back_event_1"));
    });

    await tester.pumpAndSettle();

    // 4. GIẢ LẬP NHẤN BACK LẦN 2 (Từ Filter về Home) - ĐÂY LÀ CHỖ DỄ LỖI
    print("Step 4: Back 2 (Filter -> Home)");
    await tester.runAsync(() async {
      await delegate.setNewRoutePath(const RouteKey("/home", "back_2"));
    });
    await tester.pumpAndSettle();

    expect(find.byType(OffHomePage), findsOneWidget);
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.first.path, "/home");

    print("*** DONE: runOffSyncTests - PASSED!");
  });
}
