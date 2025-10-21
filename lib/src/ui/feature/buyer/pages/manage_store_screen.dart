import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/navigation/navigation_extensions.dart';
import 'package:spotsell/src/core/navigation/route_names.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/repositories/store_repository.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/feature/buyer/utils/store_dialog_utils.dart';
import 'package:spotsell/src/ui/feature/buyer/view_models/manage_store_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_popup_menu.dart';
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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => isLoading = true);
    try {
      _authService = getService<AuthService>();
      _storeRepository = getService<StoreRepository>();

      _viewModel = ManageStoreViewModel(
        storeRepository: _storeRepository,
        authService: _authService,
      );

      _viewModel.initialize();

      await _viewModel.loadStores();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return AdaptiveScaffold(
          isLoading: isLoading,
          appBar: _buildAppBar(context, responsive),
          floatingActionButton: _buildFloatingActionButton(context, responsive),
          child: SafeArea(child: _buildBody(context, responsive)),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text('Manage Stores'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(ThemeUtils.getAdaptiveIcon(AdaptiveIcon.back)),
        ),
      );
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
      if (Platform.isMacOS) {
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
    if (_viewModel.stores.isEmpty) {
      return _buildEmptyState(context, responsive);
    }

    return _buildStoresList(context, responsive);
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
        if (!kIsWeb && (Platform.isMacOS || Platform.isWindows))
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
    final items = [
      PopupMenuItem(
        value: 'open',
        onTap: () async {
          await _handleOpenStore(store);
        },
        child: Row(
          children: [
            Icon(Icons.launch, size: 18, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Open Store'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'edit',
        onTap: () async {
          await _handleEditStore(store);
        },
        child: Row(
          children: [
            Icon(Icons.edit, size: 18, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            const Text('Edit Store'),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'delete',
        onTap: () async {
          await _handleDeleteStore(store);
        },
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red.shade600),
            const SizedBox(width: 12),
            const Text('Delete Store'),
          ],
        ),
      ),
    ];

    final card = Container(
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
              if (!kIsWeb && !(Platform.isMacOS || Platform.isIOS))
                AdaptivePopupMenu(
                  items: items,
                  child: Icon(
                    Icons.more_vert,
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.7),
                  ),
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

    if (!kIsWeb) {
      if (Platform.isMacOS || Platform.isIOS) {
        return Slidable(
          endActionPane: ActionPane(
            motion: DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _handleDeleteStore(store),
                icon: Icons.delete,
                label: 'Delete',
                backgroundColor: Colors.red,
              ),
            ],
          ),
          child: card,
        );
      }
    }

    return card;
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
    try {
      await context.pushNamedAndClearStack(RouteNames.seller, arguments: store);
    } catch (e) {
      debugPrint('Error opening store: $e');
      _showErrorMessage('Failed to open store. Please try again.');
    }
  }

  void _showSuccessMessage(String message) {
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

  void _showErrorMessage(String message) {
    if (Platform.isIOS) {
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
