import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    return runApp(App());
  }

  final platform = await PackageInfo.fromPlatform();

  await SentryFlutter.init((options) {
    options.release = platform.version;
    options.environment = Env.ENVIRONMENT;
    options.dsn = Env.SENTRY_DNS;
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(SentryWidget(child: const App())));
}
