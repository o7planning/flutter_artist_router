
# flutter_artist_router

A high-performance, flexible declarative navigation system built on top of Flutter's Navigator 2.0 (Router API). It features granular control over the navigation history stack, dynamic route pruning, and automated memory lifecycle management.

All code comments and documentation are strictly maintained in English for international developer compliance.



[LIVE DEMO](https://o7planning.github.io/demo/flutter/flutter_artist_router_demo/)

[Download Demo Source Code](https://github.com/o7planning/flutter_artist_router_demo)

![IMAGE](https://o7planning.github.io/static/demo/flutter/flutter_artist_router_demo/images/demo.gif)

---

##  Key Architectural Advantages

The absolute standout feature of `flutter_artist_router` is its ability to **dynamically remove or mutate intermediate routes directly from the middle of the navigation stack** without disturbing or tearing down surrounding route structures.

Standard routing solutions force a strict, immutable LIFO (Last-In, First-Out) stack sequence. `flutter_artist_router` breaks this constraint to enable complex enterprise state lifecycles:

### The Intermediate Pruning Scenario:

Consider a workflow sequence mapping across paths like this:

`/home ──> /product ──> /supplier`

When components or state containers linked to `/product` are invalidated or no longer required, the router automatically:

1. Disposes and releases all associated memory allocation spaces from the registry.
2. Gracefully slices and prunes the `/product` route metadata straight out of the active Route Stack.

**Resulting Navigation Behavior:**
The active stack updates smoothly to `[ /home, /supplier ]`. If the user hits the system **"Back"** hardware button or triggers a pop routine from the `/supplier` screen, the application bypasses the product step entirely and transitions instantly back to **`/home`**.

---

##  Standalone Usage (100% Decoupled)

`flutter_artist_router` is designed as a completely self-contained, modular package. It does not depend on any large external framework binaries and can be plugged directly into any independent, standard Flutter application layout.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_artist_router/flutter_artist_router.dart';

// 1. Initialize your custom independent router configurations
final independentRouter = FlutterArtistRouter(
  initialLocation: '/',
  bridge: YourCustomRouterBridge(), 
  routes: [
    FaRoute(path: '/', builder: (context, state) => const HomeScreen()),
    FaRoute(path: '/product', builder: (context, state) => const ProductScreen()),
    FaRoute(path: '/supplier', builder: (context, state) => const SupplierScreen()),
  ],
);

// 2. Wire directly into your standard MaterialApp pipeline
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: FlutterArtistRouterDelegate(router: independentRouter),
      routeInformationParser: FlutterArtistRouteParser(),
    );
  }
}

```

---

## ⚡ Integration & Context API Usages

Interact with the routing ecosystem cleanly using the standard `BuildContext` extension or via centralized framework runtime instances.

###  Demystifying the Pop Mechanics (Crucial)

To prevent breaking layout life-cycles, `flutter_artist_router` separates temporary UI overlay removal from hard history stack destruction:

* **`context.faRouter.pop()` / `back()**`: Natively delegates execution directly to Flutter's standard `Navigator.of(context).pop()`. Use this to safely close open contextual layouts like `Drawer`, `EndDrawer`, BottomSheets, or local popups without altering your core route stack records.
* **`context.faRouter.popRoute()`**: Explicitly purges the top-most structural route (either a Page screen or an `FaDialogPage`) out of the history stack history.

---

### Framework API Implementation Examples

#### A. Complete Stack Replacement (e.g., Logout Routines)

Clears the entire navigation context history and mounts the target path as the absolute root of the application stack.

```dart
void executeSystemLogout(BuildContext context) {
  // Purges historical stacks and forces active session teardown
  context.faRouter.offAll('/login');
}

```

#### B. Direct Route Swapping (Close Current and Push Next)

Closes the current view context and overlays the new target location path in a single atomic transaction.

```dart
void transitionToDashboard(BuildContext context) {
  // Replaces the top-most stack slice gracefully
  context.faRouter.off('/dashboard');
}

```

#### C. Declarative Dialog Presentation Framework

Launches a contextual overlay dialog page safely inside the declarative Navigator 2.0 structure. It is highly recommended to use `context.faRouter.showDialog()` instead of Flutter's native global dialogue calls to preserve history tracking.

```dart
void promptConfirmationDialog(BuildContext context) {
  // Opens a managed modal dialogue layer wired into the router context
  context.faRouter.showDialog(
    '/confirm-action',
    barrierDismissible: true,
    builder: (context, state) => AlertDialog(
      title: const Text("Confirm Action"),
      content: const Text("Are you sure you want to proceed?"),
      actions: [
        TextButton(
          onPressed: () => context.faRouter.popRoute(), // Closes the dialog route structural block
          child: const Text("Dismiss"),
        ),
      ],
    ),
  );
}

```

#### D. Programmatic Intermediate Route Pruning via Bridge

You can use the built-in `RouterBridge` to dynamically trigger layout tracking updates that prune intermediate segments out of memory:

```dart
void discardProductSessionHistory(BuildContext context) {
  // Altering your custom bridge state flags automatically triggers stack evaluation routines
  myGlobalRouterBridge.skipProduct = true;
   
  // Explicitly requests the router to validate and reconstruct the current stack cleanly
  context.faRouter.requestStackValidation();  
}

```

---

##  Installation Manifest

Add this parameter block into your standard project `pubspec.yaml` configuration tracking file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_artist_core: ^latest_version
  flutter_artist_router: ^1.0.0

``` 