import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/seller/view_models/add_products_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  late AddProductsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddProductsViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _viewModel.store = ModalRoute.of(context)!.settings.arguments! as Store;
    final responsive = ResponsiveBreakpoints.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return AdaptiveScaffold(
          appBar: _buildAppBar(context),
          isLoading: _viewModel.isLoading,
          child: _buildScrollableContent(context, responsive),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    final widget = AppBar(
      title: const Text('Add Product'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.back)),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          middle: const Text('Add Product'),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        );
        // return null;
      }
    }

    return widget;
  }

  Widget _buildScrollableContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    final maxWidth = responsive.isDesktop ? 800.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.horizontalPadding),
          child: _buildContent(context, responsive),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ResponsiveBreakpoints responsive) {
    if (responsive.isDesktop) {
      return _buildDesktopLayout(context, responsive);
    } else {
      return _buildMobileLayout(context, responsive);
    }
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildBasicInfoSection(context, responsive),
                  SizedBox(height: responsive.mediumSpacing),
                  _buildDetailsSection(context, responsive),
                ],
              ),
            ),
            SizedBox(width: responsive.largeSpacing),
            Expanded(
              child: Column(
                children: [
                  _buildImagesSection(context, responsive),
                  SizedBox(height: responsive.largeSpacing),
                  _buildSubmitButton(context, responsive),
                ],
              ),
            ),
          ],
        ),
        if (_viewModel.hasError) ...[
          SizedBox(height: responsive.mediumSpacing),
          _buildErrorMessage(context, _viewModel.errorMessage!),
        ],
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBasicInfoSection(context, responsive),
        SizedBox(height: responsive.mediumSpacing),
        _buildDetailsSection(context, responsive),
        SizedBox(height: responsive.mediumSpacing),
        _buildImagesSection(context, responsive),
        SizedBox(height: responsive.largeSpacing),
        _buildSubmitButton(context, responsive),
        if (_viewModel.hasError) ...[
          SizedBox(height: responsive.mediumSpacing),
          _buildErrorMessage(context, _viewModel.errorMessage!),
        ],
      ],
    );
  }

  Widget _buildBasicInfoSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return _buildAdaptiveCard(
      context,
      responsive,
      title: 'Basic Information',
      icon: ThemeUtils.getAdaptiveIcon(AdaptiveIcon.add),
      child: Column(
        children: [
          AdaptiveTextField(
            controller: _viewModel.titleController,
            label: 'Product Title',
            placeholder: 'Enter product title',
            enabled: !_viewModel.isLoading,
            width: double.infinity,
          ),
          SizedBox(height: responsive.mediumSpacing),
          AdaptiveTextField(
            controller: _viewModel.descriptionController,
            label: 'Description',
            placeholder: 'Enter product description',
            maxLines: responsive.isDesktop ? 6 : 4,
            enabled: !_viewModel.isLoading,
            width: double.infinity,
          ),
          SizedBox(height: responsive.mediumSpacing),
          AdaptiveTextField(
            controller: _viewModel.priceController,
            label: 'Price',
            placeholder: 'Enter price',
            keyboardType: TextInputType.number,
            enabled: !_viewModel.isLoading,
            width: double.infinity,
            prefixIcon: Icons.attach_money,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return _buildAdaptiveCard(
      context,
      responsive,
      title: 'Product Details',
      icon: ThemeUtils.getAdaptiveIcon(AdaptiveIcon.settings),
      child: Column(
        children: [
          _buildConditionSelector(context, responsive),
          SizedBox(height: responsive.mediumSpacing),
          _buildStatusSelector(context, responsive),
        ],
      ),
    );
  }

  Widget _buildConditionSelector(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Condition'),
        SizedBox(height: responsive.smallSpacing),
        _buildAdaptiveSelector<Condition>(
          context,
          responsive,
          values: Condition.values,
          selected: _viewModel.selectedCondition,
          onChanged: (value) {
            if (value != null) {
              _viewModel.setCondition(value);
            }
          },
          displayText: (condition) => Product(
            title: '',
            description: '',
            price: '',
            condition: condition,
            status: Status.available,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ).properCondition,
        ),
      ],
    );
  }

  Widget _buildStatusSelector(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Status'),
        SizedBox(height: responsive.smallSpacing),
        _buildAdaptiveSelector<Status>(
          context,
          responsive,
          values: Status.values,
          selected: _viewModel.selectedStatus,
          onChanged: (value) {
            if (value != null) {
              _viewModel.setStatus(value);
            }
          },
          displayText: (status) => Product(
            title: '',
            description: '',
            price: '',
            condition: Condition.good,
            status: status,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ).properStatuses,
        ),
      ],
    );
  }

  Widget _buildAdaptiveSelector<T extends Object>(
    BuildContext context,
    ResponsiveBreakpoints responsive, {
    required List<T> values,
    required T selected,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return _buildCupertinoSelector<T>(
          context,
          values: values,
          selected: selected,
          onChanged: onChanged,
          displayText: displayText,
        );
      }

      if (Platform.isWindows) {
        return _buildFluentSelector<T>(
          context,
          values: values,
          selected: selected,
          onChanged: onChanged,
          displayText: displayText,
        );
      }
    }

    // Material dropdown for Android/Web/Linux
    return _buildMaterialDropdown<T>(
      context,
      values: values,
      selected: selected,
      onChanged: onChanged,
      displayText: displayText,
    );
  }

  Widget _buildCupertinoSelector<T extends Object>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    if (values.length <= 4) {
      return CupertinoSlidingSegmentedControl<T>(
        children: {
          for (final value in values)
            value: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                displayText(value),
                style: const TextStyle(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        },
        onValueChanged: onChanged,
        groupValue: selected,
        backgroundColor: CupertinoColors.systemGrey6,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CupertinoPicker(
          itemExtent: 32,
          onSelectedItemChanged: (index) => onChanged(values[index]),
          children: values.map((value) => Text(displayText(value))).toList(),
        ),
      );
    }
  }

  Widget _buildFluentSelector<T extends Object>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required ValueChanged<T>? onChanged,
    required String Function(T) displayText,
  }) {
    return fl.ComboBox<T>(
      value: selected,
      onChanged: onChanged != null
          ? (T? value) {
              if (value != null) {
                onChanged(value);
              }
            }
          : null,
      items: values.map((value) {
        return fl.ComboBoxItem<T>(
          value: value,
          child: Text(displayText(value)),
        );
      }).toList(),
    );
  }

  Widget _buildMaterialDropdown<T extends Object>(
    BuildContext context, {
    required List<T> values,
    required T selected,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: selected,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: values.map((value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(displayText(value)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImagesSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return _buildAdaptiveCard(
      context,
      responsive,
      title: 'Product Images',
      icon: Icons.photo_library,
      action: !_viewModel.isLoading
          ? _buildAddImageButton(context, responsive)
          : null,
      child: _buildImageGrid(context, responsive),
    );
  }

  Widget _buildAddImageButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb && Platform.isWindows) {
      return fl.SplitButton(
        flyout: fl.MenuFlyout(
          items: [
            fl.MenuFlyoutItem(
              text: const Text('From Gallery'),
              onPressed: _viewModel.pickImage,
            ),
            fl.MenuFlyoutItem(
              text: const Text('Take Photo'),
              onPressed: _viewModel.pickImageFromCamera,
            ),
          ],
        ),
        child: const Icon(fl.FluentIcons.add_friend),
      );
    }

    if (!kIsWeb && (Platform.isMacOS || Platform.isIOS)) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showImagePickerOptions(context),
        child: const Icon(CupertinoIcons.photo_on_rectangle),
      );
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'gallery') {
          _viewModel.pickImage();
        } else if (value == 'camera') {
          _viewModel.pickImageFromCamera();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library),
              SizedBox(width: 8),
              Text('From Gallery'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8),
              Text('Take Photo'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.add_photo_alternate,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Image'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.pickImage();
            },
            child: const Text('From Gallery'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.pickImageFromCamera();
            },
            child: const Text('Take Photo'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_viewModel.attachments.isEmpty) {
      return Container(
        height: responsive.isDesktop ? 200 : 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: ThemeUtils.getTextColor(context).withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ThemeUtils.getAdaptiveIcon(AdaptiveIcon.add),
                size: responsive.isDesktop ? 48 : 32,
                color: ThemeUtils.getTextColor(context).withValues(alpha: 0.5),
              ),
              SizedBox(height: responsive.smallSpacing),
              Text(
                'No images added yet',
                style:
                    ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.caption,
                    )?.copyWith(
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final crossAxisCount = responsive.isDesktop
        ? 4
        : responsive.isTablet
        ? 3
        : 2;
    final itemSize =
        (MediaQuery.of(context).size.width -
            (responsive.horizontalPadding * 2) -
            (responsive.smallSpacing * (crossAxisCount - 1))) /
        crossAxisCount;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: responsive.smallSpacing,
        mainAxisSpacing: responsive.smallSpacing,
        childAspectRatio: 1,
      ),
      itemCount: _viewModel.attachments.length,
      itemBuilder: (context, index) {
        return _buildImageTile(context, index, itemSize);
      },
    );
  }

  Widget _buildImageTile(BuildContext context, int index, double size) {
    final imageData = _viewModel.attachments[index];

    return Stack(
      children: [
        ClipRRect(
          borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
          child: _buildAdaptiveImage(imageData, size),
        ),
        if (!_viewModel.isLoading)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _viewModel.removeAttachment(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        // Optional: Show file size indicator
        if (!_viewModel.isLoading)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatFileSize(imageData.size),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdaptiveImage(ImageData imageData, double size) {
    if (kIsWeb) {
      // For web, use Image.memory with bytes
      if (imageData.bytes != null) {
        return Image.memory(
          imageData.bytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorPlaceholder(size);
          },
        );
      }
    } else {
      // For native platforms, use Image.file
      if (imageData.file != null) {
        return Image.file(
          imageData.file!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImageErrorPlaceholder(size);
          },
        );
      }
    }

    // Fallback for invalid image data
    return _buildImageErrorPlaceholder(size);
  }

  Widget _buildImageErrorPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey.shade600,
            size: size * 0.3,
          ),
          const SizedBox(height: 4),
          Text(
            'Error',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return AdaptiveButton(
      onPressed: _viewModel.isFormValid && !_viewModel.isLoading
          ? () => _viewModel.createProduct()
          : null,
      type: AdaptiveButtonType.primary,
      size: responsive.isDesktop
          ? AdaptiveButtonSize.large
          : AdaptiveButtonSize.medium,
      isLoading: _viewModel.isLoading,
      width: double.infinity,
      icon: _viewModel.isLoading
          ? null
          : Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.add)),
      child: Text(
        _viewModel.isLoading ? 'Creating Product...' : 'Create Product',
        style: TextStyle(
          fontSize: responsive.isDesktop ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(ResponsiveBreakpoints.of(context).mediumSpacing),
      decoration: BoxDecoration(
        color: (ThemeUtils.isDarkMode(context)
            ? Colors.red.shade900
            : Colors.red.shade50),
        border: Border.all(color: Colors.red.shade300),
        borderRadius: ThemeUtils.getAdaptiveBorderRadius(context),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          SizedBox(width: ResponsiveBreakpoints.of(context).smallSpacing),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveCard(
    BuildContext context,
    ResponsiveBreakpoints responsive, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    final cardDecoration = ThemeUtils.getAdaptiveCardDecoration(context);

    return Container(
      decoration: cardDecoration,
      padding: EdgeInsets.all(responsive.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: responsive.isDesktop ? 24 : 20,
                color: ThemeUtils.getPrimaryColor(context),
              ),
              SizedBox(width: responsive.smallSpacing),
              Expanded(
                child: Text(
                  title,
                  style:
                      ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.title,
                      )?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextColor(context),
                      ),
                ),
              ),
              if (action != null) action,
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body)
          ?.copyWith(
            fontWeight: FontWeight.w600,
            color: ThemeUtils.getTextColor(context),
          ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
