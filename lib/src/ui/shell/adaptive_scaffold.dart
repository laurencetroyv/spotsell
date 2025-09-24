import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.navigationRail,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final NavigationRail? navigationRail;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return _buildCupertinoScaffold(context, responsive);
      }

      if (Platform.isWindows) {
        return _buildFluentScaffold(context, responsive);
      }
    }

    return _buildMaterialScaffold(context, responsive);
  }

  Widget _buildCupertinoScaffold(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // For Cupertino, we need to handle navigation differently
    if (responsive.shouldShowNavigationRail && navigationRail != null) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
        child: Row(
          children: [
            // Convert NavigationRail to Cupertino-style sidebar
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                border: Border(
                  right: BorderSide(
                    color: CupertinoTheme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: navigationRail,
            ),
            Expanded(
              child: Column(
                children: [
                  if (appBar != null)
                    Container(
                      height: responsive.appBarHeight,
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoTheme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: appBar,
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: appBar != null
          ? CupertinoNavigationBar(
              middle: appBar is AppBar ? (appBar as AppBar).title : null,
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: CupertinoTheme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            )
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      child: Stack(
        children: [
          child,
          if (floatingActionButton != null)
            Positioned(
              right: responsive.horizontalPadding,
              bottom:
                  responsive.verticalPadding +
                  (bottomNavigationBar != null
                      ? kBottomNavigationBarHeight
                      : 0),
              child: floatingActionButton!,
            ),
          if (bottomNavigationBar != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomNavigationBar!,
            ),
        ],
      ),
    );
  }

  Widget _buildFluentScaffold(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // For Fluent UI, use ScaffoldPage with NavigationView if navigation is needed
    if (responsive.shouldShowNavigationRail && navigationRail != null) {
      return fl.NavigationView(
        content: fl.ScaffoldPage(
          content: child,
          header: appBar != null
              ? Container(
                  height: responsive.appBarHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding,
                  ),
                  child: appBar,
                )
              : null,
          padding: EdgeInsets.zero,
        ),
        pane: _buildFluentNavigationPane(context, responsive),
      );
    }

    return fl.ScaffoldPage(
      content: Stack(
        children: [
          child,
          if (floatingActionButton != null)
            Positioned(
              right: responsive.horizontalPadding,
              bottom:
                  responsive.verticalPadding +
                  (bottomNavigationBar != null ? 80 : 0),
              child: floatingActionButton!,
            ),
          if (bottomNavigationBar != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: bottomNavigationBar!,
            ),
        ],
      ),
      header: appBar != null
          ? Container(
              height: responsive.appBarHeight,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
              ),
              child: appBar,
            )
          : null,
      padding: EdgeInsets.zero,
    );
  }

  fl.NavigationPane _buildFluentNavigationPane(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // Convert NavigationRail to Fluent NavigationPane
    final rail = navigationRail!;

    return fl.NavigationPane(
      displayMode: responsive.isDesktop
          ? fl.PaneDisplayMode.open
          : fl.PaneDisplayMode.compact,
      items: rail.destinations.asMap().entries.map((entry) {
        final index = entry.key;
        final destination = entry.value;

        return fl.PaneItem(
          key: ValueKey(index),
          icon: destination.icon,
          title: Text(destination.label.toString()),
          body: const SizedBox.shrink(),
        );
      }).toList(),
      footerItems: rail.trailing != null
          ? [
              fl.PaneItem(
                icon: const Icon(fl.FluentIcons.settings),
                title: const Text('Settings'),
                body: const SizedBox.shrink(),
              ),
            ]
          : [],
    );
  }

  Widget _buildMaterialScaffold(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // For Material, use standard Scaffold with responsive navigation
    if (responsive.shouldShowNavigationRail && navigationRail != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        body: Row(
          children: [
            navigationRail!,
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Column(
                children: [
                  if (appBar != null) appBar!,
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
        endDrawer: endDrawer,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: child,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
