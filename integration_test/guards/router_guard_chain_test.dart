part of '../__router_main_test.dart';

// Người dùng cố vào /dashboard.
// Guard A chặn lại: "Chưa đăng nhập!" -> Đẩy sang /login.
// Tại /login, Guard B lại chặn: "Chưa chọn Server vùng!" -> Đẩy sang /select-server.
// Kết quả: Router phải tự động "nhảy" 2 lần và dừng lại đúng tại /select-server.

/// Guard 1: Requires Authentication
class AuthCheckGuard extends FaRouteGuard {
  bool isAuthenticated = false;

  @override
  Future<bool> canActivate(FaRouteState state) async => isAuthenticated;

  @override
  Future<String?> redirect(FaRouteState state) async => "/login";
}

/// Guard 2: Requires Server Selection (only for Login page)
class ServerCheckGuard extends FaRouteGuard {
  bool isServerSelected = false;

  @override
  Future<bool> canActivate(FaRouteState state) async => isServerSelected;

  @override
  Future<String?> redirect(FaRouteState state) async => "/select-server";
}

Future<void> runGuardChainTests() async {
  testWidgets('Router: Multi-level Guard Redirect Chain', (
    WidgetTester tester,
  ) async {
    print("*** START: runGuardChainTests");
    final bridge = TestRouterBridge();
    final authGuard = AuthCheckGuard();
    final serverGuard = ServerCheckGuard();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const Text("Home")),
        FaRoute(
          path: "/dashboard",
          builder: (c, s) => const Text("Dashboard"),
          guards: [authGuard], // Protected by Auth
        ),
        FaRoute(
          path: "/login",
          builder: (c, s) => const Text("Login Page"),
          guards: [
            serverGuard,
          ], // Login itself is protected by Server Selection
        ),
        FaRoute(
          path: "/select-server",
          builder: (c, s) => const Text("Select Server"),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // THỰC THI: Cố gắng vào Dashboard khi chưa có gì cả
    print("Step: Navigating to /dashboard -> Expecting chain redirect");
    Utils.router!.to("/dashboard");

    // Đợi Router xử lý chuỗi đệ quy nội bộ
    await tester.pumpAndSettle();

    // KIỂM TRA:
    // 1. Phải dừng lại ở Select Server
    expect(find.text("Select Server"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/select-server");

    // 2. Dashboard và Login không được nằm trong Stack (vì dùng NavigationAction.replace trong logic redirect)
    expect(find.text("Dashboard"), findsNothing);
    expect(find.text("Login Page"), findsNothing);

    print("*** DONE: runGuardChainTests - CHAIN REDIRECT SUCCESS!");
  });
}
