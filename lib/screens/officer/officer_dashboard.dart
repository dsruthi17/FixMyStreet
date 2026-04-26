import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../config/routes.dart';
import '../../core/models/complaint_model.dart';
import '../../core/models/user_model.dart';
import 'widgets/officer_complaint_card.dart';
import 'widgets/officer_empty_state.dart';
import 'widgets/assign_worker_sheet.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _categoryFilter;
  String? _priorityFilter;
  String _sortBy = 'recent'; // recent, priority, category

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadComplaints();
  }

  void _loadComplaints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false)
          .streamAllComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildStatsDrawer(),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (_categoryFilter != null || _priorityFilter != null)
                _buildActiveFiltersBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildComplaintList(provider, 'pending', showAssignButton: true),
                    _buildComplaintList(provider, 'assigned', showAssignButton: false),
                    _buildComplaintList(provider, 'resolved', showAssignButton: false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: const Icon(Icons.analytics_rounded),
        label: const Text('Stats'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.badge_rounded, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Officer Control',
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
            onPressed: _handleLogout,
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
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions_rounded, size: 20),
                text: 'New',
                height: 60,
              ),
              Tab(
                icon: Icon(Icons.assignment_ind_rounded, size: 20),
                text: 'Assigned',
                height: 60,
              ),
              Tab(
                icon: Icon(Icons.check_circle_outline_rounded, size: 20),
                text: 'Resolved',
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmColor: AppColors.error,
    );
    if (confirm && mounted) {
      await Provider.of<AppAuthProvider>(context, listen: false).signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.landing);
      }
    }
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Active Filters:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          if (_categoryFilter != null)
            Chip(
              label: Text(_categoryFilter!),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _categoryFilter = null),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              visualDensity: VisualDensity.compact,
            ),
          if (_categoryFilter != null && _priorityFilter != null)
            const SizedBox(width: 8),
          if (_priorityFilter != null)
            Chip(
              label: Text(_priorityFilter!.toUpperCase()),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => _priorityFilter = null),
              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() {
              _categoryFilter = null;
              _priorityFilter = null;
            }),
            icon: const Icon(Icons.clear_all_rounded, size: 16),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDrawer() {
    return Drawer(
      child: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          return _buildStatsOverviewContent(provider);
        },
      ),
    );
  }

  Widget _buildStatsOverviewContent(ComplaintProvider provider) {
    final pendingCount = provider.getByStatus('pending').length;
    final assignedCount = provider.complaints
        .where((c) => c.status == 'assigned' || c.status == 'in_progress')
        .length;
    final resolvedCount = provider.getByStatus('resolved').length;
    final totalCount = provider.complaints.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dashboard Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time overview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.fiber_new_rounded,
                        label: 'New',
                        count: pendingCount,
                        color: AppColors.info,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withValues(alpha: 0.1),
                            AppColors.info.withValues(alpha: 0.05),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.assignment_ind_rounded,
                        label: 'Active',
                        count: assignedCount,
                        color: AppColors.warning,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withValues(alpha: 0.1),
                            AppColors.warning.withValues(alpha: 0.05),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(1);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_rounded,
                        label: 'Resolved',
                        count: resolvedCount,
                        color: AppColors.success,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.success.withValues(alpha: 0.1),
                            AppColors.success.withValues(alpha: 0.05),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.analytics_outlined,
                        label: 'Total',
                        count: totalCount,
                        color: AppColors.primary,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.primary.withValues(alpha: 0.05),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionChip(
                icon: Icons.filter_list_rounded,
                label: 'Filter',
                onTap: _showFilterDialog,
              ),
              _buildActionChip(
                icon: Icons.sort_rounded,
                label: 'Sort',
                onTap: _showSortDialog,
              ),
              _buildActionChip(
                icon: Icons.download_rounded,
                label: 'Export',
                onTap: _showExportDialog,
              ),
              _buildActionChip(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onTap: () {
                  Provider.of<ComplaintProvider>(context, listen: false)
                      .streamAllComplaints();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Refreshed successfully'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
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

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.filter_list_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Filter Complaints'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('Roads', _categoryFilter == 'Roads'),
                  _buildFilterChip('Streetlights', _categoryFilter == 'Streetlights'),
                  _buildFilterChip('Water Supply', _categoryFilter == 'Water Supply'),
                  _buildFilterChip('Sewage', _categoryFilter == 'Sewage'),
                  _buildFilterChip('Garbage', _categoryFilter == 'Garbage'),
                  _buildFilterChip('Other', _categoryFilter == 'Other'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Urgent', _priorityFilter == 'urgent', color: AppColors.error),
                  _buildFilterChip('High', _priorityFilter == 'high', color: AppColors.warning),
                  _buildFilterChip('Normal', _priorityFilter == 'normal', color: AppColors.info),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _categoryFilter = null;
                _priorityFilter = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {Color? color}) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'Urgent' || label == 'High' || label == 'Normal') {
            _priorityFilter = selected ? label.toLowerCase() : null;
          } else {
            _categoryFilter = selected ? label : null;
          }
        });
      },
      selectedColor: (color ?? AppColors.primary).withValues(alpha: 0.2),
      checkmarkColor: color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.primary) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sort_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Sort By'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Most Recent'),
              subtitle: const Text('Newest complaints first'),
              value: 'recent',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Priority'),
              subtitle: const Text('Urgent complaints first'),
              value: 'priority',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Category'),
              subtitle: const Text('Grouped by type'),
              value: 'category',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() => _sortBy = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Export Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose export format:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppColors.success),
              title: const Text('Excel (.xlsx)'),
              subtitle: const Text('Spreadsheet format'),
              onTap: () {
                Navigator.pop(context);
                _handleExport('excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
              title: const Text('PDF Document'),
              subtitle: const Text('Formatted report'),
              onTap: () {
                Navigator.pop(context);
                _handleExport('pdf');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded, color: AppColors.info),
              title: const Text('JSON'),
              subtitle: const Text('Raw data format'),
              onTap: () {
                Navigator.pop(context);
                _handleExport('json');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleExport(String format) {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Exporting as ${format.toUpperCase()}...')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildComplaintList(
    ComplaintProvider provider,
    String status, {
    required bool showAssignButton,
  }) {
    final items = _getFilteredComplaints(provider, status);

    if (provider.isLoading && items.isEmpty) {
      return OfficerEmptyState(
        message: 'Loading complaints...',
        icon: Icons.hourglass_empty_rounded,
        isLoading: true,
      );
    }

    if (items.isEmpty) {
      return OfficerEmptyState(
        message: _getEmptyMessage(status),
        icon: _getEmptyIcon(status),
        subtitle: _getEmptySubtitle(status),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        provider.streamAllComplaints();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final complaint = items[index];
          return OfficerComplaintCard(
            complaint: complaint,
            showAssignButton: showAssignButton,
            onAssign: showAssignButton ? () => _showAssignDialog(complaint) : null,
            onTap: () => _showComplaintDetails(complaint),
          );
        },
      ),
    );
  }

  List<Complaint> _getFilteredComplaints(
    ComplaintProvider provider,
    String status,
  ) {
    List<Complaint> items;
    
    if (status == 'assigned') {
      items = provider.complaints
          .where((c) => c.status == 'assigned' || c.status == 'in_progress')
          .toList();
    } else {
      items = provider.getByStatus(status);
    }

    // Apply category filter
    if (_categoryFilter != null) {
      items = items.where((c) => c.categoryDisplay == _categoryFilter).toList();
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      items = items.where((c) => c.priority == _priorityFilter).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'recent':
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'priority':
        final priorityOrder = {'urgent': 0, 'high': 1, 'normal': 2};
        items.sort((a, b) {
          final aPriority = priorityOrder[a.priority] ?? 3;
          final bPriority = priorityOrder[b.priority] ?? 3;
          return aPriority.compareTo(bPriority);
        });
        break;
      case 'category':
        items.sort((a, b) => a.categoryDisplay.compareTo(b.categoryDisplay));
        break;
    }

    return items;
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'No New Complaints';
      case 'assigned':
        return 'No Assigned Tasks';
      case 'resolved':
        return 'No Resolved Complaints';
      default:
        return 'No Complaints';
    }
  }

  String _getEmptySubtitle(String status) {
    switch (status) {
      case 'pending':
        return 'New complaints will appear here';
      case 'assigned':
        return 'Assigned tasks will appear here';
      case 'resolved':
        return 'Resolved complaints will appear here';
      default:
        return '';
    }
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.inbox_rounded;
      case 'assigned':
        return Icons.assignment_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.inbox_rounded;
    }
  }

  void _showComplaintDetails(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header with priority and status
                    Row(
                      children: [
                        _buildDetailPriorityBadge(complaint.priority),
                        const SizedBox(width: 8),
                        _buildDetailStatusBadge(complaint.status),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category
                    Row(
                      children: [
                        Icon(Icons.category_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          complaint.categoryDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description
                    _buildDetailSection(
                      icon: Icons.description_rounded,
                      title: 'Description',
                      content: complaint.description,
                    ),
                    const SizedBox(height: 20),
                    // Location
                    _buildDetailSection(
                      icon: Icons.location_on_rounded,
                      title: 'Location',
                      content: complaint.address,
                    ),
                    const SizedBox(height: 20),
                    // Citizen Info
                    _buildDetailSection(
                      icon: Icons.person_rounded,
                      title: 'Reported By',
                      content: complaint.isAnonymous
                          ? 'Anonymous Citizen'
                          : '${complaint.userName}\n${complaint.userPhone}',
                    ),
                    const SizedBox(height: 20),
                    // Date
                    _buildDetailSection(
                      icon: Icons.calendar_today_rounded,
                      title: 'Reported On',
                      content: Helpers.formatTimeAgo(complaint.createdAt),
                    ),
                    if (complaint.assignedWorkerName.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection(
                        icon: Icons.engineering_rounded,
                        title: 'Assigned Worker',
                        content: complaint.assignedWorkerName,
                        contentColor: AppColors.success,
                      ),
                    ],
                    if (complaint.mediaUrls.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Attachments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: complaint.mediaUrls.length,
                          itemBuilder: (context, index) {
                            final media = complaint.mediaUrls[index];
                            final url = media['url'] ?? '';
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade200,
                                image: url.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(url),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: url.isEmpty
                                  ? const Icon(Icons.image_rounded, size: 40, color: Colors.grey)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action button for pending complaints
                    if (complaint.status == 'pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAssignDialog(complaint);
                          },
                          icon: const Icon(Icons.person_add_rounded, size: 20),
                          label: const Text(
                            'Assign to Worker',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPriorityBadge(String priority) {
    Color color;
    IconData icon;
    switch (priority) {
      case 'urgent':
        color = AppColors.error;
        icon = Icons.warning_rounded;
        break;
      case 'high':
        color = Colors.orange;
        icon = Icons.flag_rounded;
        break;
      default:
        color = AppColors.info;
        icon = Icons.flag_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            priority.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'NEW';
        icon = Icons.pending_actions_rounded;
        break;
      case 'assigned':
      case 'in_progress':
        color = AppColors.info;
        label = 'ACTIVE';
        icon = Icons.work_outline_rounded;
        break;
      case 'resolved':
        color = AppColors.success;
        label = 'RESOLVED';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: contentColor ?? AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(Complaint complaint) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final workers = await authProvider.getWorkers();

    if (!mounted) return;

    if (workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('No workers available. Create worker accounts first.'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AssignWorkerSheet(
        complaint: complaint,
        workers: workers,
        onAssign: (worker) => _handleAssign(complaint, worker),
      ),
    );
  }

  void _handleAssign(Complaint complaint, AppUser worker) {
    final provider = Provider.of<ComplaintProvider>(context, listen: false);
    final officerId =
        Provider.of<AppAuthProvider>(context, listen: false).currentUser?.uid ??
            '';

    final workerName = worker.displayName.isNotEmpty
        ? worker.displayName
        : worker.phoneNumber;

    provider.assignToWorker(
      complaintId: complaint.id,
      workerId: worker.uid,
      workerName: workerName,
      officerId: officerId,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Assigned to $workerName')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
