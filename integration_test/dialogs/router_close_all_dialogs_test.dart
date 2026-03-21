part of '../__router_main_test.dart';

Future<void> runCloseAllDialogTests() async {
  testWidgets('Dialog: closeAllDialogs Stress Test', (
    WidgetTester tester,
  ) async {
    print("*** START: runCloseAllDialogTests");
    final bridge = TestRouterBridge();

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

    // 1. Mở dồn dập 3 cái Dialog - KHÔNG await để đi tiếp
    print("Step 1: Opening 3 dialogs");

    // Gọi và không chờ đợi
    Utils.router!.dialog("/d1", builder: (c, s) => const Text("D1 Content"));
    Utils.router!.dialog("/d2", builder: (c, s) => const Text("D2 Content"));
    // Cái cuối cùng có thể await hoặc gọi pump để Frame bắt kịp
    Utils.router!.dialog("/d3", builder: (c, s) => const Text("D3 Content"));

    // Ép Flutter render toàn bộ stack mới
    await tester.pumpAndSettle();

    // Kiểm tra Stack: 1 Home + 3 Dialogs = 4
    expect(Utils.router!.stack.length, 4);
    expect(find.text("D3 Content"), findsOneWidget);

    // 2. Quét sạch bằng closeAllDialogs
    print("Step 2: Closing all dialogs at once");
    Utils.router!.closeAllDialogs();
    await tester.pumpAndSettle();

    // 3. Kiểm tra kết quả
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.last.path, "/home");
    expect(find.text("D1 Content"), findsNothing);
    expect(find.text("D3 Content"), findsNothing);
    expect(find.text("Home Page"), findsOneWidget);

    print("*** DONE: runCloseAllDialogTests - NGON LÀNH!");
  });
}
