part of '../../flutter_artist_router.dart';

extension FaRouterContextExtension on BuildContext {
  /// Resolves and extracts the operational core [FlutterArtistRouter] engine instance.
  /// Traverses up the current widget tree context to safely fetch the matching delegate driver.
  FlutterArtistRouter get faRouter =>
      (Router.of(this).routerDelegate as FlutterArtistRouterDelegate).router;
}
