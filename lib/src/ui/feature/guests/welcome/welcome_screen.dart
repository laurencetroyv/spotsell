import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotsell/src/ui/feature/guests/welcome/view_model/welcome_view_model.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/widgets/carousel_page_indicator_widget.dart';
import 'package:spotsell/src/ui/feature/guests/welcome/widgets/carousel_widget.dart';
import 'package:spotsell/src/ui/shared/widgets/adaptive_button.dart';
import 'package:spotsell/src/ui/shell/adaptive_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late WelcomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _viewModel = WelcomeViewModel();
    _viewModel.initialize();

    // Listen to ViewModel changes to sync PageController
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_pageController.hasClients &&
        _pageController.page?.round() != _viewModel.currentIndex) {
      _pageController.animateToPage(
        _viewModel.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            // Show error state if there's an error
            if (_viewModel.hasError) {
              return _buildErrorState(context);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isLargeScreen = constraints.maxWidth > 600;

                if (isLargeScreen) {
                  return _buildRowLayout(context);
                } else {
                  return _buildColumnLayout(context);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _viewModel.errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _viewModel.clearError,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildCarousel(context, isLargeScreen: true)),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: _buildAuthSection(context),
          ),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 1, child: _buildCarousel(context, isLargeScreen: false)),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildAuthSection(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, {required bool isLargeScreen}) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _viewModel.setCurrentIndex(index);
                _viewModel
                    .onUserInteraction(); // Pause auto-play on user interaction
              },
              itemCount: _viewModel.carouselItems.length,
              itemBuilder: (context, index) {
                return CarouselWidget(_viewModel.carouselItems[index]);
              },
            ),
          ),
          const SizedBox(height: 20),
          CarouselPageIndicatorWidget(
            _viewModel.carouselItems,
            currentIndex: _viewModel.currentIndex,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context) {
    final isLoading = _viewModel.isLoading;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome to SpotSell',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your local marketplace for buying and selling',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AdaptiveButton(
          width: 330,
          isLoading: isLoading,
          onPressed: _viewModel.handleContinueWithEmail,
          child: isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Continue with Email'),
        ),
        const SizedBox(height: 16),
        AdaptiveButton(
          width: 330,
          isLoading: isLoading,
          onPressed: _viewModel.handleSignIn,
          type: AdaptiveButtonType.secondary,
          child: Text('Sign In'),
        ),
        const SizedBox(height: 24),
        _buildTermsText(context),
      ],
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(
          context,
        ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}
