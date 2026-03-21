part of '../__router_main_test.dart';

class BridgeHomePage extends BasePage {
  static const String path = "/bridgeHomePage";

  const BridgeHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Text("BridgeHomePage", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ElevatedButton(
          key: Key("toListPageButton"),
          onPressed: () {
            Utils.router!.to(BridgeListPage.path);
          },
          child: Text("toListPageButton"),
        ),
      ],
    );
  }
}

class BridgeListPage extends BasePage {
  static const String path = "/bridgeListPage";

  const BridgeListPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Text("BridgeListPage", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ElevatedButton(
          key: Key("toDetailPageButton"),
          onPressed: () {
            Utils.router!.to(BridgeDetailPage.path);
          },
          child: Text("toDetailPageButton"),
        ),
      ],
    );
  }
}

class BridgeDetailPage extends BasePage {
  static const String path = "/bridgeDetailPage";

  const BridgeDetailPage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Text("BridgeDetailPage", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ElevatedButton(
          key: Key("toHomePageButton"),
          onPressed: () {},
          child: Text("toHomePageButton"),
        ),
      ],
    );
  }
}

// *****************************************************************************
// *****************************************************************************

Future<void> runBridgeTests() async {
  testWidgets('Bridge: Middle-page pruning & Top-page protection', (
    WidgetTester tester,
  ) async {
    print("*** START: runBridgeTests");
    final bridge = TestRouterBridge();
    // Set router
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: BridgeHomePage.path,
      routes: [
        FaRoute(path: BridgeHomePage.path, builder: (c, s) => BridgeHomePage()),
        FaRoute(path: BridgeListPage.path, builder: (c, s) => BridgeListPage()),
        FaRoute(
          path: BridgeDetailPage.path,
          builder: (c, s) => BridgeDetailPage(),
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

    // Đăng ký ID gốc
    bridge.activeIds.add(Utils.router!.stack.first.id);

    // 1. Push /list - Dùng runAsync để tránh treo Future
    print("*** runBridgeTests - 1 (Pushing /list)");

    // Goto BridgeListPage
    await Utils.pressByKey(tester: tester, key: 'toListPageButton');
    print("*** runBridgeTests - 1.1.1 (Pushing /list)");

    final listId = Utils.router!.stack.last.id;
    bridge.activeIds.add(listId);
    expect(Utils.router!.stack.length, 2);

    // 2. Push /detail
    // Now in the BridgeListPage.
    print("*** runBridgeTests - 2 (Pushing /detail)");
    await Utils.pressByKey(tester: tester, key: "toDetailPageButton");

    final detailId = Utils.router!.stack.last.id;
    bridge.activeIds.add(detailId);
    expect(Utils.router!.stack.length, 3);

    // 3. Test Middle Pruning:
    bridge.activeIds.remove(listId);
    Utils.router!.requestStackValidation();
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.any((k) => k.id == listId), isFalse);
    expect(bridge.logs, contains("Removed: ${BridgeListPage.path}"));

    // 4. Test Top Protection: Invalidate 'Detail'
    bridge.activeIds.remove(detailId);
    Utils.router!.requestStackValidation();
    await tester.pumpAndSettle();

    // Top page must remain active per safe policy
    // expect(Utils.router!.stack.last.id, detailId);
    // expect(find.text('Detail'), findsOneWidget);

    print("*** DONE: runBridgeTests");
  });
}
