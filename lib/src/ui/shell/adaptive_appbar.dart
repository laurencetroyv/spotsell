import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';

class AdaptiveAppBar extends StatelessWidget {
  const AdaptiveAppBar({super.key, required this.child});

  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return _buildCupertinoAppBar(context, responsive);
      }

      if (Platform.isWindows) {
        return _buildFluentAppBar(context, responsive);
      }
    }

    return _buildMaterialAppBar(context, responsive);
  }

  Widget _buildCupertinoAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return CupertinoNavigationBar(
      middle: child is AppBar ? (child as AppBar).title : null,
      backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      border: Border(
        bottom: BorderSide(
          color: CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildFluentAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return SizedBox();
  }

  Widget _buildMaterialAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return child;
  }
}
