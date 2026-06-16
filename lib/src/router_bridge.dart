part of '../flutter_artist_router.dart';

/// Interface for bridging the router with the application's underlying logic.
abstract interface class RouterBridge {
  /// Evaluates whether a specific structural route entry remains valid within the application lifecycle.
  /// Returning `false` signals the core navigation state engine to automatically slice and prune
  /// this intermediate segment out of the active history stack.
  bool isRouteValid(RouteKey route);

  /// Callback triggered immediately after a structural route entry has been completely dismissed
  /// and stripped from the navigation history registry.
  /// Use this hook to safely trigger resource deallocation, dispose associated layout blocks,
  /// or synchronize localized state cleanups.
  void onRouteRemoved(RouteKey route);
}
