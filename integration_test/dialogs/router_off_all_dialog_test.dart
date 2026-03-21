part of '../__router_main_test.dart';

Future<void> runOffAllWithDialogTests() async {
  testWidgets('Navigation: offAll must clear both Pages and Dialogs', (
    WidgetTester tester,
  ) async {
    print("*** START: runOffAllWithDialogTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const Text("Home Page")),
        FaRoute(path: "/login", builder: (c, s) => const Text("Login Page")),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Mở một Dialog bất kỳ
    print("Step 1: Opening a Dialog over Home Page");
    Utils.router!.dialog(
      "/my-dialog",
      builder: (c, s) => const Text("Dialog Content"),
    );
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2);
    expect(find.text("Dialog Content"), findsOneWidget);

    // 2. Thực hiện lệnh offAll sang Login
    print("Step 2: Executing offAll('/login')");
    await Utils.router!.offAll("/login");
    await tester.pumpAndSettle();

    // 3. KIỂM TRA ĐỘ "SẠCH"
    // Stack chỉ được phép còn duy nhất 1 phần tử là /login
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.last.path, "/login");

    // UI không được còn bóng dáng của Dialog hay trang Home cũ
    expect(find.text("Dialog Content"), findsNothing);
    expect(find.text("Home Page"), findsNothing);
    expect(find.text("Login Page"), findsOneWidget);

    print("*** DONE: runOffAllWithDialogTests - SẠCH BONG KÍN KÍT!");
  });
}
