## 1.0.0

###  BREAKING CHANGES

* **Router Semantic Refactoring**:
  * Renamed `FlutterArtistRouter.dialog()` to `FlutterArtistRouter.showDialog()`. Users are highly encouraged to use `context.faRouter.showDialog()` instead of Flutter's standard `showDialog()` to ensure dialog instances are properly managed within the framework's reactive history.
  * Refactored `context.faRouter.pop()` and `context.faRouter.back()` to natively delegate execution directly to Flutter's standard `Navigator.of(context).pop()`. This aligns their behaviors with native framework conventions for dismissing active UI overlays (such as Drawers, EndDrawers, and standard popups).
  * Introduced `context.faRouter.popRoute()` to explicitly force the removal of a structural route (either a Page or a Dialog) from the internal history stack. This method strictly operates on routes registered within the router stack and bypasses temporary UI layouts.

###  Enhancements & Fixes

* **Unified Context Synchronization**: Optimized the declarative framework pop lifecycle. When a page or dialog is popped natively via UI gestures or imperative commands, the router delegate cleanly disposes of its matching state entry using `router.removePage(page)`.
* **Web History Compliance**: Validated full history provider synchronization. Browser address bars and URL paths seamlessly mirror structural route pops during back-button navigation and automated widget testing scopes.


## 0.9.3

* Initial release.
