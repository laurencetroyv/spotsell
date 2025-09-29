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
    this.children,
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
    this.signOut,
    this.isLoading,
    this.parentHasBottomNavigationBar = false,
  });

  final Widget child;
  final List<Widget>? children;
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
  final VoidCallback? signOut;
  final bool? isLoading;
  final bool? parentHasBottomNavigationBar;

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
    if (isLoading != null && isLoading!) {
      return CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

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

    late double floatingActionButtonHeight;

    if (parentHasBottomNavigationBar != null || bottomNavigationBar != null) {
      floatingActionButtonHeight = kBottomNavigationBarHeight;
    } else if (bottomNavigationBar != null) {
      floatingActionButtonHeight = responsive.verticalPadding;
    } else {
      floatingActionButtonHeight = 0;
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: appBar as CupertinoNavigationBar?,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      child: (floatingActionButton != null || bottomNavigationBar != null)
          ? Stack(
              children: [
                child,
                if (floatingActionButton != null)
                  Positioned(
                    right: responsive.horizontalPadding,
                    bottom: floatingActionButtonHeight,
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
            )
          : child,
    );
  }

  Widget _buildFluentScaffold(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (isLoading != null && isLoading!) {
      return fl.ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Center(child: fl.ProgressRing()),
      );
    }

    // For Fluent UI, use ScaffoldPage with NavigationView if navigation is needed
    if (navigationRail != null) {
      return fl.NavigationView(
        appBar: responsive.isMobile
            ? fl.NavigationAppBar(automaticallyImplyLeading: false)
            : null,
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
    fl.PaneDisplayMode displayMode = fl.PaneDisplayMode.open;

    if (responsive.isDesktop) {
      displayMode = fl.PaneDisplayMode.open;
    } else if (responsive.isTablet) {
      displayMode = fl.PaneDisplayMode.compact;
    } else {
      displayMode = fl.PaneDisplayMode.minimal;
    }

    List<fl.NavigationPaneItem> items = rail.destinations
        .asMap()
        .entries
        .map<fl.NavigationPaneItem>((entry) {
          final index = entry.key;
          final destination = entry.value;

          return fl.PaneItem(
            key: ValueKey(index),
            icon: destination.icon,
            title: destination.label,
            body: children![index],
          );
        })
        .toList();

    return fl.NavigationPane(
      displayMode: displayMode,
      selected: rail.selectedIndex,
      onChanged: rail.onDestinationSelected,
      items: items,
      footerItems: rail.trailing != null
          ? <fl.NavigationPaneItem>[
              fl.PaneItemAction(
                icon: const Icon(fl.FluentIcons.sign_out),
                onTap: signOut!,
                title: Text('Sign Out'),
              ),
            ]
          : <fl.NavigationPaneItem>[],
    );
  }

  Widget _buildMaterialScaffold(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (isLoading != null && isLoading!) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
