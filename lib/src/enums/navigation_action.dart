part of '../../flutter_artist_router.dart';

/// Defines the structural transaction layout applied to the state change
/// when coordinating history reports with the platform's browser interface tracker.
enum NavigationAction {
  /// Represents a standard append operation where a new structural route entry
  /// is mounted onto the top of the history list registry.
  push,

  /// Indicates an inline route mutation that substitutes an active top slice entry
  /// without introducing additional historical navigation stack layout lines.
  replace,

  /// Marks a disposal operation signifying the dismissal and removal of the active entry
  /// from the history list state context.
  pop,
}
