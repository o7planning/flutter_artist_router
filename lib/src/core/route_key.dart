part of '../../flutter_artist_router.dart';

/// Uniquely identifies a route instance in the navigation stack.
class RouteKey {
  final String path;
  final String id;
  final bool isDialog;

  const RouteKey(this.path, this.id, {this.isDialog = false});

  @override
  bool operator ==(Object other) => other is RouteKey && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => "RouteKey(#$id, $path)";
}
