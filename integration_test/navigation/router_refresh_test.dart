part of '../__router_main_test.dart';

class RefreshProductPage extends BasePage {
  static const String path = "/product/:id";

  const RefreshProductPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    final routeData = ModalRoute.of(context)!.settings.arguments as FaRouteData;

    final id = routeData.state.params['id'];

    return Text("Product $id", key: const Key("productText"));
  }
}

Future<void> runRefreshTests() async {
  testWidgets('History: Browser Refresh Deep Link Restore', (tester) async {
    print("*** START: runRefreshTests");

    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/product/42",
      routes: [
        FaRoute(
          path: "/product/:id",
          builder: (c, s) => const RefreshProductPage(),
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

    expect(find.text("Product 42"), findsOneWidget);
    expect(Utils.router!.stack.length, 1);

    print("*** DONE: runRefreshTests");
  });
}
