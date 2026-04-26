import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about using FixMyStreet',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildFaqItem(
            'How do I report an issue?',
            'Tap the "+" button on the home screen, take a photo or video of the issue, add a description, select the category, and submit. The app will automatically capture your location.',
          ),
          _buildFaqItem(
            'Can I report anonymously?',
            'Yes! When submitting a complaint, you can enable the "Report Anonymously" option. Your identity will not be shared with other users.',
          ),
          _buildFaqItem(
            'How do I track my complaints?',
            'Go to your Profile screen and tap on "My Complaints" to see all your submitted issues and their current status.',
          ),
          _buildFaqItem(
            'What are the different complaint statuses?',
            '• Pending: Complaint has been submitted and is awaiting review\n• In Progress: A worker has been assigned and is working on it\n• Resolved: The issue has been fixed\n• Rejected: The complaint was reviewed and rejected',
          ),
          _buildFaqItem(
            'How long does it take to resolve an issue?',
            'Resolution time varies depending on the type and severity of the issue. You will receive updates as the status changes.',
          ),
          _buildFaqItem(
            'Can I edit my complaint after submitting?',
            'Currently, complaints cannot be edited after submission. However, you can view them in "My Complaints" and add comments if needed.',
          ),
          _buildFaqItem(
            'What if my location is not detected?',
            'Make sure location services are enabled for this app in your device settings. On web browsers, you may need to allow location access when prompted.',
          ),
          _buildFaqItem(
            'How do I change the app language?',
            'Go to Profile > Settings > Language and select your preferred language (English, Hindi, or Telugu).',
          ),
          _buildFaqItem(
            'Is my data secure?',
            'Yes! We follow industry-standard security practices. Your personal information is encrypted and stored securely on Firebase.',
          ),
          _buildFaqItem(
            'Who can I contact for support?',
            'For technical support or questions, email us at care4yourcare.07@gmail.com',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Still have questions?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact our support team',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open email client
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Email Support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
