part of '../flutter_artist_router.dart';

/// The main router class managing the navigation stack and guards.
class FlutterArtistRouter extends ChangeNotifier {
  /// Internal look-up table containing mapped path definitions to their corresponding route settings.
  final Map<String, FaRoute> _routeDefinitions = {};

  /// The underlying list of Flutter [Page] objects currently feeding the [Navigator] entry tree.
  final List<Page> _pages = [];

  /// Active state history containing individual structural references to unique route instances.
  final List<RouteKey> _stack = [];

  /// Keeps track of reactive asynchronous response triggers corresponding to popped route result allocations.
  final Map<RouteKey, Completer<dynamic>> _resultCompleters = {};

  /// Global guards applied to every navigation attempt.
  final List<FaRouteGuard> globalGuards;

  /// The application bridge used to track outer lifecycle changes and trigger intermediate stack validation pruning.
  final RouterBridge bridge;

  /// Initial fallback screen path mounted at initial system initialization.
  final String? initialLocation;

  /// Default fallback structure activated whenever target routing pathways fail validation checks.
  final FaRoute? errorRoute;

  /// Directing policy strategy deployed when trying to push a route configuration already present in the active stack.
  final DuplicateRoutePolicy duplicatePolicy;

  /// Underlying system synchronization hook linking the router layout to the platform's browser address context.
  final RouteInformationProvider? routeInfoProvider;

  /// Thread-safe incrementing identifier tag attached to every new pushed navigation instance.
  int _counter = 0;

  /// Internal indicator guarding against multiple startup pipeline calls.
  bool _isStarted = false;

  FlutterArtistRouter({
    required List<FaRoute> routes,
    this.initialLocation,
    this.errorRoute,
    this.duplicatePolicy = DuplicateRoutePolicy.overwrite,
    required this.bridge,
    this.routeInfoProvider,
    this.globalGuards = const [],
  }) {
    for (final r in routes) {
      _routeDefinitions[r.path] = r;
    }
  }

  /// Validates whether a matching path key resides inside the registered definitions map.
  bool isRouteDefined(String path) => _routeDefinitions.containsKey(path);

  /// Exposes a read-only unmodifiable mirror of the underlying active rendering page sequence.
  List<Page> get pages => List.unmodifiable(_pages);

  /// Exposes a read-only unmodifiable view of the target structural route elements array stack.
  List<RouteKey> get stack => List.unmodifiable(_stack);

  /// Safely resolves the current top-most structural element active inside history.
  RouteKey? get currentRouteKey => _stack.isEmpty ? null : _stack.last;

  /// Internal startup logic triggered by the delegate.
  Future<void> _start() async {
    if (_isStarted) return;
    _isStarted = true;

    String? startPath;
    if (routeInfoProvider != null) {
      final browserPath = routeInfoProvider!.value.uri.path;
      if (browserPath.isNotEmpty &&
          _routeDefinitions.containsKey(browserPath)) {
        startPath = browserPath;
      }
    }
    startPath ??= initialLocation;
    startPath ??= _routeDefinitions.keys.first;

    await _internalGo(
      startPath,
      action: NavigationAction.replace,
      clearStack: true,
    );
  }

  /// Coordinates path changes back to the system route provider to update browser location bars smoothly.
  void _syncBrowser(NavigationAction action) {
    if (_stack.isEmpty || routeInfoProvider == null) return;
    final uri = Uri.parse(_stack.last.path);
    switch (action) {
      case NavigationAction.push:
        routeInfoProvider!.routerReportsNewRouteInformation(
          RouteInformation(uri: uri),
          type: RouteInformationReportingType.navigate,
        );
        break;
      case NavigationAction.replace:
        routeInfoProvider!.routerReportsNewRouteInformation(
          RouteInformation(uri: uri),
          type: RouteInformationReportingType.neglect,
        );
        break;
      case NavigationAction.pop:
        break;
    }
  }

  /// Navigates to a new path. Supports dynamic [builder] for on-the-fly route definition.
  Future<T?> to<T>(
    String path, {
    FaRouteBuilder? builder,
    Object? extra,
  }) async {
    if (builder != null) {
      _routeDefinitions[path] = FaRoute(path: path, builder: builder);
    }
    final completer = Completer<T?>();
    await _internalGo(
      path,
      extra: extra,
      completer: completer,
      action: NavigationAction.push,
    );
    return completer.future;
  }

