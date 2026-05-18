part of '../flutter_artist_router.dart';

/// Policy for handling navigation when a route with the same path already exists in the stack.
enum DuplicateRoutePolicy { autoSuffix, throwError, skip, overwrite }

/// Error thrown when a duplicate route is detected and the policy is set to [DuplicateRoutePolicy.throwError].
class DuplicateRouteError extends Error {
  final String message;

  DuplicateRouteError(this.message);

  @override
  String toString() => message;
}

/// A custom [Page] implementation for displaying dialogs within the Navigator 2.0 stack.
class FaDialogPage<T> extends Page<T> {
  final Widget child;
  final bool barrierDismissible;
  final Color barrierColor;

  const FaDialogPage({
    required this.child,
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    super.key,
    super.name,
    super.arguments,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return RawDialogRoute<T>(
      settings: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: 'Dismiss',
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}

/// Uniquely identifies a route instance in the navigation stack.
class RouteKey {
  final String path;
  final String id;
  final bool isDialog;

  const RouteKey(this.path, this.id, {this.isDialog = false});

  @override
  bool operator ==(Object other) => other is RouteKey && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => "RouteKey(#$id, $path)";
}

/// Represents the state of a route, including path parameters and arguments.
class FaRouteState {
  final Object? extra;
  final Map<String, String> params;
  final Map<String, String> queryParams;

  const FaRouteState({
    this.extra,
    this.params = const {},
    this.queryParams = const {},
  });
}

/// Interface for defining route guards (middleware) for protection or redirection.
abstract class FaRouteGuard {
  Future<bool> canActivate(FaRouteState state);

  Future<String?> redirect(FaRouteState state) async => null;
}

/// Interface for bridging the router with the application's underlying logic.
abstract interface class RouterBridge {
  bool isRouteValid(RouteKey route);

  void onRouteRemoved(RouteKey route);
}

/// Definition of a route including its path, builder, and local guards.
class FaRoute {
  final String path;
  final FaRouteBuilder builder;
  final List<FaRouteGuard> guards;

  const FaRoute({
    required this.path,
    required this.builder,
    this.guards = const [],
  });
}

/// Container for route-related data used during the build process.
class FaRouteData {
  final RouteKey key;
  final FaRoute route;
  final FaRouteState state;

  FaRouteData({required this.key, required this.route, required this.state});
}

/// Extension for convenient navigation access from [BuildContext].
extension FaContextNavigation on BuildContext {
  FaNavigation get navigation => FaNavigation(this);

  FlutterArtistRouter get faRouter =>
      (Router.of(this).routerDelegate as FlutterArtistRouterDelegate).router;
}

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
