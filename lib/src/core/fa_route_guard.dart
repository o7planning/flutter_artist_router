part of '../../flutter_artist_router.dart';

/// Interface for defining route guards (middleware) for protection or redirection.
abstract class FaRouteGuard {
  /// Evaluates permission challenges to determine whether the active destination navigation intent is allowed to render.
  /// Returns `true` to approve mounting access, or `false` to intercept and trigger alternative rerouting paths.
  Future<bool> canActivate(FaRouteState state);

  /// Explicit intercept routine mapping redirect targets whenever [canActivate] reports a navigation layout block.
  /// Returns a valid fallback destination target string location path, or `null` if no redirection layout adjustments apply.
  Future<String?> redirect(FaRouteState state) async => null;
}