  /// Replaces the current route. Supports dynamic [builder].
  Future<void> off(
    String path, {
    FaRouteBuilder? builder,
    Object? extra,
  }) async {
    if (builder != null) {
      _routeDefinitions[path] = FaRoute(path: path, builder: builder);
    }
    if (_stack.isNotEmpty) {
      final lastKey = _stack.removeLast();
      _pages.removeLast();
      bridge.onRouteRemoved(lastKey);
    }
    return _internalGo(path, extra: extra, action: NavigationAction.replace);
  }

  /// Clears stack and navigates to new path. Supports dynamic [builder].
  Future<void> offAll(
    String path, {
    FaRouteBuilder? builder,
    Object? extra,
  }) async {
    if (builder != null) {
      _routeDefinitions[path] = FaRoute(path: path, builder: builder);
    }
    return _internalGo(
      path,
      extra: extra,
      clearStack: true,
      action: NavigationAction.replace,
    );
  }

  /// Registers and overlays a managed declarative dialog instance onto the historical structural layer.
  Future<T?> showDialog<T>(
    String path, {
    required FaRouteBuilder builder,
    List<FaRouteGuard> guards = const [],
    Object? extra,
    bool barrierDismissible = true,
  }) async {
    _routeDefinitions[path] = FaRoute(
      path: path,
      builder: builder,
      guards: guards,
    );
    final completer = Completer<T?>();
    await _internalGo(
      path,
      extra: extra,
      isDialog: true,
      barrierDismissible: barrierDismissible,
      completer: completer,
      action: NavigationAction.push,
    );
    return completer.future;
  }

  /// Explicitly removes the top-most structural route (Page or Dialog) from the history stack context.
  void popRoute<T>([T? result]) {
    if (_stack.length > 1) {
      final key = _stack.removeLast();
      _pages.removeLast();
      _resultCompleters.remove(key)?.complete(result);
      bridge.onRouteRemoved(key);
      _refreshStack();
      notifyListeners();
      _syncBrowser(NavigationAction.pop);
    }
  }

  /// Standard imperative pop utility mirroring native Flutter framework behavior.
  /// Safely targets and dismisses active contextual layout overlays (Drawers, EndDrawers, native popups).
  void pop<T>([T? result]) {
    final currentContext = FlutterArtistCore.navigatorKey.currentContext;
    if (currentContext != null) {
      Navigator.of(currentContext).pop(result);
    }
  }

  /// Semantic alias alternative pointing directly to the structural framework pop sequence.
  void back<T>([T? result]) => pop<T>(result);

  /// Mass iteration routine targeting and cleaning out every active [FaDialogPage] layer across history.
  void closeAllDialogs() {
    bool changed = false;
    for (int i = _stack.length - 1; i >= 0; i--) {
      if (_stack[i].isDialog) {
        final key = _stack.removeAt(i);
        _pages.removeAt(i);
        _resultCompleters.remove(key)?.complete(null);
        bridge.onRouteRemoved(key);
        changed = true;
      }
    }
    if (changed) {
      _refreshStack();
      notifyListeners();
      _syncBrowser(NavigationAction.pop);
    }
  }

  /// Explicitly requests the router to validate the current stack via the bridge.
  void requestStackValidation() => _refreshStack();

