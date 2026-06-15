part of '../../flutter_artist_router.dart';

/// Container for route-related data used during the build process.
class FaRouteData {
  final RouteKey key;
  final FaRoute route;
  final FaRouteState state;

  FaRouteData({required this.key, required this.route, required this.state});
}
