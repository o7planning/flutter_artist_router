part of '../../flutter_artist_router.dart';

/// Extension for convenient navigation access from [BuildContext].
extension FaContextNavigation on BuildContext {
  FaNavigation get navigation => FaNavigation(this);

  FlutterArtistRouter get faRouter =>
      (Router.of(this).routerDelegate as FlutterArtistRouterDelegate).router;
}
