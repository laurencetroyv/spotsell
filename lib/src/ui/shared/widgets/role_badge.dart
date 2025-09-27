import 'package:flutter/material.dart';

import 'package:spotsell/src/core/theme/theme_utils.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final String role;

  @override
  Widget build(BuildContext context) {
    final roleData = _getRoleData(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: roleData['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: roleData['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleData['icon'], size: 12, color: roleData['color']),
          const SizedBox(width: 4),
          Text(
            roleData['label'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: roleData['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRoleData(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return {
          'label': 'Admin',
          'icon': Icons.admin_panel_settings,
          'color': Colors.purple.shade600,
        };
      case 'seller':
        return {
          'label': 'Seller',
          'icon': ThemeUtils.getAdaptiveIcon(AdaptiveIcon.store),
          'color': Colors.blue.shade600,
        };
      default:
        return {
          'label': 'Buyer',
          'icon': Icons.shopping_bag,
          'color': Colors.green.shade600,
        };
    }
  }
}
