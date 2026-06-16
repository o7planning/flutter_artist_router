part of '../__router_main_test.dart';

Future<void> runNestedParamsTests() async {
  testWidgets('Router: Deeply nested path parameters validation', (
    WidgetTester tester,
  ) async {
    print("*** START: runNestedParamsTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home", // ĐẶT TRANG ĐẦU LÀ HOME
      routes: [
        FaRoute(path: "/home", builder: (c, s) => const Text("Home Page")),
        FaRoute(
          path: "/orders/:orderId/details/:type",
          builder: (c, state) => Text(
            "Order:${state.params['orderId']} Type:${state.params['type']}",
          ),
        ),
      ],
    );

    print("Run to here 1: Pumping Widget");
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    // Đợi frame đầu tiên lên trang Home
    await tester.pumpAndSettle();
    print("Run to here 2: At Home Page");

    // Bây giờ mới điều hướng vào vùng "hiểm"
    // KHÔNG await trực tiếp to() nếu nó trả về Future mà không có pop
    Utils.router!.to("/orders/1001/details/invoice");

    print("Run to here 3: Pumping after navigation");
    await tester.pumpAndSettle();

    // Kiểm tra xem data có hiển thị đúng không
    expect(find.text("Order:1001 Type:invoice"), findsOneWidget);

    print("@@@ Test: Nested Params extracted correctly.");
  });
}
