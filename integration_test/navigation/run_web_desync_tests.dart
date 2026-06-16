part of '../__router_main_test.dart';

class WebSyncHomePage extends BasePage {
  static const String path = "/home";

  const WebSyncHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("btnGoToProduct"),
    onPressed: () => Utils.router!.to("/product"),
    child: const Text("Go to Product"),
  );
}

class WebSyncProductPage extends BasePage {
  static const String path = "/product";

  const WebSyncProductPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("btnCallRouterPop"),
    onPressed: () => Utils.router!.pop(), // Gọi Đoạn code 1 của ông giáo
    child: const Text("Call Router Pop"),
  );
}

Future<void> runWebDesyncTests() async {
  testWidgets('Web Sync Bug: Browser URL Desync when calling router.pop()', (
    WidgetTester tester,
  ) async {
    print("*** START: runWebDesyncTests");
    final bridge = TestRouterBridge();

    // Giả lập hệ thống có RouteInformationProvider của trình duyệt Web
    final routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: Uri(path: "/home")),
    );

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routeInfoProvider: routeInformationProvider,
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const WebSyncHomePage()),
        FaRoute(
          path: "/product",
          builder: (c, s) => const WebSyncProductPage(),
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
    bridge.activeIds.add(Utils.router!.stack.first.id);

    // 1. Mô phỏng bấm nút để sang trang Product: Stack = [/home, /product]
    print("Step 1: Clicking button to go to /product");
    await Utils.pressByKey(tester: tester, key: 'btnGoToProduct');
    bridge.activeIds.add(Utils.router!.stack.last.id);
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.last.path, "/product");
    expect(
      routeInformationProvider.value.uri.path,
      "/product",
    ); // Trình duyệt chuyển sang /product chuẩn

    // 2. Mô phỏng bấm nút để gọi Đoạn code 1 (Chạy lệnh Navigator.pop cưỡng chế)
    print("Step 2: Clicking button to call router.pop()");
    await Utils.pressByKey(tester: tester, key: 'btnCallRouterPop');
    await tester.pumpAndSettle();

    // KIỂM TRA TRẠNG THÁI STACK VÀ UI:
    // UI đã quay về Home Page nhờ cơ chế onDidRemovePage giải cứu Stack
    expect(find.byType(WebSyncHomePage), findsOneWidget);
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.last.path, "/home");

    //  ĐÂY LÀ CHỖ ĐOẠN CODE 1 SẼ BỊ CHẾT TEST (XUẤT HIỆN BUG):
    // Vì Navigator.of(context).pop() của Đoạn code 1 không thông báo cho Browser biết.
    // Kết quả: UI thì về Home rồi, nhưng thanh URL bar của trình duyệt vẫn đứng im ở `/product`!
    final currentBrowserUrl = routeInformationProvider.value.uri.path;
    print("Real Browser URL Bar holds: $currentBrowserUrl");

    expect(
      currentBrowserUrl,
      "/home",
    ); // <-- SẼ BỊ ĐỎ TEST TẠI ĐÂY (Do giá trị thực tế vẫn là "/product")

    print("*** DONE: runWebDesyncTests");
  });
}
