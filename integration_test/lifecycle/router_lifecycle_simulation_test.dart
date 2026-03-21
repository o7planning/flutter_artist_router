part of '../__router_main_test.dart';

class FlutterArtistSimulator {
  // Thuộc tính Lazy gây đau đầu
  static late String apiKey;
  static bool _isConfigured = false;

  static Future<void> config() async {
    print("@@@ Simulator: Đang cấu hình (chờ 2s)...");
    await Future.delayed(const Duration(seconds: 2));
    apiKey = "FA-12345-ARTIST"; // Khởi tạo giá trị late
    _isConfigured = true;
    print("@@@ Simulator: Cấu hình XONG!");
  }
}

class SimulatedAuthGuard extends FaRouteGuard {
  @override
  Future<bool> canActivate(FaRouteState state) async {
    // Nếu gọi dòng này trước khi config() xong -> LateInitializationError
    print("@@@ Guard: Đang kiểm tra API Key: ${FlutterArtistSimulator.apiKey}");
    return FlutterArtistSimulator.apiKey.isNotEmpty;
  }

  @override
  Future<String?> redirect(FaRouteState state) async => "/login";
}

Future<void> runLifecycleSimulationTest() async {
  // Bỏ cái bọc testWidgets dư thừa ở ngoài đi ông giáo nhé
  testWidgets('Lifecycle Standard: Config must complete before UI build', (
    WidgetTester tester,
  ) async {
    print("*** START: runLifecycleSimulationTest");

    // 1. Chuẩn bị Router
    final router = FlutterArtistRouter(
      bridge: TestRouterBridge(),
      initialLocation: "/admin",
      routes: [
        FaRoute(
          path: "/admin",
          builder: (c, s) => const Text("Admin Dashboard"),
          guards: [SimulatedAuthGuard()],
        ),
      ],
    );

    // 2. VÒNG GỬI XE: Đợi config xong xuôi (Mô phỏng hàm main chuẩn)
    await FlutterArtistSimulator.config();

    // 3. VÀO CỔNG: Sau khi config xong mới cho phép pumpWidget
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: router),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    // 4. KIỂM TRA: Đợi frame và check kết quả
    await tester.pumpAndSettle();

    expect(find.text("Admin Dashboard"), findsOneWidget);
    print("*** DONE: runLifecycleSimulationTest - XANH MƯỚT!");
  });
}
