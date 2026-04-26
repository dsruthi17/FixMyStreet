import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../config/routes.dart';
import '../../core/utils/helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AppAuthProvider>(context, listen: false);
      final complaints = Provider.of<ComplaintProvider>(context, listen: false);
      if (auth.currentUser != null) {
        debugPrint(
            'Profile: Loading complaints for user ${auth.currentUser!.uid}');
        complaints.streamMyComplaints(auth.currentUser!.myComplaintIds);
      }
    });
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final auth = Provider.of<AppAuthProvider>(context, listen: false);
    final currentName = auth.currentUser?.displayName ?? '';
    final controller = TextEditingController(text: currentName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentName) {
      final success = await auth.updateProfile(displayName: result);
      if (success && mounted) {
        Helpers.showSnackBar(context, 'Name updated successfully');
        setState(() {}); // Refresh UI
      } else if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update name', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final auth = Provider.of<AppAuthProvider>(context);
    final complaints = Provider.of<ComplaintProvider>(context);
    final user = auth.currentUser;

    // Calculate complaint stats - include 'assigned' and 'pending' as in-progress
    final myComplaints = complaints.myComplaints;
    final totalReported = myComplaints.length;
    final inProgress = myComplaints
        .where((c) =>
            c.status == 'in_progress' ||
            c.status == 'in progress' ||
            c.status == 'assigned' ||
            c.status == 'pending')
        .length;
    final resolved = myComplaints.where((c) => c.status == 'resolved').length;

    debugPrint(
        'Profile Stats - Total: $totalReported, In Progress: $inProgress, Resolved: $resolved');

    // Use display name or phone number as fallback
    final displayName = (user != null && user.displayName.isNotEmpty)
      ? user.displayName
      : ((user != null && user.phoneNumber.isNotEmpty)
        ? user.phoneNumber
        : 'User');
    final email = user?.email ?? 'No email';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showEditNameDialog(context),
                            icon: const Icon(Icons.edit,
                                size: 18, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(totalReported.toString(),
                              localizations.translate('total')),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildStatItem(inProgress.toString(),
                              localizations.translate('inProgress')),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          _buildStatItem(resolved.toString(),
                              localizations.translate('resolved')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Menu items
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    'Activity',
                    [
                      _buildMenuItem(
                        context,
                        Icons.list_alt_rounded,
                        AppStrings.myComplaints,
                        'View your reported issues',
                        AppColors.primary,
                        () => Navigator.pushNamed(
                            context, AppRoutes.myComplaints),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.map_rounded,
                        'Map View',
                        'See complaints on map',
                        AppColors.success,
                        () => Navigator.pushNamed(context, AppRoutes.mapView),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Preferences',
                    [
                      _buildMenuItem(
                        context,
                        Icons.settings_rounded,
                        AppStrings.settings,
                        'Language, theme & more',
                        AppColors.accent,
                        () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.notifications_rounded,
                        AppStrings.notifications,
                        'Manage notifications',
                        AppColors.info,
                        () => Navigator.pushNamed(
                            context, AppRoutes.notifications),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    'Support',
                    [
                      _buildMenuItem(
                        context,
                        Icons.help_outline_rounded,
                        'Help & FAQ',
                        'Get help and answers',
                        Colors.teal,
                        () => Navigator.pushNamed(context, AppRoutes.faq),
                      ),
                      _buildMenuItem(
                        context,
                        Icons.info_outline_rounded,
                        AppStrings.about,
                        'About FixMyStreet',
                        Colors.blueGrey,
                        () => Navigator.pushNamed(context, AppRoutes.about),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirm = await Helpers.showConfirmDialog(
                          context,
                          title: AppStrings.logout,
                          message: AppStrings.logoutConfirm,
                          confirmText: AppStrings.logout,
                          confirmColor: AppColors.error,
                        );
                        if (confirm && context.mounted) {
                          final auth = Provider.of<AppAuthProvider>(context,
                              listen: false);
                          await auth.signOut();
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.border,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
