part of '../__router_main_test.dart';

class NavHomePage extends BasePage {
  static const String path = "/";

  const NavHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("toAPageButton"),
    onPressed: () => Utils.router!.to("/a"),
    child: const Text("Go to A"),
  );
}

class NavAPage extends BasePage {
  static const String path = "/a";

  const NavAPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("offToBPageButton"),
    onPressed: () => Utils.router!.off("/b"),
    child: const Text("Replace with B"),
  );
}

class NavBPage extends BasePage {
  static const String path = "/b";

  const NavBPage({super.key});

  @override
  Widget buildBody(BuildContext context) => ElevatedButton(
    key: const Key("offAllToHomeButton"),
    onPressed: () => Utils.router!.offAll("/"),
    child: const Text("Clear all to Home"),
  );
}

Future<void> runNavigationTests() async {
  testWidgets('Navigation: Basic to, off, and offAll flow', (
    WidgetTester tester,
  ) async {
    print("*** START: runNavigationTests");
    final bridge = TestRouterBridge();
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/",
      routes: [
        FaRoute(path: "/", builder: (c, s) => const NavHomePage()),
        FaRoute(path: "/a", builder: (c, s) => const NavAPage()),
        FaRoute(path: "/b", builder: (c, s) => const NavBPage()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Test TO: Home -> A
    await Utils.pressByKey(tester: tester, key: 'toAPageButton');
    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.last.path, "/a");

    // 2. Test OFF: A -> B (A bị xóa, thay bằng B)
    await Utils.pressByKey(tester: tester, key: 'offToBPageButton');
    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.last.path, "/b");
    expect(Utils.router!.stack.any((k) => k.path == "/a"), isFalse);

    // 3. Test OFFALL: B -> Home (Dọn sạch bách)
    await Utils.pressByKey(tester: tester, key: 'offAllToHomeButton');
    expect(Utils.router!.stack.length, 1);
    expect(Utils.router!.stack.first.path, "/");

    print("*** DONE: runNavigationTests");
  });
}
