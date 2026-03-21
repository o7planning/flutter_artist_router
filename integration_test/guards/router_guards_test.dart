part of '../__router_main_test.dart';

class TestGuard extends FaRouteGuard {
  bool allow = false;

  @override
  Future<bool> canActivate(FaRouteState state) async => allow;

  @override
  Future<String?> redirect(FaRouteState state) async => allow ? null : "/login";
}

Future<void> runGuardsTests() async {
  testWidgets('Guards: Blocking and Redirecting', (WidgetTester tester) async {
    print("*** START: runGuardsTests");
    final bridge = TestRouterBridge();
    final authGuard = TestGuard();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/",
      routes: [
        FaRoute(
          path: "/",
          builder: (c, s) => ElevatedButton(
            key: const Key("toAdminButton"),
            onPressed: () => Utils.router!.to("/admin"),
            child: const Text("Go Admin"),
          ),
        ),
        FaRoute(
          path: "/admin",
          builder: (c, s) => const Text("Admin Page"),
          guards: [authGuard],
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
    await tester.pumpAndSettle();

    // 1. Case: Blocked (allow = false) -> Phải bị redirect về Login
    authGuard.allow = false;
    await Utils.pressByKey(tester: tester, key: 'toAdminButton');
    expect(find.text("Login Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/login");

    // 2. Case: Allowed (allow = true) -> Phải vào được Admin
    authGuard.allow = true;
    // Quay về home để bấm lại
    Utils.router!.offAll("/");
    await tester.pumpAndSettle();

    await Utils.pressByKey(tester: tester, key: 'toAdminButton');
    expect(find.text("Admin Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/admin");

    print("*** DONE: runGuardsTests");
  });
}
