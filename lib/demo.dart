import 'package:flutter/material.dart';

import 'flutter_artist_router.dart';

/// ------------------------------------------------------------
/// 7. Demo Implementation
/// ------------------------------------------------------------
class MyBridge implements RouterBridge {
  bool skipProduct = false;

  @override
  bool isRouteValid(RouteKey route) =>
      !(skipProduct && route.path == '/product');

  @override
  void onRouteRemoved(RouteKey route) {}
}

final myBridge = MyBridge();
final faRouter = FlutterArtistRouter(
  bridge: myBridge,
  routeInfoProvider: null,
  initialLocation: '/',
  errorRoute: FaRoute(
    path: '/404',
    builder: (c, s) => const Scaffold(body: Center(child: Text("404"))),
  ),
  routes: [
    FaRoute(path: '/', builder: (c, s) => const HomeScreen()),
    FaRoute(path: '/product', builder: (c, s) => const ProductScreen()),
    FaRoute(path: '/supplier', builder: (c, s) => const SupplierScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: FlutterArtistRouterDelegate(
        router: faRouter,
        observers: [],
      ),
      routeInformationParser: FlutterArtistRouteParser(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Home")),
    body: Center(
      child: ElevatedButton(
        onPressed: () => context.navigation.to('/product'),
        child: const Text("Go to Product (Push)"),
      ),
    ),
  );
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Product")),
    body: Center(
      child: ElevatedButton(
        onPressed: () => context.navigation.to('/supplier'),
        child: const Text("Go to Supplier (Push)"),
      ),
    ),
  );
}

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Supplier")),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              myBridge.skipProduct = true;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã loại bỏ Product!")),
              );
            },
            child: const Text("Vô hiệu hóa Product trong Stack"),
          ),
          ElevatedButton(
            onPressed: () => context.navigation.offAll('/'),
            child: const Text("Logout (offAll)"),
          ),
        ],
      ),
    ),
  );
}
