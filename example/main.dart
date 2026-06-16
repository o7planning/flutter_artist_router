import 'package:flutter/material.dart';
import 'package:flutter_artist_router/flutter_artist_router.dart';

void main() {
  runApp(const MyApp());
}

/// 1. Define the Bridge to intercept and validate structural routes
class MyBridge implements RouterBridge {
  bool skipProduct = false;

  @override
  bool isRouteValid(RouteKey route) =>
      !(skipProduct && route.path == '/product');

  @override
  void onRouteRemoved(RouteKey route) {}
}

final myBridge = MyBridge();

/// 2. Initialize the global configuration for FlutterArtistRouter
final faRouter = FlutterArtistRouter(
  bridge: myBridge,
  routeInfoProvider: null,
  initialLocation: '/',
  errorRoute: FaRoute(
    path: '/404',
    builder: (context, state) =>
        const Scaffold(body: Center(child: Text("404 - Page Not Found"))),
  ),
  routes: [
    FaRoute(path: '/', builder: (context, state) => const HomeScreen()),
    FaRoute(
      path: '/product',
      builder: (context, state) => const ProductScreen(),
    ),
    FaRoute(
      path: '/supplier',
      builder: (context, state) => const SupplierScreen(),
    ),
  ],
);

/// 4. Root Application Wrapper
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: FlutterArtistRouterDelegate(
        router: faRouter,
        observers: [],
      ),
      routeInformationParser: FlutterArtistRouteParser(),
    );
  }
}

/// ------------------------------------------------------------
///  Main Layout Framework (Split View Setup)
/// ------------------------------------------------------------

class DemoMainLayout extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? endDrawer;

  const DemoMainLayout({
    required this.title,
    required this.content,
    this.endDrawer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      endDrawer: endDrawer,
      body: Row(
        children: [
          // Left Area: Active Screen Content (70% Screen Width)
          Expanded(
            flex: 7,
            child: Container(color: Colors.grey[100], child: content),
          ),
          // Vertical Divider line
          VerticalDivider(width: 1, color: Colors.grey[300]),
          // Right Area: Visual Stack Inspector (30% Screen Width)
          const Expanded(flex: 3, child: VisualStackInspectorPanel()),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
///  Visual Route Stack Inspector Panel (Right Column)
/// ------------------------------------------------------------

class VisualStackInspectorPanel extends StatelessWidget {
  const VisualStackInspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder automatically repaints whenever the router stack configuration updates
    return ListenableBuilder(
      listenable: faRouter,
      builder: (context, child) {
        final currentStack = faRouter.stack;

        return Container(
          color: Colors.grey[900], // Premium dark layout context
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPanelHeader(currentStack.length),
              const SizedBox(height: 20),
              Expanded(
                child: currentStack.isEmpty
                    ? _buildEmptyState()
                    : _buildStackList(currentStack),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelHeader(int stackCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "ROUTE INSPECTOR",
          style: TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Size: $stackCount",
            style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Stack is currently empty",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildStackList(List<RouteKey> currentStack) {
    // Render from top to bottom (Reverse list order) to represent a real stack pile visually
    final reversedStack = currentStack.reversed.toList();

    return ListView.separated(
      itemCount: reversedStack.length,
      separatorBuilder: (context, index) =>
          const Icon(Icons.arrow_upward_rounded, color: Colors.grey, size: 16),
      itemBuilder: (context, index) {
        final routeKey = reversedStack[index];
        final isTopPage = index == 0;

        return _buildRouteItemCard(routeKey, isTopPage);
      },
    );
  }

  Widget _buildRouteItemCard(RouteKey routeKey, bool isTopPage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isTopPage ? Colors.teal[800] : Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTopPage ? Colors.tealAccent : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          routeKey.isDialog
              ? Icons.picture_in_picture_rounded
              : Icons.layers_rounded,
          color: isTopPage ? Colors.tealAccent : Colors.white70,
        ),
        title: Text(
          routeKey.path,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "ID: ${routeKey.id}",
          style: TextStyle(
            color: isTopPage ? Colors.white70 : Colors.grey[400],
            fontSize: 10,
          ),
        ),
        trailing: isTopPage
            ? const Text(
                "TOP",
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              )
            : null,
      ),
    );
  }
}

/// ------------------------------------------------------------
/// ️ Screen Body Content Builders (Left Column Content)
/// ------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoMainLayout(
      title: "Home",
      content: Center(
        child: ElevatedButton(
          onPressed: () => context.faRouter.to('/product'),
          child: const Text("Go to Product (to)"),
        ),
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoMainLayout(
      title: "Product Detail",
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.faRouter.to('/supplier'),
              child: const Text("Go to Supplier (to)"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.faRouter.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              child: const Text("Go Back (back/pop)"),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierScreen extends StatelessWidget {
  const SupplierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoMainLayout(
      title: "Supplier Console",
      // EndDrawer panel targeting native pop mechanics
      endDrawer: _buildSidebarDrawer(context),
      content: Builder(
        builder: (localContext) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBridgeControlWidget(localContext),
                  const SizedBox(height: 16),
                  _buildActionButtonsWidget(localContext),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarDrawer(BuildContext context) {
    return Drawer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 48,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              "Form Panel Overlay",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.faRouter.pop(),
              child: const Text("Dismiss Drawer (pop)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBridgeControlWidget(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Router Bridge Simulator",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                myBridge.skipProduct = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Product entry flagged invalid in Bridge State!",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
              child: const Text("Prune Product Route via Bridge"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsWidget(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _triggerDeclarativeDialog(context),
          child: const Text("Open Declarative Dialog (showDialog)"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          child: const Text("Slide Open EndDrawer Panel"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => context.faRouter.popRoute(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
          ),
          child: const Text("Force Destroy Current Route (popRoute)"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => context.faRouter.offAll('/'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
          ),
          child: const Text("Reset All to Home (offAll)"),
        ),
      ],
    );
  }

  void _triggerDeclarativeDialog(BuildContext context) {
    context.faRouter.showDialog(
      '/info-dialog',
      builder: (c, s) => AlertDialog(
        title: const Text("Declarative Overlay Route"),
        content: const Text(
          "This dialogue structure sits explicitly inside the framework router history list.",
        ),
        actions: [
          TextButton(
            onPressed: () => context.faRouter.popRoute(),
            child: const Text("Pop Dialog (popRoute)"),
          ),
        ],
      ),
    );
  }
}
