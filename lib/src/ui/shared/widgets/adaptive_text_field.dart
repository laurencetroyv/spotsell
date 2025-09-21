import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

class AdaptiveTextField extends StatefulWidget {
  const AdaptiveTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.label,
    this.placeholder,
    this.width,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
  });

  final double? width;
  final String? label;
  final String? placeholder;
  final bool enabled;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget textfield;

    if (Platform.isMacOS || Platform.isIOS) {
      textfield = _buildCupertinoTextField(context);
    } else if (Platform.isWindows) {
      textfield = _buildFluentTextField(context);
    } else {
      textfield = _buildMaterialTextField(context);
    }

    // For Fluent UI, wrap with InfoLabel if label is provided
    if (widget.label != null && Platform.isWindows) {
      textfield = fl.InfoLabel(label: widget.label!, child: textfield);
    }

    return SizedBox(width: widget.width, child: textfield);
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    // Determine suffix icon for password fields or custom suffix
    Widget? suffixWidget;

    if (widget.obscureText) {
      // Password field with visibility toggle
      suffixWidget = GestureDetector(
        onTap: _toggleObscureText,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            _isObscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
            color: CupertinoColors.placeholderText,
            size: 20,
          ),
        ),
      );
    } else if (widget.suffixIcon != null) {
      // Regular suffix icon
      suffixWidget = Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          widget.suffixIcon!,
          color: CupertinoColors.placeholderText,
          size: 20,
        ),
      );
    }

    return CupertinoTextField(
      controller: widget.controller,
      enabled: widget.enabled,
      placeholder: widget.placeholder,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      inputFormatters: widget.inputFormatters,
      prefix: widget.prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                widget.prefixIcon!,
                color: CupertinoColors.placeholderText,
                size: 20,
              ),
            )
          : null,
      suffix: suffixWidget,
    );
  }

  Widget _buildFluentTextField(BuildContext context) {
    final leadingIcon = widget.prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(widget.prefixIcon!, size: 16),
          )
        : null;

    if (widget.obscureText) {
      return fl.PasswordBox(
        revealMode: fl.PasswordRevealMode.peekAlways,
        controller: widget.controller,
        enabled: widget.enabled,
        placeholder: widget.placeholder,
        onChanged: widget.onChanged,
        leadingIcon: leadingIcon,
        onSubmitted: widget.onSubmitted,
        focusNode: widget.focusNode,
      );
    }

    return fl.TextBox(
      controller: widget.controller,
      enabled: widget.enabled,
      placeholder: widget.placeholder,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      inputFormatters: widget.inputFormatters,
      prefix: leadingIcon,
      suffix: widget.suffixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(widget.suffixIcon!, size: 16),
            )
          : null,
    );
  }

  Widget _buildMaterialTextField(BuildContext context) {
    // Determine suffix icon for password fields or custom suffix
    Widget? suffixIcon;

    if (widget.obscureText) {
      // Password field with visibility toggle
      suffixIcon = IconButton(
        icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
        onPressed: _toggleObscureText,
        tooltip: _isObscured ? 'Show password' : 'Hide password',
      );
    } else if (widget.suffixIcon != null) {
      // Regular suffix icon
      suffixIcon = Icon(widget.suffixIcon!);
    }

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: widget.label,
        hintText: widget.placeholder,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon!) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
