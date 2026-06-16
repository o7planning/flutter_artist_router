part of '../../flutter_artist_router.dart';

/// Container for route-related data used during the build process.
class FaRouteData {
  /// The unique structural identity reference bound to this specific route instance inside history.
  final RouteKey key;

  /// The static configuration blueprint holding the builder and middleware instructions for the path.
  final FaRoute route;

  /// The extracted path parameters, query parameters, and dynamic extra data corresponding to this navigation instance.
  final FaRouteState state;

  FaRouteData({required this.key, required this.route, required this.state});
}
