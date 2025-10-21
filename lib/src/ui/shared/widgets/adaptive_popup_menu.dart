import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptivePopupMenu extends StatelessWidget {
  const AdaptivePopupMenu({
    super.key,
    required this.child,
    required this.items,
  });

  final Widget child;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      return _buildCupertinoPopupMenu();
    }

    return _buildMaterialPopupMenu();
  }

  Widget _buildCupertinoPopupMenu() {
    return CupertinoContextMenu(
      actions: items.map((e) {
        final item = e as PopupMenuItem;
        return CupertinoContextMenuAction(
          onPressed: item.onTap,
          child: item.child!,
        );
      }).toList(),
      child: child,
    );
  }

  Widget _buildMaterialPopupMenu() {
    return PopupMenuButton(
      icon: child,
      itemBuilder: (context) {
        return items.map((e) {
          return PopupMenuItem(child: e);
        }).toList();
      },
    );
  }
}
