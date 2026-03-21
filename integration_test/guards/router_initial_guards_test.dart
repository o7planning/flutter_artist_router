part of '../__router_main_test.dart';

Future<void> runInitialGuardsTests() async {
  testWidgets('Guards: Initial Location Redirection', (
    WidgetTester tester,
  ) async {
    print("*** START: Initial Guard Test");
    final bridge = TestRouterBridge();
    final rootGuard = TestGuard(); // Guard này sẽ chặn trang "/"
    rootGuard.allow = false; // Mặc định không cho vào

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/",
      routes: [
        FaRoute(
          path: "/",
          builder: (c, s) => const Text("Home Page"),
          guards: [rootGuard], // Chặn ngay tại gốc
        ),
        FaRoute(path: "/login", builder: (c, s) => const Text("Login Page")),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    // Đợi cho Router xử lý redirection
    await tester.pumpAndSettle();

    // KỲ VỌNG: Không được thấy "Home Page", mà phải thấy "Login Page"
    expect(find.text("Login Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/login");

    print("*** DONE: Initial Guard Test");
  });
}
