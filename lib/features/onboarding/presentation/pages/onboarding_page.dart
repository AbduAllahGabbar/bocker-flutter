import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/routes/routes_manager.dart';
import '../../../auth/data/repository/user_access.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Welcome to Shopy',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Discover your favorite products, manage your cart, and complete checkout securely.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OnboardingStep(
                    title: 'Browse categories',
                    description:
                        'Find items from top brands and local sellers.',
                  ),
                  const SizedBox(height: 16),
                  _OnboardingStep(
                    title: 'Use your cart',
                    description:
                        'Update quantities and apply promotions easily.',
                  ),
                  const SizedBox(height: 16),
                  _OnboardingStep(
                    title: 'Fast checkout',
                    description:
                        'Pay securely and get order updates instantly.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: FilledButton(
          onPressed: () {
            if (UserAccess.isAuthenticated) {
              context.goNamed(RoutesNames.home);
            } else {
              context.goNamed(RoutesNames.signIn);
            }
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final String title;
  final String description;

  const _OnboardingStep({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
          child: Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
