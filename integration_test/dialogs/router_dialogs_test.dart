part of '../__router_main_test.dart';

class DialogHomePage extends BasePage {
  static const String path = "/dialog-home";

  const DialogHomePage({super.key});

  @override
  Widget buildBody(BuildContext context) => Center(
    child: ElevatedButton(
      key: const Key("openDialogButton"),
      onPressed: () {
        Utils.router!.showDialog(
          "/my-dialog",
          builder: (c, s) => Container(
            key: const Key("dialogContent"),
            width: 200,
            height: 200,
            color: Colors.white,
            child: ElevatedButton(
              key: const Key("closeDialogButton"),
              onPressed: () => Utils.router!.popRoute("Dialog Closed"),
              child: const Text("Close Me"),
            ),
          ),
        );
      },
      child: const Text("Open Dialog"),
    ),
  );
}

Future<void> runDialogTests() async {
  testWidgets('Dialog: Open, Close and Barrier Dismissal', (
    WidgetTester tester,
  ) async {
    print("*** START: runDialogTests");
    final bridge = TestRouterBridge();

    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/dialog-home",
      routes: [
        FaRoute(
          path: "/dialog-home",
          builder: (c, s) => const DialogHomePage(),
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

    // 1. Mở Dialog
    print("Step 1: Opening Dialog");
    await Utils.pressByKey(tester: tester, key: 'openDialogButton');

    expect(find.byKey(const Key("dialogContent")), findsOneWidget);
    expect(Utils.router!.stack.length, 2);
    expect(Utils.router!.stack.last.isDialog, isTrue);

    // 2. Đóng Dialog bằng nút bấm bên trong
    print("Step 2: Closing Dialog via button");
    await Utils.pressByKey(tester: tester, key: 'closeDialogButton');

    expect(find.byKey(const Key("dialogContent")), findsNothing);
    expect(Utils.router!.stack.length, 1);

    // 3. Mở lại Dialog để test Barrier Dismissal
    print("Step 3: Testing Barrier Dismissal");
    await Utils.pressByKey(tester: tester, key: 'openDialogButton');
    expect(Utils.router!.stack.length, 2);

    // Nhấn vào tọa độ cực biên (vùng Barrier - thường là góc màn hình)
    // Navigator 2.0 của FlutterArtist phải bắt được sự kiện pop này
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("dialogContent")), findsNothing);
    expect(Utils.router!.stack.length, 1);

    print("*** DONE: runDialogTests");
  });
}
