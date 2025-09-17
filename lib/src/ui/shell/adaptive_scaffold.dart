import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final dynamic appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS || Platform.isIOS) {
      return _buildCupertinoScaffold(context);
    }

    if (Platform.isWindows) {
      return _buildFluentScaffold(context);
    }

    return _buildMaterialScaffold(context);
  }

  Widget _buildCupertinoScaffold(BuildContext context) {
    return CupertinoPageScaffold(child: child);
  }

  Widget _buildFluentScaffold(BuildContext context) {
    return fl.ScaffoldPage(
      content: child,
      header: appBar,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildMaterialScaffold(BuildContext context) {
    return Scaffold(
      body: child,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
