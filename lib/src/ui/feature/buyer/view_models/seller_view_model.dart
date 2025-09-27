import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/shared/view_model/base_view_model.dart';

class SellerViewModel extends BaseViewModel {
  late TabController tabController;
  final TextEditingController searchController = TextEditingController();

  bool extend = false;
  int selectedNavIndex = 0;

  // Favorites and following sets
  final Set<String> _favoriteItems = <String>{};
  final Set<String> _followingUsers = <String>{};

  final List<String> categories = [
    'Property',
    'Autos',
    'Mobile Phones & Gadgets',
  ];

  final List<String> tabs = ['Top Picks', 'Nearby', 'Free Items', 'Following'];

  List<Widget> pages = [];

  // Getters for favorites and following
  Set<String> get favoriteItems => Set.unmodifiable(_favoriteItems);
  Set<String> get followingUsers => Set.unmodifiable(_followingUsers);

  /// Check if an item is in favorites
  bool isFavorite(String itemId) {
    return _favoriteItems.contains(itemId);
  }

  /// Toggle favorite status of an item
  void toggleFavorite(String itemId) {
    if (_favoriteItems.contains(itemId)) {
      _favoriteItems.remove(itemId);
    } else {
      _favoriteItems.add(itemId);
    }
    safeNotifyListeners();
  }

  /// Add item to favorites
  void addToFavorites(String itemId) {
    if (!_favoriteItems.contains(itemId)) {
      _favoriteItems.add(itemId);
      safeNotifyListeners();
    }
  }

  /// Remove item from favorites
  void removeFromFavorites(String itemId) {
    if (_favoriteItems.remove(itemId)) {
      safeNotifyListeners();
    }
  }

  /// Clear all favorites
  void clearFavorites() {
    if (_favoriteItems.isNotEmpty) {
      _favoriteItems.clear();
      safeNotifyListeners();
    }
  }

  /// Get favorites count
  int get favoritesCount => _favoriteItems.length;

  /// Check if following a user/seller
  bool isFollowing(String userId) {
    return _followingUsers.contains(userId);
  }

  /// Toggle following status of a user
  void toggleFollowing(String userId) {
    if (_followingUsers.contains(userId)) {
      _followingUsers.remove(userId);
    } else {
      _followingUsers.add(userId);
    }
    safeNotifyListeners();
  }

  /// Follow a user
  void followUser(String userId) {
    if (!_followingUsers.contains(userId)) {
      _followingUsers.add(userId);
      safeNotifyListeners();
    }
  }

  /// Unfollow a user
  void unfollowUser(String userId) {
    if (_followingUsers.remove(userId)) {
      safeNotifyListeners();
    }
  }

  /// Clear all following
  void clearFollowing() {
    if (_followingUsers.isNotEmpty) {
      _followingUsers.clear();
      safeNotifyListeners();
    }
  }

  /// Get following count
  int get followingCount => _followingUsers.length;

  /// Search functionality
  String get searchQuery => searchController.text;

  /// Clear search
  void clearSearch() {
    searchController.clear();
    safeNotifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchController.text = query;
    safeNotifyListeners();
  }

  /// Navigation functionality
  void updateSelectedNavIndex(int index) {
    if (selectedNavIndex != index) {
      selectedNavIndex = index;
      safeNotifyListeners();
    }
  }

  /// Toggle extended state (for navigation rail)
  void toggleExtended() {
    extend = !extend;
    safeNotifyListeners();
  }

  /// Initialize tab controller (call this from your screen's initState)
  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: tabs.length, vsync: vsync);
  }

  /// Load user preferences (favorites, following) from storage
  Future<void> loadUserPreferences() async {
    await executeAsync(() async {
      // TODO: Load favorites and following from secure storage or API
      // This is where you'd integrate with your actual data persistence

      // Example implementation:
      // final favoritesJson = await secureStorage.read(key: 'favorites');
      // if (favoritesJson != null) {
      //   final favoritesList = jsonDecode(favoritesJson) as List<dynamic>;
      //   _favoriteItems.addAll(favoritesList.cast<String>());
      // }

      // final followingJson = await secureStorage.read(key: 'following');
      // if (followingJson != null) {
      //   final followingList = jsonDecode(followingJson) as List<dynamic>;
      //   _followingUsers.addAll(followingList.cast<String>());
      // }

      debugPrint('User preferences loaded');
    }, errorMessage: 'Failed to load user preferences');
  }

  /// Save user preferences to storage
  Future<void> saveUserPreferences() async {
    await executeAsync(() async {
      // TODO: Save favorites and following to secure storage or API

      // Example implementation:
      // await secureStorage.write(
      //   key: 'favorites',
      //   value: jsonEncode(_favoriteItems.toList()),
      // );

      // await secureStorage.write(
      //   key: 'following',
      //   value: jsonEncode(_followingUsers.toList()),
      // );

      debugPrint('User preferences saved');
    }, errorMessage: 'Failed to save user preferences');
  }

  /// Initialize the view model
  @override
  void initialize() {
    super.initialize();
    // Load user preferences when initializing
    loadUserPreferences();
  }

  @override
  void dispose() {
    // Save preferences before disposing
    saveUserPreferences();

    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
