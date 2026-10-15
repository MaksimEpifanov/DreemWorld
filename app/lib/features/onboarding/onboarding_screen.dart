import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/responsive_content.dart';

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    this.imageAsset,
  });

  final String title;
  final String description;
  final String? imageAsset;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const <OnboardingPage>[
    OnboardingPage(
      title: 'Знакомства по совместимости',
      description: 'Умный подбор на основе интересов, ценностей и целей',
    ),
    OnboardingPage(
      title: 'Чат + перевод',
      description: 'Коммуницируй без языковых барьеров в реальном времени',
    ),
    OnboardingPage(
      title: 'ИИ-помощник',
      description: 'Советы, переформулировки и ледоколы для общения',
    ),
    OnboardingPage(
      title: 'Твоя история начинается',
      description: 'Создай профиль и найди тех, кто близок по духу',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
          padding: AppSpacing.page,
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (int index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final OnboardingPage page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          page.title,
                          style: AppTextStyles.title(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          page.description,
                          style: AppTextStyles.body(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _pages.length,
                  (int index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              NeonButton(
                onPressed: _next,
                label: _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                expanded: true,
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
