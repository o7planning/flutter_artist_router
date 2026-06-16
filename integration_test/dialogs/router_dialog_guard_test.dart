part of '../__router_main_test.dart';

Future<void> runDialogGuardTests() async {
  testWidgets('Dialog: Guards Protection and Redirection', (
    WidgetTester tester,
  ) async {
    print("*** START: runDialogGuardTests");
    final bridge = TestRouterBridge();
    final authGuard = TestGuard(); // Lớp Guard của ông giáo

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      globalGuards: [], // Có thể test cả Global Guard ở đây nếu muốn
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

    // --- TRƯỜNG HỢP 1: BỊ CHẶN (allow = false) ---
    print("Step 1: Opening Protected Dialog while NOT allowed");
    authGuard.allow = false;

    // Cố gắng mở Dialog rút tiền
    Utils.router!.showDialog(
      "/withdraw",
      builder: (c, s) => const Text("Withdraw Money Content"),
      guards: [authGuard], // Gắn bảo vệ vào đây
    );

    await tester.pumpAndSettle();

    // KỲ VỌNG:
    // 1. Dialog không được xuất hiện.
    // 2. Router phải tự động Redirect sang /login (theo logic của TestGuard).
    expect(find.text("Withdraw Money Content"), findsNothing);
    expect(find.text("Login Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/login");

    // --- TRƯỜNG HỢP 2: ĐƯỢC CHO PHÉP (allow = true) ---
    print("Step 2: Opening Protected Dialog while allowed");
    authGuard.allow = true;
    Utils.router!.offAll("/home"); // Quay lại Home làm lại cuộc đời
    await tester.pumpAndSettle();

    Utils.router!.showDialog(
      "/withdraw",
      builder: (c, s) => const Text("Withdraw Money Content"),
      guards: [authGuard],
    );

    await tester.pumpAndSettle();

    // KỲ VỌNG: Dialog xuất hiện hiên ngang
    expect(find.text("Withdraw Money Content"), findsOneWidget);
    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.last.isDialog, isTrue);

    print("*** DONE: runDialogGuardTests - AN TOÀN TUYỆT ĐỐI!");
  });
}
