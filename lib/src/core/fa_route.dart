part of '../../flutter_artist_router.dart';

/// Definition of a route including its path, builder, and local guards.
class FaRoute {
  /// The specific raw or parameter-tokenized path segment configuration mapping rules (e.g., '/product/:id').
  final String path;

  /// The active component builder closure executed to render the target screen UI view hierarchy.
  final FaRouteBuilder builder;

  /// List of localized route middleware guards evaluating permission challenges specifically bound to this destination path block.
  final List<FaRouteGuard> guards;

  const FaRoute({
    required this.path,
    required this.builder,
    this.guards = const [],
  });
}
