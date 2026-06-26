import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes/app_routes.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top action bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Beautiful Custom Painted Illustration or Icon Graphic
                  Center(
                    child: Container(
                      height: size.height * 0.35,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 40,
                            right: 40,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 30,
                            left: 50,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.accent.withOpacity(
                                0.1,
                              ),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 100,
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 16),
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 30,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        Text(
                          'Find Specialized Doctors',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 26,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search and filter top specialists based on rating, experience, and consultation fees. Book appointments with ease.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom navigation indicator and buttons
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  // Next Button
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.onboarding2);
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
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
}
