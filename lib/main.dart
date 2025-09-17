import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spotsell/src/ui/app.dart';
import 'package:yaru/yaru.dart';

Future<void> main() async {
  if (Platform.isLinux || Platform.isFuchsia) {
    await YaruWindowTitleBar.ensureInitialized();
  }

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}
