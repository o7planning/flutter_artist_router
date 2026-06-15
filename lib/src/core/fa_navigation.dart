part of '../../flutter_artist_router.dart';

/// Wrapper for navigation methods to provide a clean API via [BuildContext].
class FaNavigation {
  final BuildContext _context;

  FaNavigation(this._context);

  Future<T?> to<T>(String path, {Object? extra}) =>
      _context.faRouter.to<T>(path, extra: extra);

  Future<T?> dialog<T>(
    String path, {
    required FaRouteBuilder builder,
    List<FaRouteGuard> guards = const [],
    Object? extra,
    bool barrierDismissible = true,
  }) => _context.faRouter.dialog<T>(
    path,
    builder: builder,
    guards: guards,
    extra: extra,
    barrierDismissible: barrierDismissible,
  );

  void off(String path, {Object? extra}) =>
      _context.faRouter.off(path, extra: extra);

  void offAll(String path, {Object? extra}) =>
      _context.faRouter.offAll(path, extra: extra);

  void back<T>([T? result]) => _context.faRouter.back<T>(result);

  void closeAllDialogs() => _context.faRouter.closeAllDialogs();
}
