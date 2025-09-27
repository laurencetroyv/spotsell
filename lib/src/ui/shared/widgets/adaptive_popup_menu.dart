import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';

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
    final controller = fl.FlyoutController();
    return fl.FlyoutTarget(
      controller: controller,
      child: AdaptiveButton(
        type: AdaptiveButtonType.text,
        onPressed: () {
          controller.showFlyout(
            autoModeConfiguration: fl.FlyoutAutoConfiguration(
              preferredMode: fl.FlyoutPlacementMode.bottomLeft,
            ),
            builder: (context) {
              return fl.MenuFlyout(
                items: items.map((e) {
                  final item = e as PopupMenuItem;

                  return fl.MenuFlyoutItem(
                    text: item.child!,
                    onPressed: item.onTap,
                  );
                }).toList(),
              );
            },
          );
        },
        child: child,
      ),
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
