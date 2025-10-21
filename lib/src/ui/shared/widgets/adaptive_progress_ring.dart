import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveProgressRing extends StatelessWidget {
  const AdaptiveProgressRing({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator();
    }

    return CircularProgressIndicator.adaptive();
  }
}
