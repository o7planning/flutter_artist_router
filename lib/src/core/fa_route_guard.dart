part of '../../flutter_artist_router.dart';

/// Interface for defining route guards (middleware) for protection or redirection.
abstract class FaRouteGuard {
  Future<bool> canActivate(FaRouteState state);

  Future<String?> redirect(FaRouteState state) async => null;
}
