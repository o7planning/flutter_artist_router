part of '../../flutter_artist_router.dart';

/// Error thrown when a duplicate route is detected and the policy is set to [DuplicateRoutePolicy.throwError].
class DuplicateRouteError extends Error {
  /// Detailed technical description string indicating why the duplicate navigation path attempt was rejected.
  final String message;

  DuplicateRouteError(this.message);

  @override
  String toString() => message;
}
