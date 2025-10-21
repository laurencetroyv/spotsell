import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';

class StoreFormDialog extends StatefulWidget {
  const StoreFormDialog({super.key, this.store, this.isEditing = false});

  final Store? store;
  final bool isEditing;

  @override
  State<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late StoreRepository _storeRepository;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _initializeForm();
  }

  void _initializeRepository() {
    try {
      _storeRepository = getService<StoreRepository>();
    } catch (e) {
      debugPrint(
        'Warning: StoreRepository not available in ServiceLocator: $e',
      );
      setState(() {
        _errorMessage = 'Store service unavailable. Please restart the app.';
      });
    }
  }

  void _initializeForm() {
    if (widget.isEditing && widget.store != null) {
      _nameController.text = widget.store!.name;
      _descriptionController.text = widget.store!.description ?? '';
      _phoneController.text = widget.store!.phone ?? '';
      _emailController.text = widget.store!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (Platform.isIOS) {
      return _buildCupertinoDialog(context, responsive);
    }

    return _buildMaterialDialog(context, responsive);
  }

  Widget _buildMaterialDialog(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Store' : 'Create New Store'),
      content: Container(
        width: responsive.isDesktop ? 400 : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: _buildFormContent(context, responsive),
      ),
      actions: _buildDialogActions(context, responsive),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildCupertinoDialog(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return CupertinoAlertDialog(
      title: Text(widget.isEditing ? 'Edit Store' : 'Create New Store'),
      content: Container(
        width: responsive.isDesktop ? 400 : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: _buildFormContent(context, responsive),
        ),
      ),
      actions: _buildCupertinoActions(context, responsive),
    );
  }

  Widget _buildFormContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return _buildErrorContent(context, responsive);
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Store Name (Required)
          AdaptiveTextField(
            controller: _nameController,
            label: 'Store Name',
            placeholder: 'Enter store name',
            prefixIcon: Icons.store,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Description (Optional)
          AdaptiveTextField(
            controller: _descriptionController,
            label: 'Description',
            placeholder: 'Describe your store (optional)',
            prefixIcon: Icons.description,
            textInputAction: TextInputAction.next,
            maxLines: 3,
            maxLength: 500,
            enabled: !_isLoading,
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Phone (Optional)
          AdaptiveTextField(
            controller: _phoneController,
            label: 'Phone Number',
            placeholder: 'Enter phone number (optional)',
            prefixIcon: Icons.phone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            enabled: !_isLoading,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\(\)\s]')),
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Email (Optional)
          AdaptiveTextField(
            controller: _emailController,
            label: 'Email Address',
            placeholder: 'Enter email address (optional)',
            prefixIcon: Icons.email,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),

          if (_isLoading) ...[
            SizedBox(height: responsive.mediumSpacing),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlatformLoadingIndicator(),
                  SizedBox(width: responsive.smallSpacing),
                  Text(
                    widget.isEditing
                        ? 'Updating store...'
                        : 'Creating store...',
                    style: ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: responsive.mediumSpacing),
        Text(
          'Service Error',
          style: ThemeUtils.getAdaptiveTextStyle(
            context,
            TextStyleType.title,
          )?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: responsive.smallSpacing),
        Text(
          _errorMessage!,
          style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlatformLoadingIndicator() {
    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    }
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  List<Widget> _buildDialogActions(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _isLoading ? null : _handleSubmit,
        child: Text(widget.isEditing ? 'Update' : 'Create'),
      ),
    ];
  }

  List<Widget> _buildCupertinoActions(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return [
      CupertinoDialogAction(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: _isLoading ? null : _handleSubmit,
        child: Text(widget.isEditing ? 'Update' : 'Create'),
      ),
    ];
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Result<Store> result;

      if (widget.isEditing && widget.store != null) {
        // Update existing store
        final updateRequest = UpdateStoreRequest(
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

        result = await _storeRepository.updateStore(
          widget.store!.id,
          updateRequest,
        );
      } else {
        // Create new store
        final createRequest = CreateStoreRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );

        result = await _storeRepository.createStore(createRequest);
      }

      switch (result) {
        case Ok<Store>():
          setState(() => _isLoading = false);
          if (mounted) {
            Navigator.of(context).pop(result.value);
            _showSuccessMessage(context, result.value);
          }
          break;
        case Error<Store>():
          setState(() {
            _isLoading = false;
            _errorMessage = result.toString();
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  bool _validateForm() {
    // Clear any existing error
    setState(() => _errorMessage = null);

    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Store name is required');
      return false;
    }

    if (_nameController.text.trim().length < 3) {
      setState(
        () => _errorMessage = 'Store name must be at least 3 characters',
      );
      return false;
    }

    // Validate email format if provided
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return false;
    }

    // Validate phone format if provided
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && phone.length < 10) {
      setState(() => _errorMessage = 'Phone number must be at least 10 digits');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).hasMatch(email);
  }

  void _showSuccessMessage(BuildContext context, Store store) {
    final message = widget.isEditing
        ? 'Store "${store.name}" updated successfully!'
        : 'Store "${store.name}" created successfully!';

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // Material
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
