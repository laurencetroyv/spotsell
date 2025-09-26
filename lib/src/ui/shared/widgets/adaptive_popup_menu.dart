import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

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
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isMacOS) {
        return _buildCupertinoPopupMenu();
      }

      if (Platform.isWindows) {
        return _buildFluentPopupMenu();
      }
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

  Widget _buildFluentPopupMenu() {
    return fl.DropDownButton(
      items: items.map((e) {
        final item = e as PopupMenuItem;

        return fl.MenuFlyoutItem(text: item.child!, onPressed: item.onTap);
      }).toList(),
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
