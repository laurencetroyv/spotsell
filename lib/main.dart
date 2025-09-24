import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:yaru/yaru.dart';

import 'package:spotsell/src/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isFuchsia) {
      await YaruWindowTitleBar.ensureInitialized();
    }
  }

  usePathUrlStrategy();
  runApp(const App());
}
