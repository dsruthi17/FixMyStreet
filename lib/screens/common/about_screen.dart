import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.about),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App logo/icon
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handyman_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // App name and version
          const Center(
            child: Text(
              'FixMyStreet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // About section
          _buildSectionCard(
            'About the App',
            'FixMyStreet is a community-driven platform that empowers citizens to report civic issues such as potholes, broken streetlights, water leakage, and more. We connect citizens directly with municipal workers and officers for faster resolution.',
            Icons.info_outline,
          ),
          const SizedBox(height: 16),

          _buildSectionCard(
            'Our Mission',
            'To create cleaner, safer, and better-maintained cities through transparent communication and efficient problem-solving between citizens and civic authorities.',
            Icons.flag_outlined,
          ),
          const SizedBox(height: 16),

          _buildSectionCard(
            'How It Works',
            '1. Report an issue with photos and location\n2. Track the status of your complaint\n3. Get updates as it moves through resolution\n4. Help make your community better',
            Icons.lightbulb_outline,
          ),
          const SizedBox(height: 16),

          _buildSectionCard(
            'Contact Us',
            'Email: care4yourcare.07@gmail.com\n\nFor support, feedback, or suggestions, feel free to reach out to our team.',
            Icons.email_outlined,
          ),
          const SizedBox(height: 32),

          // Developed by
          Center(
            child: Text(
              'Developed with ❤️ for better communities',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2026 FixMyStreet. All rights reserved.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
