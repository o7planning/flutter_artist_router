part of '../../flutter_artist_router.dart';

/// Policy for handling navigation when a route with the same path already exists in the stack.
enum DuplicateRoutePolicy { autoSuffix, throwError, skip, overwrite }
