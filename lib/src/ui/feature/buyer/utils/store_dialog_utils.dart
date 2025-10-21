import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/store_form_dialog.dart';

class StoreDialogUtils {
  /// Show store creation dialog
  static Future<Store?> showCreateStoreDialog(BuildContext context) async {
    return await _showStoreDialog(
      context,
      const StoreFormDialog(isEditing: false),
    );
  }

  /// Show store editing dialog
  static Future<Store?> showEditStoreDialog(
    BuildContext context,
    Store store,
  ) async {
    return await _showStoreDialog(
      context,
      StoreFormDialog(store: store, isEditing: true),
    );
  }

  static Future<Store?> _showStoreDialog(
    BuildContext context,
    Widget dialog,
  ) async {
    if (Platform.isIOS) {
      return await showCupertinoDialog<Store>(
        context: context,
        barrierDismissible: false,
        builder: (context) => dialog,
      );
    }

    // Material
    return await showDialog<Store>(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog,
    );
  }

  /// Show confirmation dialog for store deletion
  static Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    Store store,
  ) async {
    if (Platform.isIOS) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Delete Store'),
          content: Text(
            'Are you sure you want to delete "${store.name}"? This action cannot be undone.',
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      return result ?? false;
    }

    // Material
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store'),
        content: Text(
          'Are you sure you want to delete "${store.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return result ?? false;
  }
}
