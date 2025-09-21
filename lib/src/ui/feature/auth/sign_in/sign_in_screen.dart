import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:spotsell/src/core/theme/responsive_breakpoints.dart';
import 'package:spotsell/src/core/theme/theme_utils.dart';
import 'package:spotsell/src/core/utils/constants.dart';
import 'package:spotsell/src/ui/feature/auth/sign_in/view_model/sign_in_view_model.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_text_field.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late SignInViewModel _viewModel;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel();
    _viewModel.initialize();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: _buildBackgroundDecoration(context),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, child) {
              if (_viewModel.hasError) {
                final message = _viewModel.errorMessage!.split(
                  'Exception: ',
                )[1];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _viewModel.showErrorMessage(message);
                });
                _viewModel.clearError();
              }

              final responsive = ResponsiveBreakpoints.of(context);

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (responsive.isDesktop) {
                    return _buildDesktopLayout(context, responsive);
                  }
                  return _buildMobileLayout(context, responsive);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(BuildContext context) {
    final isDark = ThemeUtils.isDarkMode(context);
    final primaryColor = ThemeUtils.getPrimaryColor(context);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1A1A1A),
                const Color(0xFF2D2D2D),
                primaryColor.withValues(alpha: 0.1),
              ]
            : [
                const Color(0xFFFAFAFA),
                const Color(0xFFF0F0F0),
                primaryColor.withValues(alpha: 0.05),
              ],
        stops: const [0.0, 0.6, 1.0],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          // Left side - Branding and illustration
          Expanded(flex: 6, child: _buildBrandingSection(context, responsive)),
          // Right side - Sign in form
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.all(responsive.largeSpacing),
              child: Center(
                child: _buildSignInCard(context, responsive, isDesktop: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.horizontalPadding),
        child: Column(
          children: [
            SizedBox(height: responsive.extraLargeSpacing),
            _buildMobileBranding(context, responsive),
            SizedBox(height: responsive.largeSpacing),
            _buildSignInCard(context, responsive, isDesktop: false),
            SizedBox(height: responsive.mediumSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSection(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return Container(
      padding: EdgeInsets.all(responsive.extraLargeSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo and name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: ThemeUtils.getPrimaryColor(
                  //       context,
                  //     ).withValues(alpha: 0.3),
                  //     blurRadius: 20,
                  //     offset: const Offset(0, 8),
                  //   ),
                  // ],
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  Constants.logoWithoutName,
                  width: 44,
                  height: 44,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                Constants.title,
                style:
                    ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.headline,
                    )?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.getPrimaryColor(context),
                    ),
              ),
            ],
          ),
          SizedBox(height: responsive.extraLargeSpacing),

          // Welcome message
          Text(
            'Welcome back to your\nlocal marketplace!',
            style: ThemeUtils.getAdaptiveTextStyle(
              context,
              TextStyleType.headline,
            )?.copyWith(fontSize: 48, fontWeight: FontWeight.w300, height: 1.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to continue buying and selling with your community. Discover unique items, connect with neighbors, and help reduce waste together.',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body)
                ?.copyWith(
                  fontSize: 18,
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.7),
                  height: 1.5,
                ),
          ),
          SizedBox(height: responsive.extraLargeSpacing),

          // Feature highlights from carousel items
          ..._buildFeatureHighlights(context, responsive),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureHighlights(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    // Use the first 3 carousel items as feature highlights
    final features = Constants.carouselItems.take(3).toList();

    return features
        .map(
          (carouselItem) => Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: carouselItem.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: carouselItem.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    carouselItem.icon,
                    color: carouselItem.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carouselItem.title,
                        style: ThemeUtils.getAdaptiveTextStyle(
                          context,
                          TextStyleType.title,
                        )?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        carouselItem.subtitle,
                        style:
                            ThemeUtils.getAdaptiveTextStyle(
                              context,
                              TextStyleType.body,
                            )?.copyWith(
                              color: ThemeUtils.getTextColor(
                                context,
                              ).withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildMobileBranding(
    BuildContext context,
    ResponsiveBreakpoints responsive,
  ) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: SvgPicture.asset(
              Constants.logoWithoutName,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Constants.title,
            style:
                ThemeUtils.getAdaptiveTextStyle(
                  context,
                  TextStyleType.headline,
                )?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getPrimaryColor(context),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Filipino. Handmade. Market.',
            style: ThemeUtils.getAdaptiveTextStyle(context, TextStyleType.body)
                ?.copyWith(
                  color: ThemeUtils.getTextColor(
                    context,
                  ).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard(
    BuildContext context,
    ResponsiveBreakpoints responsive, {
    required bool isDesktop,
  }) {
    final cardWidth = isDesktop ? 400.0 : double.infinity;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: cardWidth,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 400 : double.infinity,
        ),
        decoration: ThemeUtils.getAdaptiveCardDecoration(context),

        padding: EdgeInsets.all(isDesktop ? 40 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Sign In',
              style: ThemeUtils.getAdaptiveTextStyle(
                context,
                TextStyleType.headline,
              )?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your credentials to access your account',
              style:
                  ThemeUtils.getAdaptiveTextStyle(
                    context,
                    TextStyleType.body,
                  )?.copyWith(
                    color: ThemeUtils.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.largeSpacing),

            // Email field
            _buildAnimatedField(
              delay: 400,
              child: AdaptiveTextField(
                controller: _viewModel.email,
                label: 'Email Address',
                placeholder: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            SizedBox(height: responsive.mediumSpacing),

            // Password field
            _buildAnimatedField(
              delay: 500,
              child: AdaptiveTextField(
                controller: _viewModel.password,
                label: 'Password',
                placeholder: 'Enter your password',
                prefixIcon: Icons.lock_outlined,
                obscureText: true,
                suffixIcon: Icons.visibility_outlined,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _viewModel.handleSignIn(),
              ),
            ),
            SizedBox(height: responsive.smallSpacing),

            // Forgot password
            _buildAnimatedField(
              delay: 600,
              child: Align(
                alignment: Alignment.centerRight,
                child: AdaptiveButton(
                  onPressed: _viewModel.handleForgotPassword,
                  type: AdaptiveButtonType.text,
                  size: AdaptiveButtonSize.small,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: ThemeUtils.getPrimaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: responsive.mediumSpacing),

            // Sign in button
            _buildAnimatedField(
              delay: 700,
              child: AdaptiveButton(
                onPressed: _viewModel.isLoading
                    ? null
                    : _viewModel.handleSignIn,
                type: AdaptiveButtonType.primary,
                isLoading: _viewModel.isLoading,
                isEnabled: !_viewModel.isLoading,
                width: double.infinity,
                child: const Text('Sign In'),
              ),
            ),
            SizedBox(height: responsive.largeSpacing),

            // Divider
            _buildAnimatedField(
              delay: 800,
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: ThemeUtils.getTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: ThemeUtils.getTextColor(
                        context,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.mediumSpacing),

            // Sign up link
            _buildAnimatedField(
              delay: 1000,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: ThemeUtils.getAdaptiveTextStyle(
                      context,
                      TextStyleType.body,
                    ),
                  ),
                  GestureDetector(
                    onTap: _viewModel.handleSignUp,
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        color: ThemeUtils.getPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedField({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
