part of '../../flutter_artist_router.dart';

/// Definition of a route including its path, builder, and local guards.
class FaRoute {
  final String path;
  final FaRouteBuilder builder;
  final List<FaRouteGuard> guards;

  const FaRoute({
    required this.path,
    required this.builder,
    this.guards = const [],
  });
}
