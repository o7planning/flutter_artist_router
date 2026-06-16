part of '../../flutter_artist_router.dart';

/// Signature definition for an active route construction segment.
/// Provides the targeted widget interface drawing tree corresponding to the captured parameters and state context.
typedef FaRouteBuilder =
    Widget Function(BuildContext context, FaRouteState state);
