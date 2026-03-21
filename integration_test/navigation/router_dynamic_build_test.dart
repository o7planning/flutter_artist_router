part of '../__router_main_test.dart';

Future<void> runDynamicBuilderTests() async {
  testWidgets('Navigation: Dynamic Builder protection for to() and off()', (
    WidgetTester tester,
  ) async {
    print("*** START: runDynamicBuilderTests");
    final bridge = TestRouterBridge();

    // Khởi tạo Router chỉ với 1 route duy nhất là /home
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const Text("Home Page")),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. TEST to() với builder động (Trang /dynamic chưa hề được định nghĩa trước)
    print("Step 1: Testing to() with dynamic builder");
    Utils.router!.to(
      "/dynamic",
      builder: (c, s) => const Text("Dynamic Page Content"),
    );
    await tester.pumpAndSettle();

    expect(find.text("Dynamic Page Content"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/dynamic");

    // 2. TEST off() với builder động
    print("Step 2: Testing off() with dynamic builder");
    Utils.router!.off(
      "/replaced",
      builder: (c, s) => const Text("Replaced Page Content"),
    );
    await tester.pumpAndSettle();

    expect(find.text("Replaced Page Content"), findsOneWidget);
    expect(find.text("Dynamic Page Content"), findsNothing);
    expect(Utils.router!.stack.length, 2); // /home và /replaced

    // 3. TEST offAll() với builder động
    print("Step 3: Testing offAll() with dynamic builder");
    Utils.router!.offAll(
      "/root-dynamic",
      builder: (c, s) => const Text("Root Dynamic Content"),
    );
    await tester.pumpAndSettle();

    expect(find.text("Root Dynamic Content"), findsOneWidget);
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.last.path, "/root-dynamic");

    print("*** DONE: runDynamicBuilderTests - BUILDER IS SAFE!");
  });
}
