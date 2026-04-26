import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance section
          _buildSectionTitle('Appearance'),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildSwitchTile(
              icon: Icons.dark_mode_rounded,
              iconColor: Colors.deepPurple,
              title: localizations.translate('darkMode'),
              subtitle: themeProvider.isDarkMode
                  ? 'Dark theme active'
                  : 'Light theme active',
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ]),
          const SizedBox(height: 24),

          // Language section
          _buildSectionTitle(localizations.translate('language')),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.primary,
              title: 'English',
              trailing: Radio<String>(
                value: 'en',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (_) => _changeLanguage(
                    context, 'en', authProvider, localeProvider),
                activeColor: AppColors.primary,
              ),
              onTap: () =>
                  _changeLanguage(context, 'en', authProvider, localeProvider),
            ),
            const Divider(height: 1, indent: 56),
            _buildTile(
              icon: Icons.translate_rounded,
              iconColor: AppColors.accent,
              title: 'हिन्दी (Hindi)',
              trailing: Radio<String>(
                value: 'hi',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (_) => _changeLanguage(
                    context, 'hi', authProvider, localeProvider),
                activeColor: AppColors.primary,
              ),
              onTap: () =>
                  _changeLanguage(context, 'hi', authProvider, localeProvider),
            ),
            const Divider(height: 1, indent: 56),
            _buildTile(
              icon: Icons.translate_rounded,
              iconColor: Color(0xFF10B981),
              title: 'తెలుగు (Telugu)',
              trailing: Radio<String>(
                value: 'te',
                groupValue: localeProvider.locale.languageCode,
                onChanged: (_) => _changeLanguage(
                    context, 'te', authProvider, localeProvider),
                activeColor: AppColors.primary,
              ),
              onTap: () =>
                  _changeLanguage(context, 'te', authProvider, localeProvider),
            ),
          ]),
          const SizedBox(height: 24),

          // Notifications section
          _buildSectionTitle(localizations.translate('notifications')),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildSwitchTile(
              icon: Icons.notifications_rounded,
              iconColor: AppColors.success,
              title: 'Push Notifications',
              subtitle: 'Receive status updates',
              value: true,
              onChanged: (_) {
                // Toggle push notifications
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildSwitchTile(
              icon: Icons.email_rounded,
              iconColor: AppColors.info,
              title: 'Email Notifications',
              subtitle: 'Receive email alerts',
              value: false,
              onChanged: (_) {
                // Toggle email notifications
              },
            ),
          ]),
          const SizedBox(height: 24),

          // About section
          _buildSectionTitle(localizations.translate('about')),
          const SizedBox(height: 10),
          _buildCard(context, [
            _buildTile(
              icon: Icons.info_outline_rounded,
              iconColor: Colors.blueGrey,
              title: 'Version',
              trailing: Text(
                '1.0.0',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildTile(
              icon: Icons.description_outlined,
              iconColor: Colors.teal,
              title: 'Terms of Service',
              trailing:
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
              onTap: () {},
            ),
            const Divider(height: 1, indent: 56),
            _buildTile(
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.orange,
              title: 'Privacy Policy',
              trailing:
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _changeLanguage(
    BuildContext context,
    String languageCode,
    AppAuthProvider authProvider,
    LocaleProvider localeProvider,
  ) async {
    // Update UI immediately
    localeProvider.setLocale(Locale(languageCode));

    // Save to database if user is logged in
    if (authProvider.isLoggedIn) {
      final success = await authProvider.updateLanguage(languageCode);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Language changed to $languageCode'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
