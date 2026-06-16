part of '../__router_main_test.dart';

Future<void> runDialogResultTests() async {
  testWidgets('Dialog: Getting Result back from Dialog', (
    WidgetTester tester,
  ) async {
    print("*** START: runDialogResultTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const Text("Home Page")),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Biến để hứng kết quả
    String? capturedResult;

    // 2. Mở Dialog và ĐỢI (không dùng await ở đây vì sẽ làm kẹt Test, dùng .then)
    print("Step 1: Opening Dialog and waiting for result");
    Utils.router!
        .showDialog<String>(
          "/select-lang",
          builder: (c, s) => ElevatedButton(
            key: const Key("selectViButton"),
            onPressed: () => Utils.router!.popRoute("vi_VN"), // Trả về kết quả
            child: const Text("Select Vietnamese"),
          ),
        )
        .then((value) {
          capturedResult = value; // Hứng kết quả khi dialog đóng
        });

    await tester.pumpAndSettle();
    expect(Utils.router!.stack.length, 2);

    // 3. Giả lập hành động chọn ngôn ngữ (Đóng Dialog)
    print("Step 2: Selecting language and closing dialog");
    await tester.tap(find.byKey(const Key("selectViButton")));
    await tester.pumpAndSettle();

    // 4. KIỂM TRA KẾT QUẢ
    // Stack phải về lại 1
    expect(Utils.router!.stack.length, 1);
    // Quan trọng nhất: Kết quả phải được truyền đúng về biến capturedResult
    expect(capturedResult, "vi_VN");
    print("@@@ Captured Result: $capturedResult");

    print("*** DONE: runDialogResultTests - CÁ CHÉP HÓA RỒNG!");
  });
}
