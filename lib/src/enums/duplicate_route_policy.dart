part of '../../flutter_artist_router.dart';

/// Policy for handling navigation when a route with the same path already exists in the stack.
enum DuplicateRoutePolicy {
  /// Appends a unique incrementing sequence suffix to the route key identifier,
  /// allowing identical duplicate paths to coexist natively within the history stack.
  autoSuffix,

  /// Immediately terminates the routing operation and throws a [DuplicateRouteError]
  /// if the incoming navigation path target already matches an entry in the stack history.
  throwError,

  /// Silently ignores and drops the new navigation request, maintaining the current
  /// active history stack state configuration exactly as it is without throwing any errors.
  skip,

  /// Disposes of the pre-existing duplicate route instance and its corresponding rendering page,
  /// then overlays the newly pushed path config at the top of the history stack history.
  overwrite,
}
