part of '../../flutter_artist_router.dart';

/// Represents the state of a route, including path parameters and arguments.
class FaRouteState {
  /// An optional payload object used to pass complex parameters directly between view contexts.
  final Object? extra;

  /// Tokenized dynamic route parameter keys and values parsed directly from the path matching layout (e.g., {'id': '42'}).
  final Map<String, String> params;

  /// Standard URI URL query string descriptors captured from the navigation path sequence (e.g., {'type': 'extreme'}).
  final Map<String, String> queryParams;

  const FaRouteState({
    this.extra,
    this.params = const {},
    this.queryParams = const {},
  });
}
