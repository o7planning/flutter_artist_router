
# flutter_artist_router

A high-performance, flexible declarative navigation system built on top of Flutter's Navigator 2.0 (Router API). It features granular control over the navigation history stack, dynamic route pruning, and automated memory lifecycle management.

---

##  Key Architectural Advantages

The absolute standout feature of `flutter_artist_router` is its ability to **dynamically remove or mutate intermediate routes directly from the middle of the navigation stack** without disturbing or tearing down surrounding route structures.

Standard routing solutions force a strict, immutable LIFO (Last-In, First-Out) stack sequence. `flutter_artist_router` breaks this constraint to enable complex enterprise state lifecycles:

### The Intermediate Pruning Scenario:

Consider a workflow sequence mapping across paths like this:

`/home ──> /product ──> /supplier`

When components or state containers linked to `/product` (such as active UI Shelves, layout Blocks, or structural Scalars) no longer appear on the screen or are invalidated, the router automatically:

1. Disposes and releases all associated memory allocation spaces from the registry.
2. Gracefully slices and prunes the `/product` route metadata straight out of the active Route Stack.

**Resulting Navigation Behavior:**
The active stack updates smoothly to `[ /home, /supplier ]`. If the user hits the system **"Back"** hardware button or triggers a pop routine from the `/supplier` screen, the application bypasses the product step entirely and transitions instantly back to **`/home`**.

---

## 里 Standalone Usage (100% Decoupled)

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

## ⚡ Integration with the FlutterArtist Ecosystem

When deployed inside the framework ecosystem, `flutter_artist_router` serves as the core navigation bridge. It hooks directly into centralized runtime instances for instant access across any component.

### Accessing the Global Router Client

You can fetch and interact with the operational router directly via the unified static instance point:

```dart
// Fetch the central framework routing driver instance
FlutterArtistRouter router = FlutterArtist.router;

```

### Framework API Implementation Examples

When interacting via the central global setup, driving view adjustments, clearing histories, or launching custom dialogs is clean and robust using static `routeName` parameters:

#### A. Complete Stack Replacement (e.g., Logout Routines)

Clears the entire navigation context history and mounts the target path as the absolute root of the application stack.

```dart
void executeSystemLogout() {
  // Purges historical stacks and forces active session teardown
  FlutterArtist.router.offAll(LoginScreen.routeName);
}

```

#### B. Direct Route Swapping (Close Current and Push Next)

Closes the current view context and overlays the new target location path in a single atomic transaction.

```dart
void transitionToDashboard() {
  // Replaces the top-most stack slice gracefully
  FlutterArtist.router.off(DashboardScreen.routeName);
}

```

#### C. Declarative Dialog Presentation Framework

Launches a contextual overlay dialog page safely inside the declarative Navigator 2.0 structure. It supports route guards and control flags out of the box.

```dart
void promptConfirmationDialog() {
  // Opens a managed modal dialogue layer wired into the router context
  FlutterArtist.router.dialog(
    ConfirmationDialog.routeName,
    barrierDismissible: true,
    builder: (context, state) => const ConfirmationDialog(
      title: "Confirm Action",
      content: "Are you sure you want to proceed with this operation?",
    ),
  );
}

```

#### D. Programmatic Intermediate Route Pruning via Bridge

You can use the built-in `RouterBridge` to dynamically trigger layout tracking updates that prune intermediate segments out of memory:

```dart
void discardProductSessionHistory() {
  // Altering your custom bridge state flags automatically triggers 
  // stack evaluation routines, dropping the intermediate route from history.
  myGlobalRouterBridge.skipProductStep = true;
  
  // Re-evaluates and reconstructs pages cleanly
  FlutterArtist.router.refresh(); 
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
  flutter_artist_router: ^latest_version
```
 