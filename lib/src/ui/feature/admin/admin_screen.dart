import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveScaffold(child: Center(child: Text("Admin")));
  }
}
