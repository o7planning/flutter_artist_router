part of '../../flutter_artist_router.dart';

/// Uniquely identifies a route instance in the navigation stack.
class RouteKey {
  /// The operational destination URL string location path configuration (e.g., '/product').
  final String path;

  /// The absolute distinct timestamped identity tag separating multiple historical instances of identical paths.
  final String id;

  /// Indicates whether this specific instance configuration represents an overlay [FaDialogPage] instead of a standard screen layout line.
  final bool isDialog;

  const RouteKey(this.path, this.id, {this.isDialog = false});

  @override
  bool operator ==(Object other) => other is RouteKey && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => "RouteKey(#$id, $path)";
}
