import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_artist_core/flutter_artist_core.dart';

// ignore: unused_import
import 'src/url_strategy_non_web.dart';

export 'package:flutter_web_plugins/url_strategy.dart'
    if (dart.library.io) 'src/url_strategy_non_web.dart'
    show setUrlStrategy, PathUrlStrategy;

part 'src/core.dart';
part 'src/delegate.dart';
part 'src/parser.dart';
part 'src/router.dart';
part 'src/typedefs.dart';
part 'src/utils.dart';
