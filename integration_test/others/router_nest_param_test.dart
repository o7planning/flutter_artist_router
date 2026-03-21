part of '../__router_main_test.dart';

Future<void> runNestedParamsTests() async {
  testWidgets('Router: Deeply nested path parameters validation', (
    WidgetTester tester,
  ) async {
    final bridge = TestRouterBridge();
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      routes: [
        FaRoute(
          path: "/orders/:orderId/details/:type",
          builder: (c, state) => Text(
            "Order:${state.params['orderId']} Type:${state.params['type']}",
          ),
        ),
      ],
    );

    // Mồi một frame để khởi tạo (Theo chuẩn GetX mà anh em mình đã thống nhất)
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    // Điều hướng vào vùng "hiểm"
    await Utils.router!.to("/orders/1001/details/invoice");
    await tester.pumpAndSettle();

    // Kiểm tra xem data có hiển thị đúng không
    expect(find.text("Order:1001 Type:invoice"), findsOneWidget);
    print("@@@ Test: Nested Params extracted correctly.");
  });
}
