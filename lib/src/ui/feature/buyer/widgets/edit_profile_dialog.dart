import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:spotsell/src/core/dependency_injection/service_locator.dart';
import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/core/utils/result.dart';
import 'package:spotsell/src/data/entities/entities.dart';
import 'package:spotsell/src/data/services/auth_service.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.user});

  final AuthUser user;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  late AuthService _authService;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  String? _errorMessage;
  bool? _gender; // true = male, false = female
  DateTime? _selectedDateOfBirth;
  ImageData? _newProfilePicture;
  bool _hasProfilePictureChanged = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthService();
    _initializeForm();
  }

  void _initializeAuthService() {
    try {
      _authService = getService<AuthService>();
    } catch (e) {
      debugPrint('Warning: AuthService not available in ServiceLocator: $e');
      setState(() {
        _errorMessage =
            'Authentication service unavailable. Please restart the app.';
      });
    }
  }

  void _initializeForm() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _usernameController.text = widget.user.username;
    _selectedDateOfBirth = widget.user.dateOfBirth;
    _dateOfBirthController.text = DateFormat(
      'MMM dd, yyyy',
    ).format(widget.user.dateOfBirth);

    // Parse gender
    if (widget.user.gender.toLowerCase() == 'male') {
      _gender = true;
    } else if (widget.user.gender.toLowerCase() == 'female') {
      _gender = false;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    if (Platform.isIOS) {
      return _buildCupertinoDialog(context, responsive);
    }

    return _buildMaterialDialog(context, responsive);
  }

  Widget _buildMaterialDialog(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Container(
        width: responsive.isDesktop ? 450 : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: _buildFormContent(context, responsive),
        ),
      ),
      actions: _buildDialogActions(context, responsive),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildCupertinoDialog(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return CupertinoAlertDialog(
      title: const Text('Edit Profile'),
      content: Container(
        width: responsive.isDesktop ? 450 : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: _buildFormContent(context, responsive),
        ),
      ),
      actions: _buildCupertinoActions(context, responsive),
    );
  }

  Widget _buildFormContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return _buildErrorContent(context, responsive);
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Picture Section
          _buildProfilePictureSection(context, responsive),
          SizedBox(height: responsive.largeSpacing),

          // Name fields row
          Row(
            children: [
              Expanded(
                child: AdaptiveTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  placeholder: 'Enter first name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
              ),
              SizedBox(width: responsive.mediumSpacing),
              Expanded(
                child: AdaptiveTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  placeholder: 'Enter last name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Username field
          AdaptiveTextField(
            controller: _usernameController,
            label: 'Username',
            placeholder: 'Enter username',
            prefixIcon: Icons.alternate_email,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
              LengthLimitingTextInputFormatter(20),
            ],
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Date of Birth field
          GestureDetector(
            onTap: _isLoading ? null : () => _selectDateOfBirth(context),
            child: AbsorbPointer(
              child: AdaptiveTextField(
                controller: _dateOfBirthController,
                label: 'Date of Birth',
                placeholder: 'Select your date of birth',
                prefixIcon: Icons.calendar_today_outlined,
                enabled: !_isLoading,
              ),
            ),
          ),
          SizedBox(height: responsive.mediumSpacing),

          // Gender selection
          _buildGenderSelection(context, responsive),

          if (_isLoading) ...[
            SizedBox(height: responsive.mediumSpacing),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlatformLoadingIndicator(),
                  SizedBox(width: responsive.smallSpacing),
                  Text(
                    'Updating profile...',
                    style: ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        SizedBox(height: responsive.mediumSpacing),
        Text(
          'Service Error',
          style: ThemeUtils.getAdaptiveTextStyle(
            context,
            TextStyleType.title,
          )?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: responsive.smallSpacing),
        Text(
          _errorMessage!,
          style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      children: [
        Text(
          'Profile Picture',
          style: ThemeUtils.getAdaptiveTextStyle(
            context,
            TextStyleType.body,
          )?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoading ? null : () => _showImagePickerOptions(context),
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeUtils.getPrimaryColor(
                      context,
                    ).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: ThemeUtils.getPrimaryColor(
                    context,
                  ).withValues(alpha: 0.1),
                ),
                child: _buildProfilePictureContent(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: ThemeUtils.getPrimaryColor(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ThemeUtils.getBackgroundColor(context),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_hasProfilePictureChanged || _newProfilePicture != null)
          AdaptiveButton(
            onPressed: _removeProfilePicture,
            type: AdaptiveButtonType.text,
            size: AdaptiveButtonSize.small,
            child: const Text('Remove Picture'),
          ),
      ],
    );
  }

  Widget _buildProfilePictureContent() {
    if (_newProfilePicture != null) {
      if (kIsWeb) {
        return ClipOval(
          child: Image.memory(
            _newProfilePicture!.bytes!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        );
      }

      return ClipOval(
        child: Image.file(
          _newProfilePicture!.file!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.user.attachments?.isNotEmpty == true) {
      return ClipOval(
        child: Image.network(
          widget.user.attachments!.first.url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      ThemeUtils.getAdaptiveIcon(AdaptiveIcon.profile),
      size: 40,
      color: ThemeUtils.getPrimaryColor(context),
    );
  }

  Widget _buildGenderSelection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: ThemeUtils.getAdaptiveTextStyle(
            context,
            TextStyleType.body,
          )?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context,
                'Male',
                Icons.male,
                true,
                _gender == true,
              ),
            ),
            SizedBox(width: responsive.smallSpacing),
            Expanded(
              child: _buildGenderOption(
                context,
                'Female',
                Icons.female,
                false,
                _gender == false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    String label,
    IconData icon,
    bool value,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _gender = value;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? ThemeUtils.getPrimaryColor(context)
                : ThemeUtils.getTextColor(context).withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? ThemeUtils.getPrimaryColor(context).withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? ThemeUtils.getPrimaryColor(context)
                  : ThemeUtils.getTextColor(context).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
                    color: isSelected
                        ? ThemeUtils.getPrimaryColor(context)
                        : ThemeUtils.getTextColor(context),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformLoadingIndicator() {
    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    }
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  List<Widget> _buildDialogActions(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _isLoading ? null : _handleUpdateProfile,
        child: const Text('Update Profile'),
      ),
    ];
  }

  List<Widget> _buildCupertinoActions(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (_errorMessage != null) {
      return [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }

    return [
      CupertinoDialogAction(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: _isLoading ? null : _handleUpdateProfile,
        child: const Text('Update'),
      ),
    ];
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final thirteenYearsAgo = DateTime(now.year - 13, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    DateTime? selectedDate;

    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isMacOS) {
        // Use Cupertino date picker
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6.resolveFrom(context),
                    border: const Border(
                      bottom: BorderSide(color: CupertinoColors.separator),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () {
                          if (selectedDate != null) {
                            _setDateOfBirth(selectedDate!);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDateOfBirth ?? thirteenYearsAgo,
                    minimumDate: hundredYearsAgo,
                    maximumDate: thirteenYearsAgo,
                    onDateTimeChanged: (DateTime date) {
                      selectedDate = date;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Use Material date picker
        selectedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDateOfBirth ?? thirteenYearsAgo,
          firstDate: hundredYearsAgo,
          lastDate: thirteenYearsAgo,
          helpText: 'Select your date of birth',
          fieldLabelText: 'Date of Birth',
        );

        if (selectedDate != null) {
          _setDateOfBirth(selectedDate);
        }
      }
    } else {
      // Use Material date picker for web
      selectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDateOfBirth ?? thirteenYearsAgo,
        firstDate: hundredYearsAgo,
        lastDate: thirteenYearsAgo,
        helpText: 'Select your date of birth',
        fieldLabelText: 'Date of Birth',
      );

      if (selectedDate != null) {
        _setDateOfBirth(selectedDate);
      }
    }
  }

  void _setDateOfBirth(DateTime date) {
    setState(() {
      _selectedDateOfBirth = date;
      _dateOfBirthController.text = DateFormat('MMM dd, yyyy').format(date);
    });
  }

  Future<void> _showImagePickerOptions(BuildContext context) async {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await _selectProfilePicture(ImageSource.gallery);
      } else if (Platform.isIOS) {
        await _showCupertinoImagePicker(context);
      } else {
        await _showMaterialImagePicker(context);
      }
    } else {
      await _selectProfilePicture(ImageSource.gallery);
    }
  }

  Future<void> _showCupertinoImagePicker(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Update Profile Picture'),
        message: const Text(
          'Choose how you want to update your profile picture',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _selectProfilePicture(ImageSource.gallery);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_on_rectangle),
                SizedBox(width: 8),
                Text('Photo Library'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _selectProfilePicture(ImageSource.camera);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.camera),
                SizedBox(width: 8),
                Text('Camera'),
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

  Future<void> _showMaterialImagePicker(BuildContext context) async {
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
              'Update Profile Picture',
              style: ThemeUtils.getAdaptiveTextStyle(
                context,
                TextStyleType.title,
              )?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _selectProfilePicture(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeUtils.getTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 32,
                            color: ThemeUtils.getPrimaryColor(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gallery',
                            style: ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.body,
                            )?.copyWith(fontWeight: FontWeight.w500),
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
                      _selectProfilePicture(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ThemeUtils.getTextColor(
                            context,
                          ).withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 32,
                            color: ThemeUtils.getPrimaryColor(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera',
                            style: ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.body,
                            )?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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

  Future<void> _selectProfilePicture(ImageSource source) async {
    try {
      late ImageData profilePicture;
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          profilePicture = ImageData(
            bytes: bytes,
            name: pickedFile.name,
            mimeType: pickedFile.mimeType,
          );
        } else {
          profilePicture = ImageData(
            file: File(pickedFile.path),
            name: pickedFile.name,
            mimeType: pickedFile.mimeType,
          );
        }

        setState(() {
          _newProfilePicture = profilePicture;
          _hasProfilePictureChanged = true;
        });
      }
    } catch (e) {
      debugPrint('Error selecting profile picture: $e');
      setState(() {
        _errorMessage = 'Failed to select image. Please try again.';
      });
    }
  }

  void _removeProfilePicture() {
    setState(() {
      _newProfilePicture = null;
      _hasProfilePictureChanged = true;
    });
  }

  Future<void> _handleUpdateProfile() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final username = _usernameController.text;
    final email = widget.user.email;
    final phone = widget.user.phone;
    final dateOfBirth = _selectedDateOfBirth ?? widget.user.dateOfBirth;
    final gender = _gender != null
        ? _gender!
              ? 'Male'
              : 'Female'
        : widget.user.gender;

    List<MultipartFile> multipartFiles = [];

    if (_newProfilePicture != null) {
      if (kIsWeb && _newProfilePicture!.bytes != null) {
        multipartFiles.add(
          MultipartFile.fromBytes(
            _newProfilePicture!.bytes!,
            filename: _newProfilePicture!.displayName,
            contentType: DioMediaType.parse(
              _newProfilePicture!.mimeType ?? 'image/jpeg',
            ),
          ),
        );
      }
    }

    try {
      final user = UpdateUserRequest(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        attachments: multipartFiles,
      );

      final result = await _authService.updateProfile(user);

      switch (result) {
        case Ok<AuthUser>():
          setState(() => _isLoading = false);
          if (mounted) {
            Navigator.of(context).pop(result.value);
            _showSuccessMessage(context);
          }
          break;
        case Error<AuthUser>():
          setState(() {
            _isLoading = false;
            _errorMessage = result.error.toString().replaceAll(
              'Exception: ',
              '',
            );
          });
          break;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  bool _validateForm() {
    setState(() => _errorMessage = null);

    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'First name is required');
      return false;
    }

    if (_firstNameController.text.trim().length < 2) {
      setState(
        () => _errorMessage = 'First name must be at least 2 characters',
      );
      return false;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Last name is required');
      return false;
    }

    if (_lastNameController.text.trim().length < 2) {
      setState(() => _errorMessage = 'Last name must be at least 2 characters');
      return false;
    }

    if (_usernameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Username is required');
      return false;
    }

    if (_usernameController.text.trim().length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters');
      return false;
    }

    if (!_isValidUsername(_usernameController.text.trim())) {
      setState(
        () => _errorMessage =
            'Username can only contain letters, numbers, dots, and underscores',
      );
      return false;
    }

    if (_selectedDateOfBirth == null) {
      setState(() => _errorMessage = 'Please select your date of birth');
      return false;
    }

    if (!_isValidAge(_selectedDateOfBirth!)) {
      setState(() => _errorMessage = 'You must be at least 13 years old');
      return false;
    }

    if (_gender == null) {
      setState(() => _errorMessage = 'Please select your gender');
      return false;
    }

    return true;
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9._]+').hasMatch(username);
  }

  bool _isValidAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return age - 1 >= 13;
    }
    return age >= 13;
  }

  void _showSuccessMessage(BuildContext context) {
    const message = 'Profile updated successfully!';

    if (Platform.isIOS) {
      // Don't show additional dialog on iOS as it's intrusive
      return;
    }

    // Material
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
