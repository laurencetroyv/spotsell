import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/utils/constants.dart';
import 'package:spotsell/src/ui/feature/guests/sign_up/sign_up_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  late SignUpViewModel _viewModel;
  late AnimationController _animationController;
  late ScrollController _scrollController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel();
    _viewModel.initialize();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scrollController = ScrollController();

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);

    return AdaptiveScaffold(
      appBar: _buildAppBar(context, responsive),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            if (_viewModel.hasError) {
              final message = _viewModel.errorMessage!.split('Exception: ')[1];

              WidgetsBinding.instance.addPostFrameCallback((_) {
                _viewModel.showErrorMessage(message);
              });
              _viewModel.clearError();
            }

            if (responsive.isDesktop) {
              return _buildDesktopLayout(context, responsive);
            } else {
              return _buildMobileLayout(context, responsive);
            }
          },
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb) {
      if (Platform.isIOS || Platform.isMacOS) {
        return CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          automaticBackgroundVisibility: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          border: null,
          middle: Text(
            'Create Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      }
    }

    return null;
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: _buildBrandingSection(context, true),
          ),
        ),
        // Right side - Scrollable Form
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(responsive.extraLargeSpacing),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      // Add some top padding for better visual balance
                      SizedBox(height: responsive.mediumSpacing),
                      _buildSignUpForm(context, responsive, isDesktop: true),
                      // Add bottom padding to ensure last elements are accessible
                      SizedBox(height: responsive.extraLargeSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      return _buildCupertinoMobileLayout(context, responsive);
    } else {
      return _buildMaterialMobileLayout(context, responsive);
    }
  }

  Widget _buildCupertinoMobileLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Branding header
        SliverToBoxAdapter(
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: _buildBrandingSection(context, false),
          ),
        ),
        // Form content
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            child: _buildSignUpForm(context, responsive, isDesktop: false),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialMobileLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: _buildBrandingSection(context, false),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Form content
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(responsive.horizontalPadding),
            child: _buildSignUpForm(context, responsive, isDesktop: false),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection(BuildContext context, bool isDesktop) {
    return _buildAnimatedSlide(
      delay: 0,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            SvgPicture.asset(
              Constants.logoWithoutName,
              width: isDesktop ? 120 : 80,
              height: isDesktop ? 120 : 80,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Text(
              'SPOTSELL',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              'FILIPINO. HANDMADE. MARKET.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: 1.2,
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(height: 32),
              Text(
                'Join our community of makers and sellers',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm(
    BuildContext context,
    ResponsiveBreakpoints responsive, {
    required bool isDesktop,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) const SizedBox(height: 24),

          // Title
          _buildAnimatedSlide(
            delay: 200,
            child: Text(
              'Create Account',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Profile Picture
          _buildAnimatedSlide(
            delay: 250,
            child: _buildProfilePictureSection(context, responsive),
          ),

          SizedBox(height: responsive.largeSpacing),

          // Name fields row
          _buildAnimatedSlide(
            delay: 300,
            child: Row(
              children: [
                Expanded(
                  child: AdaptiveTextField(
                    controller: _viewModel.firstNameController,
                    label: 'First Name',
                    placeholder: 'Enter first name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                  ),
                ),
                SizedBox(width: responsive.mediumSpacing),
                Expanded(
                  child: AdaptiveTextField(
                    controller: _viewModel.lastNameController,
                    label: 'Last Name',
                    placeholder: 'Enter last name',
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Phone Number field
          _buildAnimatedSlide(
            delay: 500,
            child: AdaptiveTextField(
              controller: _viewModel.phoneController,
              label: 'Phone Number',
              placeholder: 'Enter your phone number',
              maxLength: 15,
              prefixIcon: Icons.contact_phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Username field
          _buildAnimatedSlide(
            delay: 400,
            child: AdaptiveTextField(
              controller: _viewModel.usernameController,
              label: 'Username',
              placeholder: 'Choose a username',
              prefixIcon: Icons.alternate_email,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                LengthLimitingTextInputFormatter(20),
              ],
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Email field
          _buildAnimatedSlide(
            delay: 500,
            child: AdaptiveTextField(
              controller: _viewModel.emailController,
              label: 'Email',
              placeholder: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          if (!kIsWeb && Platform.isWindows)
            _buildAnimatedSlide(
              delay: 600,
              child: fl.InfoLabel(
                label: 'Date of Birth',
                child: SizedBox(
                  width: double.infinity,
                  child: fl.CalendarDatePicker(
                    dateFormatter: DateFormat.yMMMMEEEEd(),
                    maxDate: DateTime.now(),
                    onSelectionChanged: (value) {
                      _validateFluintCalendarDatePicker(value.selectedDates);
                    },
                  ),
                ),
              ),
            )
          else
            // Date of Birth field
            _buildAnimatedSlide(
              delay: 600,
              child: GestureDetector(
                onTap: () => _selectDateOfBirth(context),
                child: AbsorbPointer(
                  child: AdaptiveTextField(
                    controller: _viewModel.dateOfBirthController,
                    label: 'Date of Birth',
                    placeholder: 'Select your date of birth',
                    prefixIcon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
            ),

          SizedBox(height: responsive.mediumSpacing),

          // Gender selection
          _buildAnimatedSlide(
            delay: 700,
            child: _buildGenderSelection(context, responsive),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Password field
          _buildAnimatedSlide(
            delay: 800,
            child: AdaptiveTextField(
              controller: _viewModel.passwordController,
              label: 'Password',
              placeholder: 'Create a password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Confirm Password field
          _buildAnimatedSlide(
            delay: 900,
            child: AdaptiveTextField(
              controller: _viewModel.passwordConfirmationController,
              label: 'Confirm Password',
              placeholder: 'Confirm your password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
          ),

          SizedBox(height: responsive.largeSpacing),

          // Sign Up button
          _buildAnimatedSlide(
            delay: 1000,
            child: AdaptiveButton(
              onPressed: _viewModel.isLoading ? null : _viewModel.handleSignUp,
              isLoading: _viewModel.isLoading,
              size: AdaptiveButtonSize.large,
              child: const Text('Create Account'),
            ),
          ),

          SizedBox(height: responsive.mediumSpacing),

          // Sign In link
          _buildAnimatedSlide(
            delay: 1100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: _viewModel.handleSignIn,
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.largeSpacing),

          // Terms and Privacy
          _buildAnimatedSlide(
            delay: 1200,
            child: Text(
              'By creating an account, you agree to our Terms of Service and Privacy Policy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (!isDesktop) SizedBox(height: responsive.extraLargeSpacing),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                context,
                'Male',
                Icons.male,
                true,
                _viewModel.gender == true,
              ),
            ),
            SizedBox(width: responsive.smallSpacing),
            Expanded(
              child: _buildGenderOption(
                context,
                'Female',
                Icons.female,
                false,
                _viewModel.gender == false,
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewModel.gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSlide({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
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
                            _viewModel.setDateOfBirth(selectedDate!);
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
                    initialDateTime: eighteenYearsAgo,
                    minimumDate: hundredYearsAgo,
                    maximumDate: eighteenYearsAgo,
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
          initialDate: eighteenYearsAgo,
          firstDate: hundredYearsAgo,
          lastDate: eighteenYearsAgo,
          helpText: 'Select your date of birth',
          fieldLabelText: 'Date of Birth',
        );

        if (selectedDate != null) {
          _viewModel.setDateOfBirth(selectedDate);
        }
      }
    } else {
      // Use Material date picker
      selectedDate = await showDatePicker(
        context: context,
        initialDate: eighteenYearsAgo,
        firstDate: hundredYearsAgo,
        lastDate: eighteenYearsAgo,
        helpText: 'Select your date of birth',
        fieldLabelText: 'Date of Birth',
      );

      if (selectedDate != null) {
        _viewModel.setDateOfBirth(selectedDate);
      }
    }
  }

  Widget _buildProfilePictureSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Column(
      children: [
        Text('Profile Picture', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showImagePickerOptions(context),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: _viewModel.profilePicture != null
                ? Stack(
                    children: [
                      ClipOval(
                        child: kIsWeb
                            ? Image.memory(_viewModel.profilePicture!.bytes!)
                            : Image.file(
                                _viewModel.profilePicture!.file!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _viewModel.removeProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  void _validateFluintCalendarDatePicker(List<DateTime> dates) {
    if (dates.isNotEmpty) {
      final date = dates[0];
      _viewModel.setDateOfBirth(date);
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        _showDesktopImagePicker(context);
      } else if (Platform.isIOS) {
        _showCupertinoImagePicker(context);
      } else {
        _showMaterialImagePicker(context);
      }
    } else {
      _showMaterialImagePicker(context);
    }
  }

  void _showDesktopImagePicker(BuildContext context) {
    _viewModel.selectProfilePicture(ImageSource.gallery);
  }

  void _showCupertinoImagePicker(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Profile Picture'),
        message: const Text(
          'Choose how you want to select your profile picture',
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel.selectProfilePicture(ImageSource.gallery);
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
              _viewModel.selectProfilePicture(ImageSource.camera);
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

  void _showMaterialImagePicker(BuildContext context) {
    showModalBottomSheet<void>(
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
              'Select Profile Picture',
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
                      _viewModel.selectProfilePicture(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
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
                      _viewModel.selectProfilePicture(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
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
