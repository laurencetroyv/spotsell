import 'package:flutter/material.dart';

/// Enum representing different user roles
enum UserRole {
  buyer('Buyer'),
  seller('Seller'),
  admin('Admin');

  const UserRole(this.displayName);

  final String displayName;
}

/// Extension to get role-specific properties
extension UserRoleExtension on UserRole {
  /// Get the route name for this role
  String get routeName {
    switch (this) {
      case UserRole.admin:
        return '/admin';
      case UserRole.seller:
        return '/seller';
      case UserRole.buyer:
        return '/buyer';
    }
  }

  /// Get the icon for this role
  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.seller:
        return Icons.store;
      case UserRole.buyer:
        return Icons.shopping_bag;
    }
  }
}
