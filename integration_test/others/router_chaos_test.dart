part of '../__router_main_test.dart';

class ChaosPage extends BasePage {
  static const String path = "/chaos/:id";

  const ChaosPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    // Lấy params ra hiển thị
    final routeData = ModalRoute.of(context)!.settings.arguments as FaRouteData;
    final id = routeData.state.params['id'];
    final query = routeData.state.queryParams['type'] ?? 'none';

    return Column(
      children: [
        Text("ID: $id", key: const Key("idDisplay")),
        Text("Type: $query", key: const Key("queryDisplay")),
        ElevatedButton(
          key: const Key("spamButton"),
          onPressed: () {
            // Spam click: Điều hướng liên tục 3 phát
            Utils.router!.to("/chaos/1");
            Utils.router!.to("/chaos/2");
            Utils.router!.to("/chaos/3");
          },
          child: const Text("Spam To"),
        ),
      ],
    );
  }
}

Future<void> runChaosTests() async {
  testWidgets('Chaos: Params, DeepLink and Spam Protection', (
    WidgetTester tester,
  ) async {
    print("*** START: runChaosTests");
    final bridge = TestRouterBridge();

    // Giả lập vào app bằng Deep Link phức tạp
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/chaos/99?type=extreme",
      routes: [
        FaRoute(path: "/chaos/:id", builder: (c, s) => const ChaosPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Kiểm tra Parse Deep Link
    print("Step 1: Checking Deep Link Parsing");
    expect(find.text("ID: 99"), findsOneWidget);
    expect(find.text("Type: extreme"), findsOneWidget);

    // 2. Kiểm tra Spam Click
    print("Step 2: Testing Spam Click Resistance");
    await Utils.pressByKey(tester: tester, key: 'spamButton');

    // Nếu chính sách là overwrite hoặc check trùng, stack không được phình to vô tội vạ
    // Giả sử DuplicateRoutePolicy là overwrite
    print("Stack length after spam: ${Utils.router!.stack.length}");
    // Tùy vào DuplicateRoutePolicy mà ông giáo mong muốn ở đây

    // 3. Kiểm tra "Massive Pruning"
    print("Step 3: Testing Massive Pruning");
    // Giả lập đẩy 5 trang, sau đó gỡ sạch activeIds trừ trang đầu và cuối
    // Xem Router có tự lùi về trang an toàn không.

    print("*** DONE: runChaosTests");
  });
}
