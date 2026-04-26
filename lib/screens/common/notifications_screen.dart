import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('notifications')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Notification settings header
          const Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how you want to be notified about your complaints',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Settings cards
          _buildNotificationCard(
            context,
            icon: Icons.notifications_active,
            title: 'Push Notifications',
            subtitle: 'Get instant updates on your device',
            value: true,
            onChanged: (val) {
              // TODO: Implement push notification toggle
            },
          ),
          const SizedBox(height: 16),

          _buildNotificationCard(
            context,
            icon: Icons.email,
            title: 'Email Notifications',
            subtitle: 'Receive updates via email',
            value: false,
            onChanged: (val) {
              // TODO: Implement email notification toggle
            },
          ),
          const SizedBox(height: 32),

          // Notification types
          const Text(
            'Notification Types',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildNotificationTypeCard(
            context,
            icon: Icons.assignment_turned_in,
            title: 'Status Updates',
            subtitle: 'When your complaint status changes',
            color: AppColors.success,
            enabled: true,
          ),
          const SizedBox(height: 12),

          _buildNotificationTypeCard(
            context,
            icon: Icons.engineering,
            title: 'Worker Assigned',
            subtitle: 'When a worker is assigned to your issue',
            color: AppColors.info,
            enabled: true,
          ),
          const SizedBox(height: 12),

          _buildNotificationTypeCard(
            context,
            icon: Icons.check_circle,
            title: 'Issue Resolved',
            subtitle: 'When your issue is marked as resolved',
            color: AppColors.success,
            enabled: true,
          ),
          const SizedBox(height: 12),

          _buildNotificationTypeCard(
            context,
            icon: Icons.message,
            title: 'New Comments',
            subtitle: 'When someone comments on your complaint',
            color: AppColors.accent,
            enabled: false,
          ),

          const SizedBox(height: 32),

          // Recent notifications
          const Text(
            'Recent Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildEmptyNotifications(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? AppColors.success : AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifications() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll be notified when there are updates on your complaints',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
