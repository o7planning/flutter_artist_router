part of '../flutter_artist_router.dart';

/// Parses [RouteInformation] into a [RouteKey] and vice-versa.
class FlutterArtistRouteParser extends RouteInformationParser<RouteKey> {
  @override
  Future<RouteKey> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final path = routeInformation.uri.path.isEmpty
        ? '/'
        : routeInformation.uri.path;
    return RouteKey(
      path,
      "parser_${path}_${DateTime.now().millisecondsSinceEpoch}",
    );
  }

  @override
  RouteInformation? restoreRouteInformation(RouteKey configuration) {
    return RouteInformation(uri: Uri.parse(configuration.path));
  }
}
