import 'package:spotsell/src/data/entities/user_role.dart';

class RouteNames {
  // Auth Routes
  static const String welcome = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Main app routes
  static const String home = '/home'; // This will be handled by AuthGuard
  static const String buyer = '/buyer';
  static const String seller = '/seller';
  static const String admin = '/admin';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static const List<String> allRoutes = [
    welcome,
    signIn,
    signUp,
    home,
    buyer,
    seller,
    admin,
    profile,
    settings,
  ];

  // Helper method to check if route requires authentication
  static bool requiresAuth(String routeName) {
    const authRequiredRoutes = [home, buyer, seller, admin, profile, settings];
    return authRequiredRoutes.contains(routeName);
  }

  // Helper method to get role-specific route
  static String getRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return admin;
      case UserRole.seller:
        return seller;
      case UserRole.buyer:
        return buyer;
    }
  }
}
