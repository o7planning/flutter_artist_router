part of '../../flutter_artist_router.dart';

class RouterUtils {
  static bool isSameRoute(RouteKey a, RouteKey b, FaRoute route) {
    final aUri = Uri.parse(a.path);
    final bUri = Uri.parse(b.path);

    final aParams = extractParams(route.path, aUri.path);
    final bParams = extractParams(route.path, bUri.path);

    if (aParams == null || bParams == null) return false;

    if (!mapEquals(aParams, bParams)) return false;

    return mapEquals(aUri.queryParameters, bUri.queryParameters);
  }

  static Map<String, String>? extractParams(String pattern, String path) {
    final patternSeg = pattern.split('/');
    final pathSeg = path.split('/');
    if (patternSeg.length != pathSeg.length) return null;
    final params = <String, String>{};
    for (int i = 0; i < patternSeg.length; i++) {
      if (patternSeg[i].startsWith(':')) {
        params[patternSeg[i].substring(1)] = Uri.decodeComponent(pathSeg[i]);
      } else if (patternSeg[i] != pathSeg[i]) {
        return null;
      }
    }
    return params;
  }
}
