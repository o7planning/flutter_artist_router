part of '../__router_main_test.dart';

class ForwardHomePage extends BasePage {
  static const String path = "/";

  const ForwardHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toA"),
    onPressed: () => Utils.router!.to("/a"),
    child: const Text("Go to A"),
  );
}

class ForwardAPage extends BasePage {
  static const String path = "/a";

  const ForwardAPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toB"),
    onPressed: () => Utils.router!.to("/b"),
    child: const Text("Go to B"),
  );
}

class ForwardBPage extends BasePage {
  static const String path = "/b";

  const ForwardBPage({super.key});

  @override
  Widget buildBody(BuildContext context) => const Text("Page B");
}

Future<void> runForwardHistoryTests() async {
  testWidgets('History: Browser Forward into Dead Route', (tester) async {
    print("*** START: runForwardHistoryTests");

    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/",
      routes: [
        FaRoute(path: "/", builder: (c, s) => const ForwardHomePage()),
        FaRoute(path: "/a", builder: (c, s) => const ForwardAPage()),
        FaRoute(path: "/b", builder: (c, s) => const ForwardBPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    await tester.pumpAndSettle();

    bridge.activeIds.add(Utils.router!.stack.first.id);

    await Utils.pressByKey(tester: tester, key: 'toA');
    final idA = Utils.router!.stack.last.id;
    bridge.activeIds.add(idA);

    await tester.pumpAndSettle();

    await Utils.pressByKey(tester: tester, key: 'toB');
    final idB = Utils.router!.stack.last.id;
    bridge.activeIds.add(idB);

    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 3);

    /// BACK -> /a
    final routerWidget =
        tester.allElements.firstWhere((e) => e.widget is Router).widget
            as Router;

    final delegate = routerWidget.routerDelegate as FlutterArtistRouterDelegate;

    await tester.runAsync(() async {
      await delegate.setNewRoutePath(const RouteKey("/a", "back_event"));
    });

    await tester.pumpAndSettle();

    /// Kill B
    bridge.activeIds.remove(idB);

    /// FORWARD -> /b (ghost)
    await tester.runAsync(() async {
      await delegate.setNewRoutePath(const RouteKey("/b", "forward_event"));
    });

    await tester.pumpAndSettle();

    /// Router must stay at /a
    expect(find.byType(ForwardAPage), findsOneWidget);
    expect(Utils.router!.stack.last.path, "/a");

    print("*** DONE: runForwardHistoryTests");
  });
}
