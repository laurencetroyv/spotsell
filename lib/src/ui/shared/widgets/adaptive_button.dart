import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';

/// An adaptive button that provides platform-specific styling and behavior
/// Automatically switches between Material, Cupertino, Fluent, and Yaru designs
class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = AdaptiveButtonType.primary,
    this.size = AdaptiveButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.borderSide,
    this.semanticLabel,
    this.width,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AdaptiveButtonType type;
  final AdaptiveButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderSide? borderSide;
  final String? semanticLabel;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    // Determine if button should be enabled
    final effectivelyEnabled = isEnabled && !isLoading && onPressed != null;

    // Handle loading state
    Widget effectiveChild = isLoading
        ? _buildLoadingIndicator(context)
        : (icon != null ? _buildIconAndText(context) : child);

    Widget button;

    if (Platform.isMacOS || Platform.isIOS) {
      button = _buildCupertinoButton(
        context,
        responsive,
        effectivelyEnabled,
        effectiveChild,
      );
    } else if (Platform.isWindows) {
      button = _buildFluentButton(
        context,
        responsive,
        effectivelyEnabled,
        effectiveChild,
      );
    } else {
      button = _buildMaterialButton(
        context,
        responsive,
        effectivelyEnabled,
        effectiveChild,
      );
    }

    // Wrap with tooltip if provided
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // Add semantic label if provided
    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: effectivelyEnabled,
        child: button,
      );
    }

    return SizedBox(width: width, child: button);
  }

  /// Build loading indicator for current platform
  Widget _buildLoadingIndicator(BuildContext context) {
    final size = _getLoadingIndicatorSize();

    if (Platform.isMacOS || Platform.isIOS) {
      return SizedBox(
        width: size,
        height: size,
        child: CupertinoActivityIndicator(
          color:
              foregroundColor ??
              CupertinoTheme.of(context).primaryContrastingColor,
        ),
      );
    }

    if (Platform.isWindows) {
      return SizedBox(
        width: size,
        height: size,
        child: fl.ProgressRing(
          strokeWidth: 2,
          value: null, // Indeterminate
        ),
      );
    }

    // Material and Yaru
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  /// Build icon and text combination
  Widget _buildIconAndText(BuildContext context) {
    final spacing = _getIconTextSpacing();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) icon!,
        if (icon != null) SizedBox(width: spacing),
        Flexible(child: child),
      ],
    );
  }

  /// Build Cupertino button for iOS/macOS
  Widget _buildCupertinoButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    bool enabled,
    Widget effectiveChild,
  ) {
    final buttonPadding = _getEffectivePadding(responsive);
    final buttonBorderRadius = _getEffectiveBorderRadius(context, responsive);

    switch (type) {
      case AdaptiveButtonType.primary:
        return CupertinoButton.filled(
          onPressed: enabled ? onPressed : null,
          padding: buttonPadding,
          borderRadius: buttonBorderRadius,
          color: backgroundColor,
          disabledColor: disabledColor ?? CupertinoColors.quaternarySystemFill,
          child: effectiveChild,
        );

      case AdaptiveButtonType.secondary:
        return CupertinoButton(
          onPressed: enabled ? onPressed : null,
          padding: buttonPadding,
          borderRadius: buttonBorderRadius,
          color: backgroundColor ?? CupertinoColors.secondarySystemFill,
          disabledColor: disabledColor ?? CupertinoColors.quaternarySystemFill,
          child: effectiveChild,
        );

      case AdaptiveButtonType.text:
        return CupertinoButton(
          onPressed: enabled ? onPressed : null,
          padding: buttonPadding,
          borderRadius: buttonBorderRadius,
          child: effectiveChild,
        );

      case AdaptiveButtonType.destructive:
        return CupertinoButton.filled(
          onPressed: enabled ? onPressed : null,
          padding: buttonPadding,
          borderRadius: buttonBorderRadius,
          color: backgroundColor ?? CupertinoColors.destructiveRed,
          disabledColor: disabledColor ?? CupertinoColors.quaternarySystemFill,
          child: effectiveChild,
        );
    }
  }

  /// Build Fluent button for Windows
  Widget _buildFluentButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    bool enabled,
    Widget effectiveChild,
  ) {
    switch (type) {
      case AdaptiveButtonType.secondary:
        return fl.Button(
          onPressed: enabled ? onPressed : null,
          child: effectiveChild,
        );

      case AdaptiveButtonType.text:
        return fl.HyperlinkButton(
          onPressed: enabled ? onPressed : null,
          child: effectiveChild,
        );

      default:
        return fl.FilledButton(
          onPressed: enabled ? onPressed : null,
          child: effectiveChild,
        );
    }
  }

  /// Build Material button for Android/Linux
  Widget _buildMaterialButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    bool enabled,
    Widget effectiveChild,
  ) {
    final buttonPadding = _getEffectivePadding(responsive);
    final buttonBorderRadius = _getEffectiveBorderRadius(context, responsive);
    final buttonSize = _getButtonSize(responsive);

    final baseStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(buttonSize),
      padding: WidgetStateProperty.all(buttonPadding),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: buttonBorderRadius),
      ),
      backgroundColor: backgroundColor != null
          ? WidgetStateProperty.all(backgroundColor!)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStateProperty.all(foregroundColor!)
          : null,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return (foregroundColor ?? Theme.of(context).colorScheme.primary)
              .withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return (foregroundColor ?? Theme.of(context).colorScheme.primary)
              .withValues(alpha: 0.05);
        }
        return null;
      }),
      elevation: elevation != null ? WidgetStateProperty.all(elevation!) : null,
    );

    switch (type) {
      case AdaptiveButtonType.primary:
        return FilledButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle,
          child: effectiveChild,
        );

      case AdaptiveButtonType.secondary:
        return OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle.copyWith(
            side: borderSide != null
                ? WidgetStateProperty.all(borderSide!)
                : null,
          ),
          child: effectiveChild,
        );

      case AdaptiveButtonType.text:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle,
          child: effectiveChild,
        );

      case AdaptiveButtonType.destructive:
        final theme = Theme.of(context);
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: baseStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(
              backgroundColor ?? theme.colorScheme.error,
            ),
            foregroundColor: WidgetStateProperty.all(
              foregroundColor ?? theme.colorScheme.onError,
            ),
          ),
          child: effectiveChild,
        );
    }
  }

  /// Get effective padding based on size and responsiveness
  EdgeInsetsGeometry _getEffectivePadding(ResponsiveBreakpoints responsive) {
    if (padding != null) return padding!;

    switch (size) {
      case AdaptiveButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: responsive.isDesktop ? 16 : 12,
          vertical: responsive.isDesktop ? 8 : 6,
        );
      case AdaptiveButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: responsive.isDesktop ? 24 : 16,
          vertical: responsive.isDesktop ? 12 : 8,
        );
      case AdaptiveButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: responsive.isDesktop ? 32 : 24,
          vertical: responsive.isDesktop ? 16 : 12,
        );
    }
  }

  /// Get effective border radius
  BorderRadius _getEffectiveBorderRadius(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (borderRadius != null) return borderRadius!;
    return ThemeUtils.getAdaptiveBorderRadius(context);
  }

  /// Get button size for Material buttons
  Size _getButtonSize(ResponsiveBreakpoints responsive) {
    switch (size) {
      case AdaptiveButtonSize.small:
        return Size(
          responsive.isDesktop ? 100 : 80,
          responsive.isDesktop ? 40 : 36,
        );
      case AdaptiveButtonSize.medium:
        return Size(responsive.buttonMinWidth, responsive.buttonHeight);
      case AdaptiveButtonSize.large:
        return Size(
          responsive.isDesktop ? 160 : 140,
          responsive.isDesktop ? 64 : 56,
        );
    }
  }

  /// Get loading indicator size based on button size
  double _getLoadingIndicatorSize() {
    switch (size) {
      case AdaptiveButtonSize.small:
        return 16.0;
      case AdaptiveButtonSize.medium:
        return 20.0;
      case AdaptiveButtonSize.large:
        return 24.0;
    }
  }

  /// Get spacing between icon and text
  double _getIconTextSpacing() {
    switch (size) {
      case AdaptiveButtonSize.small:
        return 6.0;
      case AdaptiveButtonSize.medium:
        return 8.0;
      case AdaptiveButtonSize.large:
        return 10.0;
    }
  }
}

