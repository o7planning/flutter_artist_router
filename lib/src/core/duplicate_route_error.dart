part of '../../flutter_artist_router.dart';

/// Error thrown when a duplicate route is detected and the policy is set to [DuplicateRoutePolicy.throwError].
class DuplicateRouteError extends Error {
  final String message;

  DuplicateRouteError(this.message);

  @override
  String toString() => message;
}
