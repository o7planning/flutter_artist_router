part of '../__router_main_test.dart';

Future<void> runDuplicatePolicyTests() async {
  // Hàm phụ trợ để dựng App nhanh cho từng Policy
  Future<void> setupDuplicateTest(
    WidgetTester tester,
    DuplicateRoutePolicy policy,
  ) async {
    final bridge = TestRouterBridge();
    Utils.router = FlutterArtistRouter(
      bridge: bridge,
      initialLocation: "/home",
      duplicatePolicy: policy,
      routes: [
        FaRoute(
          path: "/home",
          builder: (c, s) => ElevatedButton(
            key: const Key("btnToA"),
            onPressed: () => Utils.router!.to("/a"),
            child: const Text("Go to A"),
          ),
        ),
        FaRoute(
          path: "/a",
          builder: (c, s) => ElevatedButton(
            key: const Key("btnToA_Again"),
            onPressed: () => Utils.router!.to("/a"),
            child: const Text("Go to A Again"),
          ),
        ),
        FaRoute(path: "/b", builder: (c, s) => const Text("Page B")),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: FlutterArtistRouterDelegate(router: Utils.router!),
        routeInformationParser: FlutterArtistRouteParser(),
      ),
    );
    await tester.pumpAndSettle();
  }

  // --- 1. SKIP ---
  testWidgets('Duplicate Policy: SKIP', (WidgetTester tester) async {
    print("*** START: Duplicate SKIP");
    await setupDuplicateTest(tester, DuplicateRoutePolicy.skip);

    await Utils.pressByKey(tester: tester, key: 'btnToA'); // Lần 1 vào A
    expect(Utils.router!.stack.length, 2);

    await Utils.pressByKey(
      tester: tester,
      key: 'btnToA_Again',
    ); // Lần 2 (bị Skip)
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2); // Vẫn chỉ có [Home, A]
    print("Scenario 1: Skip PASSED");
  });

  // --- 2. OVERWRITE ---
  testWidgets('Duplicate Policy: OVERWRITE', (WidgetTester tester) async {
    print("*** START: Duplicate OVERWRITE");
    await setupDuplicateTest(tester, DuplicateRoutePolicy.overwrite);

    await Utils.pressByKey(tester: tester, key: 'btnToA'); // [Home, A(1)]
    final oldId = Utils.router!.stack.last.id;

    await Utils.pressByKey(tester: tester, key: 'btnToA_Again'); // [Home, A(2)]
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 2);
    expect(
      Utils.router!.stack.last.id != oldId,
      isTrue,
    ); // ID phải mới (đã ghi đè)
    print("Scenario 2: Overwrite PASSED");
  });

  // --- 3. AUTO SUFFIX ---
  testWidgets('Duplicate Policy: AUTO SUFFIX', (WidgetTester tester) async {
    print("*** START: Duplicate AUTO SUFFIX");
    await setupDuplicateTest(tester, DuplicateRoutePolicy.autoSuffix);

    await Utils.pressByKey(tester: tester, key: 'btnToA');
    await Utils.pressByKey(tester: tester, key: 'btnToA_Again');
    await tester.pumpAndSettle();

    expect(Utils.router!.stack.length, 3); // Chấp nhận [Home, A, A]
    print("Scenario 3: AutoSuffix PASSED");
  });

  // --- 4. THROW ERROR ---
  testWidgets('Duplicate Policy: THROW ERROR', (WidgetTester tester) async {
    print("*** START: Duplicate THROW ERROR");
    await setupDuplicateTest(tester, DuplicateRoutePolicy.throwError);

    // 1. Vào trang A lần đầu (Thành công)
    await Utils.pressByKey(tester: tester, key: 'btnToA');
    await tester.pumpAndSettle();

    dynamic capturedError;

    await runZonedGuarded(
      () async {
        await tester.tap(find.byKey(const Key("btnToA_Again")));
        await tester.pump(); // trigger callback
      },
      (error, stack) {
        capturedError = error;
      },
    );

    // Kiểm tra xem có đúng là ném ra lỗi trùng lặp không
    expect(capturedError, isNotNull);
    print("********* capturedError: $capturedError");
    expect(capturedError, isA<DuplicateRouteError>());

    print("Scenario 4: ThrowError PASSED (Exception caught correctly)");
  });
}