/// Types of adaptive buttons
enum AdaptiveButtonType {
  /// Primary action button (filled/elevated)
  primary,

  /// Secondary action button (outlined)
  secondary,

  /// Text/link button
  text,

  /// Destructive action button (typically red)
  destructive,
}

/// Sizes for adaptive buttons
enum AdaptiveButtonSize { small, medium, large }

/// Convenience constructors for common button types
extension AdaptiveButtonFactory on AdaptiveButton {
  /// Create a primary button
  static AdaptiveButton primary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    AdaptiveButtonSize size = AdaptiveButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    String? semanticLabel,
  }) {
    return AdaptiveButton(
      key: key,
      onPressed: onPressed,
      type: AdaptiveButtonType.primary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Create a secondary button
  static AdaptiveButton secondary({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    AdaptiveButtonSize size = AdaptiveButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderSide? borderSide,
    String? semanticLabel,
  }) {
    return AdaptiveButton(
      key: key,
      onPressed: onPressed,
      type: AdaptiveButtonType.secondary,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderSide: borderSide,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Create a text button
  static AdaptiveButton text({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    AdaptiveButtonSize size = AdaptiveButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    String? tooltip,
    Color? foregroundColor,
    String? semanticLabel,
  }) {
    return AdaptiveButton(
      key: key,
      onPressed: onPressed,
      type: AdaptiveButtonType.text,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      tooltip: tooltip,
      foregroundColor: foregroundColor,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Create a destructive button
  static AdaptiveButton destructive({
    Key? key,
    required VoidCallback? onPressed,
    required Widget child,
    AdaptiveButtonSize size = AdaptiveButtonSize.medium,
    bool isLoading = false,
    bool isEnabled = true,
    Widget? icon,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    String? semanticLabel,
  }) {
    return AdaptiveButton(
      key: key,
      onPressed: onPressed,
      type: AdaptiveButtonType.destructive,
      size: size,
      isLoading: isLoading,
      isEnabled: isEnabled,
      icon: icon,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}
