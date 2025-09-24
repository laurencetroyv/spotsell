import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class SellerScreen extends StatelessWidget {
  const SellerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveScaffold(child: Center(child: Text("Seller")));
  }
}
