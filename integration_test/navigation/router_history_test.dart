part of '../__router_main_test.dart';

class HistoryHomePage extends BasePage {
  static const String path = "/";

  const HistoryHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toA"),
    onPressed: () => Utils.router!.to("/a"),
    child: const Text("Go to A"),
  );
}

class HistoryAPage extends BasePage {
  static const String path = "/a";

  const HistoryAPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toB"),
    onPressed: () => Utils.router!.to("/b"),
    child: const Text("Go to B"),
  );
}

class HistoryBPage extends BasePage {
  static const String path = "/b";

  const HistoryBPage({super.key});

  @override
  Widget buildBody(BuildContext context) => const Text("Page B - The Survivor");
}

Future<void> runHistoryTests() async {
  testWidgets('History: Browser Back into a Dead Route (Ghost Recovery)', (
    WidgetTester tester,
  ) async {
    print("*** START: runHistoryTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/",
      routes: [
        // DÙNG LẠI CLASS HistoryHomePage ĐÃ CÓ Ở TRÊN ĐỂ ĐẢM BẢO CONSISTENCY
        FaRoute(path: "/", builder: (c, s) => const HistoryHomePage()),
        FaRoute(path: "/a", builder: (c, s) => const HistoryAPage()),
        FaRoute(path: "/b", builder: (c, s) => const HistoryBPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Build Stack: [Home, A, B]
    bridge.activeIds.add(Utils.router!.stack[0].id);

    await Utils.pressByKey(tester: tester, key: 'toA');
    final idA = Utils.router!.stack.last.id;
    bridge.activeIds.add(idA);
    await tester.pumpAndSettle();

    await Utils.pressByKey(tester: tester, key: 'toB');
    final idB = Utils.router!.stack.last.id;
    bridge.activeIds.add(idB);
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 3);

    // 2. "TRẢM" trang A
    print("Step 2: Killing Page A...");
    bridge.activeIds.remove(idA);
    Utils.router!.requestStackValidation();
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2);

    // 3. GIẢ LẬP TRÌNH DUYỆT BẤM BACK (Về trang A đã chết)
    print("Step 3: Simulating Browser Back to /a (The Ghost)");

    final Iterable<Element> candidates = tester.allElements.where(
      (e) => e.widget is Router,
    );
    final routerWidget = candidates.first.widget as Router;
    final delegate = routerWidget.routerDelegate as FlutterArtistRouterDelegate;

    await tester.runAsync(() async {
      await delegate.setNewRoutePath(const RouteKey("/a", "ghost_event"));
    });

    // ĐỢI THÊM 1 TÍ ĐỂ UI STABILIZE
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 4. KIỂM TRA
    print(
      "Final Path in Stack: ${Utils.router!.stack.map((e) => e.path).toList()}",
    );

    // THAY VÌ TÌM TEXT "Home", TÌM CHÍNH CÁI WIDGET TYPE CHO CHẮC ĂN
    expect(find.byType(HistoryHomePage), findsOneWidget);
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.first.path, "/");

    print("*** DONE: runHistoryTests - GHOST RECOVERED!");
  });
}
