part of '../__router_main_test.dart';

class ResultAPage extends StatefulWidget {
  static const String path = "/result-a";

  const ResultAPage({super.key});

  @override
  State<ResultAPage> createState() => _ResultAPageState();
}

class _ResultAPageState extends State<ResultAPage> {
  String receivedData = "Waiting...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(receivedData, key: const Key("dataDisplay")),
          ElevatedButton(
            key: const Key("goToBButton"),
            onPressed: () async {
              // Đợi dữ liệu từ trang B
              final result = await Utils.router!.to("/result-b");
              if (result != null) {
                setState(() => receivedData = result.toString());
              }
            },
            child: const Text("Go to B"),
          ),
        ],
      ),
    );
  }
}

class ResultBPage extends BasePage {
  static const String path = "/result-b";

  const ResultBPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("backWithDataButton"),
    onPressed: () => Utils.router!.popRoute("Hello Artist"),
    // Trả dữ liệu về
    child: const Text("Back with Data"),
  );
}

Future<void> runResultTests() async {
  testWidgets('Result: Passing data back from Pop', (
    WidgetTester tester,
  ) async {
    print("*** START: runResultTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/result-a",
      routes: [
        FaRoute(path: "/result-a", builder: (c, s) => const ResultAPage()),
        FaRoute(path: "/result-b", builder: (c, s) => const ResultBPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Kiểm tra trạng thái ban đầu
    expect(find.text("Waiting..."), findsOneWidget);

    // 2. Sang trang B
    await Utils.pressByKey(tester: tester, key: 'goToBButton');
    expect(Utils.router!.stack.length, 2);

    // 3. Bấm nút Back ở trang B để trả dữ liệu về A
    await Utils.pressByKey(tester: tester, key: 'backWithDataButton');

    // Đợi Animation và State cập nhật ở trang A
    await tester.pumpAndSettle();

    // 4. Kiểm tra xem trang A đã nhận được dữ liệu chưa
    expect(find.text("Hello Artist"), findsOneWidget);
    expect(Utils.router!.stack.length, 1);

    print("*** DONE: runResultTests");
  });
}
