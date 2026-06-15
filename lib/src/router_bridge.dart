part of '../flutter_artist_router.dart';

/// Interface for bridging the router with the application's underlying logic.
abstract interface class RouterBridge {
  bool isRouteValid(RouteKey route);

  void onRouteRemoved(RouteKey route);
}
