import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

class AdaptiveProgressRing extends StatelessWidget {
  const AdaptiveProgressRing({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoActivityIndicator();
      }

      if (Platform.isWindows) {
        return fl.ProgressRing();
      }

      return CircularProgressIndicator();
    }

    return CircularProgressIndicator.adaptive();
  }
}
