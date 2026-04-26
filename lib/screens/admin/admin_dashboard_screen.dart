import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_config.dart';
import '../../core/utils/app_localizations.dart';
import '../../core/utils/helpers.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_card.dart';
import '../user/complaint_detail_screen.dart';
import 'user_management_screen.dart';
import 'analytics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  int _pendingCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    provider.streamAllComplaints();
    provider.loadStats();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _pendingCount = provider.countByStatus('pending');
        _inProgressCount = provider.countByStatus('in_progress');
        _resolvedCount = provider.countByStatus('resolved');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context)!; // Unused variable removed
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                final confirm = await Helpers.showConfirmDialog(
                  context,
                  title: 'Logout',
                  message: AppStrings.logoutConfirm,
                  confirmText: 'Logout',
                  confirmColor: AppColors.error,
                );
                if (confirm && context.mounted) {
                  await Provider.of<AppAuthProvider>(context, listen: false)
                      .signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.landing);
                  }
                }
              },
              tooltip: 'Logout',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.dashboard_rounded, size: 20),
                  text: AppStrings.overview,
                  height: 60,
                ),
                Tab(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.pending_actions_rounded, size: 20),
                          if (_pendingCount > 0)
                            Positioned(
                              right: -8,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    '$_pendingCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(AppStrings.pending),
                    ],
                  ),
                ),
                const Tab(
                  icon: Icon(Icons.work_outline_rounded, size: 20),
                  text: 'Active',
                  height: 60,
                ),
                const Tab(
                  icon: Icon(Icons.check_circle_outline_rounded, size: 20),
                  text: AppStrings.resolved,
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          // Update counts when data changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final pending = provider.countByStatus('pending');
              final inProgress = provider.countByStatus('in_progress');
              final resolved = provider.countByStatus('resolved');
              if (pending != _pendingCount ||
                  inProgress != _inProgressCount ||
                  resolved != _resolvedCount) {
                setState(() {
                  _pendingCount = pending;
                  _inProgressCount = inProgress;
                  _resolvedCount = resolved;
                });
              }
            }
          });

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(provider),
                _buildListTab(provider, 'pending'),
                _buildListTab(provider, 'in_progress'),
                _buildListTab(provider, 'resolved'),
              ],
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════
  // OVERVIEW TAB
  // ════════════════════════════
  Widget _buildOverviewTab(ComplaintProvider provider) {
    final total = provider.complaints.length;
    final pending = provider.countByStatus('pending');
    final inProgress = provider.countByStatus('in_progress');
    final resolved = provider.countByStatus('resolved');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Admin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here\'s what\'s happening with your city today',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrentDate(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stats Grid ──
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: 4 columns on desktop, 2 on mobile
              final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              final childAspectRatio = constraints.maxWidth > 800 ? 1.2 : 1.5;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: childAspectRatio,
                children: [
                  _buildStatCard(
                    'Total Complaints',
                    '$total',
                    Icons.list_alt_rounded,
                    AppColors.primary,
                    total > 0 ? 'Active tracking' : 'No data yet',
                  ),
                  _buildStatCard(
                    'Pending',
                    '$pending',
                    Icons.schedule_rounded,
                    AppColors.warning,
                    pending > 0 ? 'Needs attention' : 'All clear',
                  ),
                  _buildStatCard(
                    'In Progress',
                    '$inProgress',
                    Icons.engineering_rounded,
                    AppColors.info,
                    inProgress > 0 ? 'Being resolved' : 'None active',
                  ),
                  _buildStatCard(
                    'Resolved',
                    '$resolved',
                    Icons.check_circle_rounded,
                    AppColors.success,
                    resolved > 0 ? 'Completed' : 'None yet',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Quick Actions ──
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: 4 columns on desktop, 2 on mobile
              final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  _buildQuickActionCard(
                    'User Management',
                    Icons.people_rounded,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    'Analytics',
                    Icons.analytics_rounded,
                    AppColors.info,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    'Broadcast',
                    Icons.campaign_rounded,
                    AppColors.warning,
                    () => _showBroadcastDialog(),
                  ),
                  _buildQuickActionCard(
                    'Export Data',
                    Icons.download_rounded,
                    AppColors.success,
                    () => _showExportDialog(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Category Breakdown ──
          const Text(
            AppStrings.complaintsByCategory,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: AppConfig.categories.map((cat) {
                final count = provider.countByCategory(cat['id'] as String);
                return _buildCategoryBar(
                  cat['name'] as String,
                  count,
                  total > 0 ? total : 1,
                  Color(cat['color'] as int),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // ── Recent Complaints ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.recentComplaints,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text(AppStrings.viewAll,
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.complaints.isEmpty)
            _buildEmptyState(
              provider.isLoading ? 'Loading...' : 'No complaints yet',
              isLoading: provider.isLoading,
            )
          else
            ...provider.complaints.take(3).map((complaint) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ComplaintCard(
                  title: complaint.title,
                  category: complaint.category,
                  status: complaint.status,
                  location: complaint.address,
                  timeAgo: Helpers.formatTimeAgo(complaint.createdAt),
                  mediaUrls: complaint.mediaUrls,
                  upvotes: complaint.upvotes,
                  showAdminControls: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ComplaintDetailScreen(complaint: complaint),
                      ),
                    );
                  },
                  onStatusChange: (newStatus) {
                    provider.updateStatus(
                      complaintId: complaint.id,
                      newStatus: newStatus,
                      adminId:
                          Provider.of<AppAuthProvider>(context, listen: false)
                                  .currentUser
                                  ?.uid ??
                              '',
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double animValue, child) {
        return Transform.scale(
          scale: 0.9 + (animValue * 0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: color,
                        shadows: [
                          Shadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryBar(String name, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    final percentage = (pct * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($percentage%)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: pct),
                builder: (context, double value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // LIST TAB
  // ════════════════════════════
  Widget _buildListTab(ComplaintProvider provider, String status) {
    final allStatusItems = provider.getByStatus(status);
    final items = allStatusItems.where((c) {
      if (_selectedCategory == 'all') return true;
      return c.category == _selectedCategory;
    }).toList();

    debugPrint(
        'Admin Dashboard - Status: $status, Category: $_selectedCategory, Total: ${allStatusItems.length}, Filtered: ${items.length}');

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                ...AppConfig.categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        cat['name'] as String,
                        cat['id'] as String,
                      ),
                    )),
              ],
            ),
          ),
        ),

        // List
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState('No complaints here')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final complaint = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ComplaintCard(
                        title: complaint.title,
                        category: complaint.category,
                        status: complaint.status,
                        location: complaint.address,
                        timeAgo: Helpers.formatTimeAgo(complaint.createdAt),
                        mediaUrls: complaint.mediaUrls,
                        upvotes: complaint.upvotes,
                        showAdminControls: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ComplaintDetailScreen(complaint: complaint),
                            ),
                          );
                        },
                        onStatusChange: (newStatus) {
                          provider.updateStatus(
                            complaintId: complaint.id,
                            newStatus: newStatus,
                            adminId: Provider.of<AppAuthProvider>(context,
                                        listen: false)
                                    .currentUser
                                    ?.uid ??
                                '',
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isActive = _selectedCategory == value;

    // Map category IDs to icons
    final Map<String, IconData> categoryIcons = {
      'all': Icons.view_list_rounded,
      'roads': Icons.construction_rounded,
      'water_supply': Icons.water_drop_rounded,
      'electricity': Icons.electric_bolt_rounded,
      'sanitation': Icons.clean_hands_rounded,
      'garbage': Icons.delete_rounded,
      'other': Icons.more_horiz_rounded,
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
          debugPrint('Admin: Category filter changed to: $value');
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8)
                  ],
                )
              : null,
          color: isActive ? null : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcons[value] ?? Icons.circle,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, {bool isLoading = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            const CircularProgressIndicator.adaptive()
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (!isLoading)
            const Text(
              'Check back later for updates',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // QUICK ACTION CARD
  // ════════════════════════════
  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════
  // HELPER METHODS
  // ════════════════════════════
  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBroadcastDialog() {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.warning),
            SizedBox(width: 12),
            Text('Send Broadcast Message'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This message will be sent to all users via notification.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (messageController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _showMessage('Broadcast sent to all users!');
              }
            },
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.success),
            SizedBox(width: 12),
            Text('Export Complaints Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('Excel (.xlsx)'),
              subtitle: const Text('Complete data with all fields'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Exporting to Excel format...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('PDF Report'),
              subtitle: const Text('Summary report with charts'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Generating PDF report...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('JSON Data'),
              subtitle: const Text('Raw data for API integration'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Exporting JSON data...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
