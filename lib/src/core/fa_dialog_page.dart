part of '../../flutter_artist_router.dart';

/// A custom [Page] implementation for displaying dialogs within the Navigator 2.0 stack.
class FaDialogPage<T> extends Page<T> {
  /// The specific dialog widget structure to overlay and display on top of the active screen context.
  final Widget child;

  /// Indicates whether tapping the background barrier area dismisses this declarative dialog instance natively.
  final bool barrierDismissible;

  /// The shade configuration defining the backdrop color cast over beneath the dialog widget layout lines.
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
