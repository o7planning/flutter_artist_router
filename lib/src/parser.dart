part of '../flutter_artist_router.dart';

/// Parses [RouteInformation] into a [RouteKey] and vice-versa.
class FlutterArtistRouteParser extends RouteInformationParser<RouteKey> {
  @override
  /// Intercepts platform-driven incoming URI changes (such as manual browser address bars mutations)
  /// and maps them cleanly into structured internal key tracking objects.
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
  /// Serializes an internal structural history configuration back into standard platform-compliant [RouteInformation]
  /// to accurately update the active browser location bars.
  RouteInformation? restoreRouteInformation(RouteKey configuration) {
    return RouteInformation(uri: Uri.parse(configuration.path));
  }
}
