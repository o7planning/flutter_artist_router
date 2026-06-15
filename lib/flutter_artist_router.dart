import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_artist_core/flutter_artist_core.dart';

// ignore: unused_import
import 'src/url_strategy_non_web.dart';

export 'package:flutter_web_plugins/url_strategy.dart'
    if (dart.library.io) 'src/url_strategy_non_web.dart'
    show setUrlStrategy, PathUrlStrategy;

part 'src/core/duplicate_route_error.dart';
part 'src/core/fa_context_navigation.dart';
part 'src/core/fa_dialog_page.dart';
part 'src/core/fa_navigation.dart';
part 'src/core/fa_route.dart';
part 'src/core/fa_route_data.dart';
part 'src/core/fa_route_guard.dart';
part 'src/core/fa_route_state.dart';
part 'src/core/route_key.dart';
part 'src/delegate.dart';
part 'src/enums/duplicate_route_policy.dart';
part 'src/enums/navigation_action.dart';
part 'src/parser.dart';
part 'src/router.dart';
part 'src/router_bridge.dart';
part 'src/typedefs/fa_route_builder.dart';
part 'src/utils/utils.dart';
