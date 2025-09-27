import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:yaru/yaru.dart';

import 'package:spotsell/src/core/utils/env.dart';
import 'package:spotsell/src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isFuchsia) {
      await YaruWindowTitleBar.ensureInitialized();
    }
  }

  usePathUrlStrategy();

  final platform = await PackageInfo.fromPlatform();

  await SentryFlutter.init((options) {
    options.release = platform.version;
    options.environment = Env.ENVIRONMENT;
    options.dsn = Env.SENTRY_DNS;
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
    // The sampling rate for profiling is relative to tracesSampleRate
    // Setting to 1.0 will profile 100% of sampled transactions:
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(SentryWidget(child: const App())));
}
