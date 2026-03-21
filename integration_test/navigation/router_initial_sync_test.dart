part of '../__router_main_test.dart';

// Refresh tại Path đúng: Hệ thống phải giữ nguyên trang /filter-examples.
// Refresh tại Path "Lạ": Hệ thống phải tự động lùi về initialLocation (trong case này là /basic-examples).

Future<void> runInitialSyncTests() async {
  // --- CASE 1: REFRESH TẠI PATH ĐÚNG ---
  testWidgets('Initial Sync: Keep valid path on refresh', (
    WidgetTester tester,
  ) async {
    print("*** START: runInitialSyncTests - Valid Path");

    // Giả lập trình duyệt đang ở /filter-examples khi app vừa bật
    final routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri(path: "/filter-examples"),
      ),
    );

    Utils.router = FlutterArtistRouter(
      bridge: TestRouterBridge(),
      initialLocation: "/basic-examples", // Fallback
      routeInfoProvider: routeInformationProvider,
      routes: [
        FaRoute(
          path: "/basic-examples",
          builder: (c, s) => const Text("Basic Page"),
        ),
        FaRoute(
          path: "/filter-examples",
          builder: (c, s) => const Text("Filter Page"),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
        routeInformationProvider: routeInformationProvider,
      ),
    );
    await tester.pumpAndSettle();

    // KIỂM TRA: Phải đứng ở Filter Page ngay lập tức
    expect(find.text("Filter Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/filter-examples");
    print("Step 1: Successfully stayed at /filter-examples");
  });

  // --- CASE 2: REFRESH TẠI PATH KHÔNG TỒN TẠI (GHOST START) ---
  testWidgets('Initial Sync: Fallback to initialLocation on invalid path', (
    WidgetTester tester,
  ) async {
    print("*** START: runInitialSyncTests - Invalid Path");

    // Giả lập trình duyệt đang ở /unknown-path
    final routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(
        uri: Uri(path: "/unknown-path"),
      ),
    );

    Utils.router = FlutterArtistRouter(
      bridge: TestRouterBridge(),
      initialLocation: "/basic-examples", // Phải về đây
      routeInfoProvider: routeInformationProvider,
      routes: [
        FaRoute(
          path: "/basic-examples",
          builder: (c, s) => const Text("Basic Page"),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
        routeInformationProvider: routeInformationProvider,
      ),
    );
    await tester.pumpAndSettle();

    // KIỂM TRA: Hệ thống phải tự lái về Basic Page
    expect(find.text("Basic Page"), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/basic-examples");
    print("Step 2: Successfully fallback to /basic-examples");
  });
}
