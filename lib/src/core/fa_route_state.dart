part of '../../flutter_artist_router.dart';

/// Represents the state of a route, including path parameters and arguments.
class FaRouteState {
  final Object? extra;
  final Map<String, String> params;
  final Map<String, String> queryParams;

  const FaRouteState({
    this.extra,
    this.params = const {},
    this.queryParams = const {},
  });
}
