import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_artist_router/flutter_artist_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'base/base_pages.dart';
import 'utils.dart';

part 'bridge/router_bridge_test.dart';
part 'dialogs/router_close_all_dialogs_test.dart';
part 'dialogs/router_dialog_guard_test.dart';
part 'dialogs/router_dialog_result_test.dart';
part 'dialogs/router_dialogs_test.dart';
part 'dialogs/router_off_all_dialog_test.dart';
part 'guards/router_guard_chain_test.dart';
part 'guards/router_guards_test.dart';
part 'guards/router_initial_guards_test.dart';
// Parts of the main test suite
part 'lifecycle/router_lifecycle_simulation_test.dart';
part 'navigation/router_dynamic_build_test.dart';
part 'navigation/router_forward_test.dart';
part 'navigation/router_history_test.dart';
part 'navigation/router_initial_sync_test.dart';
part 'navigation/router_navigation_test.dart';
part 'navigation/router_off_sync_test.dart';
part 'navigation/router_refresh_test.dart';
part 'navigation/router_spam_test.dart';
part 'navigation/run_web_desync_tests.dart';
part 'others/router_chaos_test.dart';
part 'others/router_duplicate_policy_test.dart';
part 'others/router_nest_param_test.dart';
part 'results/router_results_test.dart';

// Common Mock Bridge for all tests
class TestRouterBridge implements RouterBridge {
  Set<String> activeIds = {};
  List<String> logs = [];

  @override
  bool isRouteValid(RouteKey route) => activeIds.contains(route.id);

  @override
  void onRouteRemoved(RouteKey route) {
    logs.add("Removed: ${route.path}");
    activeIds.remove(route.id);
  }

  void reset() {
    activeIds.clear();
    logs.clear();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterArtistRouter Full Integration Suite', () {
    // Gọi các hàm test từ các file part

    runWebDesyncTests();
    runNavigationTests();
    runInitialSyncTests(); // Test URL in browser address.
    runDynamicBuilderTests();
    runOffSyncTests();
    runLifecycleSimulationTest();

    runBridgeTests();
    runGuardsTests();
    runGuardChainTests();
    runInitialGuardsTests();
    runResultTests();
    /** ----- Dialog Test ------------ */
    runDialogTests();
    runCloseAllDialogTests();
    runDialogResultTests();
    runDialogGuardTests();
    runOffAllWithDialogTests();
    /** ----- Test ------------ */
    runChaosTests();
    runHistoryTests();
    runDuplicatePolicyTests();

    runNestedParamsTests();

    runRefreshTests(); // GP * NEW *

    // runForwardHistoryTests(); // NEW *  (ERROR)
    // runRaceTests(); // NEW * (ERROR)

    print("*** DONE ***");
  });
}
