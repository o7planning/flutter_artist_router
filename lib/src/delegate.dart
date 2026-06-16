part of '../flutter_artist_router.dart';

/// The RouterDelegate that glues the [FlutterArtistRouter] with the Flutter [Navigator].
class FlutterArtistRouterDelegate extends RouterDelegate<RouteKey>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteKey> {
  final FlutterArtistRouter router;
  final List<NavigatorObserver> observers;

  @override
  GlobalKey<NavigatorState> get navigatorKey => FlutterArtistCore.navigatorKey;

  FlutterArtistRouterDelegate({
    required this.router,
    this.observers = const [],
  }) {
    router.addListener(notifyListeners);
  }

  @override
  RouteKey? get currentConfiguration =>
      router.stack.isEmpty ? null : router.stack.last;

  @override
  Future<void> setInitialRoutePath(RouteKey configuration) async {
    if (router.stack.isEmpty) {
      await router._start();
      return;
    }
    if (router.currentRouteKey?.path != configuration.path &&
        router.isRouteDefined(configuration.path)) {
      await router.to(configuration.path);
    }
  }

  @override
  Future<void> setNewRoutePath(RouteKey configuration) async {
    if (router.stack.isEmpty ||
        router.currentRouteKey?.path == configuration.path) {
      return;
    }
    // Standard web back-button behavior
    router.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    if (router.stack.isEmpty) {
      return const Material(
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return Navigator(
      key: navigatorKey,
      pages: router.pages,
      observers: observers,
      // When a user swipes back (iOS gesture) or a page is popped natively,
      // synchronize our internal state without refiring the global await pop logic.
      onDidRemovePage: (Page page) {
        router.removePage(page);
      },
    );
  }
}
