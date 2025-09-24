import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class BuyerScreen extends StatelessWidget {
  const BuyerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveScaffold(child: Center(child: Text("Buyer")));
  }
}
