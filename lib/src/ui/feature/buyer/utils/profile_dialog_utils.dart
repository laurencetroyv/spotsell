import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/ui/feature/buyer/widgets/edit_profile_dialog.dart';

class ProfileDialogUtils {
  /// Show edit profile dialog
  static Future<AuthUser?> showEditProfileDialog(
    BuildContext context,
    AuthUser currentUser,
  ) async {
    if (Platform.isMacOS || Platform.isIOS) {
      return await showCupertinoDialog<AuthUser>(
        context: context,
        barrierDismissible: false,
        builder: (context) => EditProfileDialog(user: currentUser),
      );
    }

    // Material
    return await showDialog<AuthUser>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditProfileDialog(user: currentUser),
    );
  }

  /// Show profile picture options dialog
  static Future<void> showProfilePictureOptions(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onRemove,
    bool hasExistingPicture = false,
  }) async {
    if (Platform.isMacOS || Platform.isIOS) {
      await _showCupertinoProfilePictureOptions(
        context,
        onCamera: onCamera,
        onGallery: onGallery,
        onRemove: onRemove,
        hasExistingPicture: hasExistingPicture,
      );
      return;
    }

    // Material
    await _showMaterialProfilePictureOptions(
      context,
      onCamera: onCamera,
      onGallery: onGallery,
      onRemove: onRemove,
      hasExistingPicture: hasExistingPicture,
    );
  }

  static Future<void> _showCupertinoProfilePictureOptions(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onRemove,
    required bool hasExistingPicture,
  }) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Profile Picture'),
        message: const Text(
          'Choose how you want to update your profile picture',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onGallery();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_on_rectangle),
                SizedBox(width: 8),
                Text('Choose from Library'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onCamera();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera),
                SizedBox(width: 8),
                Text('Take Photo'),
              ],
            ),
          ),
          if (hasExistingPicture)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                onRemove();
              },
              isDestructiveAction: true,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.delete),
                  SizedBox(width: 8),
                  Text('Remove Photo'),
                ],
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  static Future<void> _showMaterialProfilePictureOptions(
    BuildContext context, {
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onRemove,
    required bool hasExistingPicture,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Picture',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onGallery();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onCamera();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasExistingPicture) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRemove();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
