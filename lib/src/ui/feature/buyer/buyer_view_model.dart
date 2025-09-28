import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class BuyerViewModel extends BaseViewModel {
  bool extend = true;
  int selectedNavIndex = 0;

  final List<String> categories = [
    'Property',
    'Autos',
    'Mobile Phones & Gadgets',
  ];

  List<Widget> pages = [];

  // Desktop-specific features
  String _searchQuery = '';
  bool _showAdvancedFilters = false;
  bool _isCompactMode = false;
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.newest;

  // Getters for desktop features
  String get searchQuery => _searchQuery;
  bool get showAdvancedFilters => _showAdvancedFilters;
  bool get isCompactMode => _isCompactMode;
  ViewMode get viewMode => _viewMode;
  SortOption get sortOption => _sortOption;

  void updateSelectedNavIndex(int index) {
    if (selectedNavIndex != index) {
      selectedNavIndex = index;
      safeNotifyListeners();
    }
  }

  void toggleExtended() {
    extend = !extend;
    safeNotifyListeners();
  }

  // Desktop-specific methods
  void updateSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      safeNotifyListeners();
      _performSearch();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    safeNotifyListeners();
  }

  void toggleAdvancedFilters() {
    _showAdvancedFilters = !_showAdvancedFilters;
    safeNotifyListeners();
  }

  void toggleCompactMode() {
    _isCompactMode = !_isCompactMode;
    safeNotifyListeners();
  }

  void setViewMode(ViewMode mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      safeNotifyListeners();
    }
  }

  void setSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      safeNotifyListeners();
      _applySorting();
    }
  }

  // Navigation helpers
  void navigateToTab(int index) {
    if (index >= 0 && index < pages.length) {
      updateSelectedNavIndex(index);
    }
  }

  // Grid configuration for different screen sizes
  int getGridCrossAxisCount(bool isDesktop, bool isTablet, bool isMobile) {
    if (_viewMode == ViewMode.list) return 1;

    if (_isCompactMode) {
      if (isDesktop) return 6;
      if (isTablet) return 4;
      return 2;
    } else {
      if (isDesktop) return 4;
      if (isTablet) return 3;
      return 2;
    }
  }

  double getGridChildAspectRatio() {
    switch (_viewMode) {
      case ViewMode.grid:
        return _isCompactMode ? 0.9 : 0.75;
      case ViewMode.list:
        return 3.0;
      case ViewMode.compact:
        return 1.2;
    }
  }

  // Refresh functionality
  Future<void> refreshCurrentPage() async {
    setLoading(true);
    try {
      // Refresh logic based on current tab
      switch (selectedNavIndex) {
        case 0: // Messages
          await _refreshMessages();
          break;
        case 1: // Explore
          await _refreshExplore();
          break;
        case 2: // Profile
          await _refreshProfile();
          break;
      }
    } catch (e) {
      setError('Refresh failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _refreshMessages() async {
    // Implement messages refresh
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _refreshExplore() async {
    // Implement explore refresh
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _refreshProfile() async {
    // Implement profile refresh
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      // Clear search results
      return;
    }

    setLoading(true);
    try {
      // Implement search logic here
      // This would typically call a repository or service
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simulate API call

      // Update search results
      _notifySearchResults();
    } catch (e) {
      setError('Search failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  void _notifySearchResults() {
    // Notify the explore page about search results
    // This could be done through a stream or callback
  }

  Future<void> _applySorting() async {
    // Implement sorting logic
    // This would typically update the product list
  }

  // Keyboard shortcuts handler
  void handleKeyboardShortcut(KeyboardShortcut shortcut) {
    switch (shortcut) {
      case KeyboardShortcut.search:
        // Focus search - handled in UI
        break;
      case KeyboardShortcut.tab1:
        navigateToTab(0);
        break;
      case KeyboardShortcut.tab2:
        navigateToTab(1);
        break;
      case KeyboardShortcut.tab3:
        navigateToTab(2);
        break;
      case KeyboardShortcut.refresh:
        refreshCurrentPage();
        break;
      case KeyboardShortcut.toggleSidebar:
        toggleExtended();
        break;
    }
  }
}

// Enums for better type safety
enum ViewMode { grid, list, compact }

enum SortOption {
  newest,
  oldest,
  priceLowToHigh,
  priceHighToLow,
  mostPopular,
  nearestLocation,
}

enum KeyboardShortcut { search, tab1, tab2, tab3, refresh, toggleSidebar }

// Extension for display names
extension ViewModeExtension on ViewMode {
  String get displayName {
    switch (this) {
      case ViewMode.grid:
        return 'Grid View';
      case ViewMode.list:
        return 'List View';
      case ViewMode.compact:
        return 'Compact View';
    }
  }

  IconData get icon {
    switch (this) {
      case ViewMode.grid:
        return Icons.grid_view;
      case ViewMode.list:
        return Icons.view_list;
      case ViewMode.compact:
        return Icons.view_module;
    }
  }
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.newest:
        return 'Newest First';
      case SortOption.oldest:
        return 'Oldest First';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.mostPopular:
        return 'Most Popular';
      case SortOption.nearestLocation:
        return 'Nearest Location';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.newest:
        return Icons.access_time;
      case SortOption.oldest:
        return Icons.history;
      case SortOption.priceLowToHigh:
        return Icons.trending_up;
      case SortOption.priceHighToLow:
        return Icons.trending_down;
      case SortOption.mostPopular:
        return Icons.star;
      case SortOption.nearestLocation:
        return Icons.location_on;
    }
  }
}
