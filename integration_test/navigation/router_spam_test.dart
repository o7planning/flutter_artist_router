part of '../__router_main_test.dart';

class RacePage extends BasePage {
  static const String path = "/race/:id";

  const RacePage({super.key});

  @override
  Widget buildBody(BuildContext context) {
    final routeData = ModalRoute.of(context)!.settings.arguments as FaRouteData;

    final id = routeData.state.params['id'];

    return Column(
      children: [
        Text("Race $id"),
        ElevatedButton(
          key: const Key("raceSpam"),
          onPressed: () {
            Utils.router!.to("/race/1");
            Utils.router!.to("/race/2");
            Utils.router!.to("/race/3");
            Utils.router!.to("/race/4");
            Utils.router!.to("/race/5");
          },
          child: const Text("Spam Race"),
        ),
      ],
    );
  }
}

Future<void> runRaceTests() async {
  testWidgets('Navigation: Race Condition Protection', (tester) async {
    print("*** START: runRaceTests");

    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/race/0",
      routes: [FaRoute(path: "/race/:id", builder: (c, s) => const RacePage())],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );

    await tester.pumpAndSettle();

    await Utils.pressByKey(tester: tester, key: "raceSpam");

    await tester.pumpAndSettle();

    expect(find.text("Race 5"), findsOneWidget);

    print("Stack: ${Utils.router!.stack.map((e) => e.path)}");

    expect(Utils.router!.stack.length <= 2, isTrue);

    print("*** DONE: runRaceTests");
  });
}
