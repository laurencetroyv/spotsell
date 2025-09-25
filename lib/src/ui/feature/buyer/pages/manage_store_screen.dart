import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/store_request.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/utils/store_dialog_utils.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/manage_store_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class ManageStoresScreen extends StatefulWidget {
  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  late ManageStoreViewModel _viewModel;
  late AuthService _authService;
  late StoreRepository _storeRepository;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _authService = getService<AuthService>();
      _storeRepository = getService<StoreRepository>();

      _viewModel = ManageStoreViewModel(
        storeRepository: _storeRepository,
        authService: _authService,
      );

      _viewModel.initialize();
      _viewModel.addListener(_onViewModelChanged);

      // Load stores
      await _viewModel.loadStores();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return AdaptiveScaffold(
      appBar: _buildAppBar(context, responsive),
      floatingActionButton: _buildFloatingActionButton(context, responsive),
      child: _buildBody(context, responsive),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Manage Stores',
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.back)),
          ),
        );
      }

      if (Platform.isWindows) {
        return PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: fl.FluentTheme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: fl.FluentTheme.of(
                    context,
                  ).resources.cardStrokeColorDefault,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  fl.IconButton(
                    icon: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.back)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Manage Stores',
                    style: fl.FluentTheme.of(context).typography.title,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // Material
    return AppBar(
      title: const Text('Manage Stores'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: ThemeUtils.getBackgroundColor(context),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return null; // iOS doesn't use FABs typically
      }

      if (Platform.isWindows) {
        return null; // Windows uses different patterns
      }
    }

    // Material FAB
    return FloatingActionButton(
      onPressed: _handleCreateStore,
      backgroundColor: ThemeUtils.getPrimaryColor(context),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildBody(BuildContext context, ResponsiveBreakpoints responsive) {
    if (_viewModel.isLoading) {
      return _buildLoadingState(context, responsive);
    }

    if (_viewModel.hasError) {
      return _buildErrorState(context, responsive);
    }

    if (_viewModel.stores.isEmpty) {
      return _buildEmptyState(context, responsive);
    }

    return _buildStoresList(context, responsive);
  }

  Widget _buildLoadingState(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPlatformLoadingIndicator(),
          SizedBox(height: responsive.mediumSpacing),
          Text(
            'Loading your stores...',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: responsive.mediumSpacing),
            Text(
              'Unable to Load Stores',
              style: ThemeUtils.getAdaptiveTextStyle(
                context,
                TextStyleType.title,
              )?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              _viewModel.errorMessage ?? 'An unexpected error occurred',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.largeSpacing),
            AdaptiveButton(
              onPressed: () => _viewModel.loadStores(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 80,
              color: ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.5),
            ),
            SizedBox(height: responsive.largeSpacing),
            Text(
              'No Stores Yet',
              style: ThemeUtils.getAdaptiveTextStyle(
                context,
                TextStyleType.headline,
              )?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: responsive.smallSpacing),
            Text(
              'Create your first store to start selling your items and reach more customers.',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.largeSpacing),
            AdaptiveButton(
              onPressed: _handleCreateStore,
              type: AdaptiveButtonType.primary,
              size: AdaptiveButtonSize.medium,
              icon: const Icon(Icons.add, size: 20, color: Colors.white),
              child: const Text('Create Your First Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoresList(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      children: [
        // Header section with create store button (for non-FAB platforms)
        if (!kIsWeb &&
            (Platform.isMacOS || Platform.isIOS || Platform.isWindows))
          Container(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Stores (${_viewModel.stores.length})',
                    style: ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.title,
                    )?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                AdaptiveButton(
                  onPressed: _handleCreateStore,
                  type: AdaptiveButtonType.primary,
                  size: AdaptiveButtonSize.medium,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  child: const Text('Add Store'),
                ),
              ],
            ),
          ),

        // Stores list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            itemCount: _viewModel.stores.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: responsive.mediumSpacing),
            itemBuilder: (context, index) {
              final store = _viewModel.stores[index];
              return _buildStoreCard(context, responsive, store);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    Store store,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.mediumSpacing),
      decoration: ThemeUtils.getAdaptiveCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ThemeUtils.getPrimaryColor(
                    context,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.storefront,
                  color: ThemeUtils.getPrimaryColor(context),
                  size: 24,
                ),
              ),
              SizedBox(width: responsive.mediumSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: ThemeUtils.getAdaptiveTextStyle(
                        context,
                        TextStyleType.title,
                      )?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (store.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        store.description!,
                        style:
                            ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.caption,
                            )?.copyWith(
                              color: ThemeUtils.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.7),
                ),
                onSelected: (value) => _handleStoreAction(value, store),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'open',
                    child: Row(
                      children: [
                        Icon(
                          Icons.launch,
                          size: 18,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 12),
                        const Text('Open Store'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 12),
                        const Text('Edit Store'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 12),
                        const Text('Delete Store'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Store details
          _buildStoreDetails(context, responsive, store),

          SizedBox(height: responsive.mediumSpacing),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  onPressed: () => _handleOpenStore(store),
                  type: AdaptiveButtonType.primary,
                  size: AdaptiveButtonSize.medium,
                  icon: const Icon(Icons.launch, size: 16, color: Colors.white),
                  child: const Text('Open Store'),
                ),
              ),
              SizedBox(width: responsive.smallSpacing),
              AdaptiveButton(
                onPressed: () => _handleEditStore(store),
                type: AdaptiveButtonType.secondary,
                size: AdaptiveButtonSize.medium,
                icon: Icon(
                  Icons.edit,
                  size: 16,
                  color: ThemeUtils.getPrimaryColor(context),
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreDetails(
    BuildContext context,
    ResponsiveBreakpoints responsive,
    Store store,
  ) {
    final details = <Map<String, String>>[];

    if (store.email?.isNotEmpty == true) {
      details.add({'icon': 'email', 'label': 'Email', 'value': store.email!});
    }

    if (store.phone?.isNotEmpty == true) {
      details.add({'icon': 'phone', 'label': 'Phone', 'value': store.phone!});
    }

    details.add({
      'icon': 'date',
      'label': 'Created',
      'value': _formatDate(store.createdAt),
    });

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      children: details.map((detail) {
        IconData icon;
        switch (detail['icon']) {
          case 'email':
            icon = Icons.email_outlined;
            break;
          case 'phone':
            icon = Icons.phone_outlined;
            break;
          case 'date':
            icon = Icons.calendar_today_outlined;
            break;
          default:
            icon = Icons.info_outlined;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: ThemeUtils.getTextColor(context).withValues(alpha: 0.6),
              ),
              SizedBox(width: responsive.smallSpacing),
              Text(
                '${detail['label']}: ',
                style:
                    ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.caption,
                    )?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.8),
                    ),
              ),
              Expanded(
                child: Text(
                  detail['value']!,
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
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlatformLoadingIndicator() {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return const CupertinoActivityIndicator(radius: 16);
      }
      if (Platform.isWindows) {
        return const fl.ProgressRing();
      }
    }
    return const CircularProgressIndicator();
  }

  Future<void> _handleCreateStore() async {
    try {
      final newStore = await StoreDialogUtils.showCreateStoreDialog(context);
      if (newStore != null) {
        await _viewModel.loadStores(); // Refresh the list
        _showSuccessMessage('Store "${newStore.name}" created successfully!');
      }
    } catch (e) {
      debugPrint('Error creating store: $e');
      _showErrorMessage('Failed to create store. Please try again.');
    }
  }

  Future<void> _handleEditStore(Store store) async {
    try {
      final updatedStore = await StoreDialogUtils.showEditStoreDialog(
        context,
        store,
      );
      if (updatedStore != null) {
        await _viewModel.loadStores(); // Refresh the list
        _showSuccessMessage(
          'Store "${updatedStore.name}" updated successfully!',
        );
      }
    } catch (e) {
      debugPrint('Error editing store: $e');
      _showErrorMessage('Failed to update store. Please try again.');
    }
  }

  Future<void> _handleDeleteStore(Store store) async {
    final shouldDelete = await StoreDialogUtils.showDeleteConfirmationDialog(
      context,
      store,
    );
    if (shouldDelete) {
      try {
        final success = await _viewModel.deleteStore(store.id);
        if (success) {
          _showSuccessMessage('Store "${store.name}" deleted successfully!');
        } else {
          _showErrorMessage(
            _viewModel.errorMessage ?? 'Failed to delete store',
          );
        }
      } catch (e) {
        debugPrint('Error deleting store: $e');
        _showErrorMessage('Failed to delete store. Please try again.');
      }
    }
  }

  Future<void> _handleOpenStore(Store store) async {
    // Navigate to seller screen with store context
    try {
      // For now, just navigate to seller screen
      // You might want to pass store data as arguments
      Navigator.of(
        context,
      ).pushNamed(RouteNames.seller, arguments: {'store': store});
    } catch (e) {
      debugPrint('Error opening store: $e');
      _showErrorMessage('Failed to open store. Please try again.');
    }
  }

  void _handleStoreAction(String action, Store store) {
    switch (action) {
      case 'open':
        _handleOpenStore(store);
        break;
      case 'edit':
        _handleEditStore(store);
        break;
      case 'delete':
        _handleDeleteStore(store);
        break;
    }
  }

  void _showSuccessMessage(String message) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
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

      if (Platform.isWindows) {
        fl.displayInfoBar(
          context,
          builder: (context, close) => fl.InfoBar(
            title: const Text('Success'),
            content: Text(message),
            severity: fl.InfoBarSeverity.success,
            action: fl.IconButton(
              icon: const Icon(fl.FluentIcons.clear),
              onPressed: close,
            ),
          ),
        );
        return;
      }
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

  void _showErrorMessage(String message) {
    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
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

      if (Platform.isWindows) {
        fl.displayInfoBar(
          context,
          builder: (context, close) => fl.InfoBar(
            title: const Text('Error'),
            content: Text(message),
            severity: fl.InfoBarSeverity.error,
            action: fl.IconButton(
              icon: const Icon(fl.FluentIcons.clear),
              onPressed: close,
            ),
          ),
        );
        return;
      }
    }

    // Material
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