  /// Internal processing pipeline coordinating guards, duplicates, structural allocations, and state notifications.
  Future<void> _internalGo(
    String path, {
    Object? extra,
    bool clearStack = false,
    bool isDialog = false,
    bool barrierDismissible = true,
    NavigationAction action = NavigationAction.push,
    Completer<dynamic>? completer,
  }) async {
    final uri = Uri.parse(path);
    final cleanPath = uri.path;

    String? matchedPath;
    Map<String, String> pathParams = {};
    for (final definition in _routeDefinitions.keys) {
      final match = _extractPathParams(definition, cleanPath);
      if (match != null) {
        matchedPath = definition;
        pathParams = match;
        break;
      }
    }

    final route = _routeDefinitions[matchedPath] ?? errorRoute;
    if (route == null) throw Exception("Route $path not found.");

    final state = FaRouteState(
      extra: extra,
      params: pathParams,
      queryParams: uri.queryParameters,
    );
    final allGuards = [...globalGuards, ...route.guards];
    for (final guard in allGuards) {
      if (!await guard.canActivate(state)) {
        final redirectPath = await guard.redirect(state);
        if (redirectPath != null && redirectPath != path) {
          return _internalGo(
            redirectPath,
            action: NavigationAction.replace,
            clearStack: clearStack,
          );
        }
        return;
      }
    }

    final int existingIndex = _stack.indexWhere((k) => k.path == path);
    if (existingIndex != -1) {
      switch (duplicatePolicy) {
        case DuplicateRoutePolicy.skip:
          return;
        case DuplicateRoutePolicy.throwError:
          throw DuplicateRouteError("Route $path already exists in stack.");
        case DuplicateRoutePolicy.overwrite:
          final r = _stack.removeAt(existingIndex);
          _pages.removeAt(existingIndex);
          _resultCompleters.remove(r)?.complete(null);
          bridge.onRouteRemoved(r);
          break;
        case DuplicateRoutePolicy.autoSuffix:
          break;
      }
    }

    if (clearStack) {
      for (var key in _stack) {
        bridge.onRouteRemoved(key);
      }
      _stack.clear();
      _pages.clear();
      _resultCompleters.forEach((_, c) => c.complete(null));
      _resultCompleters.clear();
    }

    final routeKey = RouteKey(
      path,
      "${path}_${_counter++}",
      isDialog: isDialog,
    );
    if (completer != null) _resultCompleters[routeKey] = completer;
    _stack.add(routeKey);
    _pages.add(
      _createPage(
        route,
        state,
        routeKey,
        isDialog: isDialog,
        barrierDismissible: barrierDismissible,
      ),
    );
    notifyListeners();
    _syncBrowser(action);
  }

  /// Scans intermediate historical paths to drop segments no longer marked active by the outer bridge interface.
  void _refreshStack() {
    bool changed = false;
    if (_stack.length > 1) {
      for (int i = _stack.length - 2; i > 0; i--) {
        if (!bridge.isRouteValid(_stack[i])) {
          final r = _stack.removeAt(i);
          _pages.removeAt(i);
          _resultCompleters.remove(r)?.complete(null);
          bridge.onRouteRemoved(r);
          changed = true;
        }
      }
    }
    if (changed) notifyListeners();
  }

  /// Compares structure patterns to parse out inline parameters from target navigation tracks.
  Map<String, String>? _extractPathParams(String pattern, String path) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');
    if (patternParts.length != pathParts.length) return null;
    Map<String, String> params = {};
    for (int i = 0; i < patternParts.length; i++) {
      if (patternParts[i].startsWith(':')) {
        params[patternParts[i].substring(1)] = pathParts[i];
      } else if (patternParts[i] != pathParts[i]) {
        return null;
      }
    }
    return params;
  }

  /// Maps incoming data settings cleanly into concrete [MaterialPage] or custom [FaDialogPage] layout representations.
  Page _createPage(
    FaRoute route,
    FaRouteState state,
    RouteKey key, {
    bool isDialog = false,
    bool barrierDismissible = true,
  }) {
    final routeData = FaRouteData(key: key, route: route, state: state);
    if (isDialog) {
      return FaDialogPage(
        key: ValueKey(key.id),
        name: key.path,
        barrierDismissible: barrierDismissible,
        arguments: routeData,
        child: route.builder(FlutterArtistCore.context, state),
      );
    }
    return MaterialPage(
      key: ValueKey(key.id),
      name: key.path,
      arguments: routeData,
      child: Builder(builder: (c) => route.builder(c, state)),
    );
  }

  /// Synchronization sink intercepting native interface swiping movements or platform pop actions.
  void removePage(Page page) {
    final i = _pages.indexOf(page);
    if (i != -1) {
      final r = _stack.removeAt(i);
      _pages.removeAt(i);
      _resultCompleters.remove(r)?.complete(null);
      bridge.onRouteRemoved(r);
      _refreshStack();
      notifyListeners();
    }
  }
}
