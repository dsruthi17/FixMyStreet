import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../core/utils/app_localizations.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../config/routes.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/category_chip.dart';
import '../user/submit_complaint_screen.dart';
import '../user/map_view_screen.dart';
import '../user/profile_screen.dart';
import '../user/complaint_detail_screen.dart';
import '../user/bulletin_board_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _sortBy = 'newest'; // newest, oldest, mostUpvoted
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // Start streaming complaints
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ComplaintProvider>(context, listen: false);
      provider.streamAllComplaints();
      provider.loadStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screens = [
      _buildFeedScreen(localizations),
      const MapViewScreen(),
      const SubmitComplaintScreen(),
      const BulletinBoardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.dashboard_rounded, color: AppColors.primary),
                ),
                label: localizations.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.map_rounded, color: AppColors.primary),
                ),
                label: localizations.translate('map'),
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                label: localizations.translate('report'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.forum_outlined),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.forum_rounded, color: AppColors.primary),
                ),
                label: 'Bulletin',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                label: localizations.translate('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedScreen(AppLocalizations localizations) {
    final auth = Provider.of<AppAuthProvider>(context);
    final userName =
        auth.currentUser?.displayName ?? localizations.translate('user');

    return Consumer<ComplaintProvider>(
      builder: (context, provider, _) {
        // Apply search, status filter, date filter, and sorting
        var complaints = provider.filteredComplaints;

        // Search filter
        if (_searchQuery.isNotEmpty) {
          complaints = complaints
              .where((c) =>
                  c.title.toLowerCase().contains(_searchQuery) ||
                  c.description.toLowerCase().contains(_searchQuery) ||
                  c.address.toLowerCase().contains(_searchQuery))
              .toList();
        }

        // Status filter
        if (_selectedStatus != 'all') {
          complaints =
              complaints.where((c) => c.status == _selectedStatus).toList();
        }

        // Date range filter
        if (_startDate != null) {
          complaints = complaints
              .where((c) =>
                  c.createdAt.isAfter(_startDate!) ||
                  c.createdAt.isAtSameMomentAs(_startDate!))
              .toList();
        }
        if (_endDate != null) {
          final endOfDay = DateTime(
              _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          complaints = complaints
              .where((c) =>
                  c.createdAt.isBefore(endOfDay) ||
                  c.createdAt.isAtSameMomentAs(endOfDay))
              .toList();
        }

        // Sorting
        if (_sortBy == 'newest') {
          complaints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else if (_sortBy == 'oldest') {
          complaints.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else if (_sortBy == 'mostUpvoted') {
          complaints.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        }

        // Calculate stats from user's own complaints (same as profile screen)
        final myComplaints = provider.myComplaints;
        final pending = myComplaints.where((c) => c.status == 'pending').length;
        final inProgress = myComplaints
            .where((c) =>
                c.status == 'in_progress' ||
                c.status == 'in progress' ||
                c.status == 'assigned' ||
                c.status == 'pending')
            .length;
        final resolved =
            myComplaints.where((c) => c.status == 'resolved').length;

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $userName! 👋',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.translate('appTagline'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildAppBarIcon(
                                      Icons.notifications_outlined, () {}),
                                  const SizedBox(width: 8),
                                  _buildAppBarIcon(Icons.history, () {
                                    Navigator.pushNamed(
                                        context, AppRoutes.myComplaints);
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by title, description...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppColors.textTertiary),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear,
                              color: AppColors.textTertiary, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showFilterDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (_selectedStatus != 'all' ||
                                    _startDate != null ||
                                    _endDate != null ||
                                    _sortBy != 'newest')
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: (_selectedStatus != 'all' ||
                                    _startDate != null ||
                                    _endDate != null ||
                                    _sortBy != 'newest')
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    _buildMiniStat('$pending',
                        localizations.translate('pending'), AppColors.warning),
                    const SizedBox(width: 10),
                    _buildMiniStat('$inProgress',
                        localizations.translate('inProgress'), AppColors.info),
                    const SizedBox(width: 10),
                    _buildMiniStat('$resolved',
                        localizations.translate('resolved'), AppColors.success),
                  ],
                ),
              ),
            ),

            // Category filter
            SliverToBoxAdapter(
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        icon: Icons.all_inclusive,
                        label: localizations.translate('all'),
                        color: AppColors.primary,
                        isSelected: _selectedCategory == 'all',
                        onSelected: (_) {
                          setState(() => _selectedCategory = 'all');
                          provider.setFilterCategory('all');
                        },
                      ),
                    ),
                    ...AppConfig.categories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            icon: cat['icon'] as IconData,
                            label: cat['name'] as String,
                            color: Color(cat['color'] as int),
                            isSelected: _selectedCategory == cat['id'],
                            onSelected: (_) {
                              setState(() =>
                                  _selectedCategory = cat['id'] as String);
                              provider.setFilterCategory(cat['id'] as String);
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Complaints (${complaints.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(localizations.translate('viewAll'),
                          style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),

            // Complaints list
            if (complaints.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          provider.isLoading
                              ? localizations.translate('loading')
                              : 'No complaints yet',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 16),
                        ),
                        if (!provider.isLoading) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to report an issue',
                            style: TextStyle(
                                color: AppColors.textTertiary, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final complaint = complaints[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ComplaintCard(
                          title: complaint.title,
                          category: complaint.category,
                          status: complaint.status,
                          location: complaint.address,
                          timeAgo: Helpers.formatTimeAgo(complaint.createdAt),
                          upvotes: complaint.upvotes,
                          mediaUrls: complaint.mediaUrls,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ComplaintDetailScreen(complaint: complaint),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: complaints.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        );
      },
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final localizations = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = 'all';
                      _startDate = null;
                      _endDate = null;
                      _sortBy = 'newest';
                    });
                    Navigator.pop(context);
                  },
                  child: Text(localizations.translate('reset'),
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Filter
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                    localizations.translate('all'), 'all', _selectedStatus),
                _buildFilterChip(localizations.translate('pending'), 'pending',
                    _selectedStatus),
                _buildFilterChip(localizations.translate('inProgress'),
                    'in_progress', _selectedStatus),
                _buildFilterChip(localizations.translate('resolved'),
                    'resolved', _selectedStatus),
                _buildFilterChip(localizations.translate('rejected'),
                    'rejected', _selectedStatus),
              ],
            ),
            const SizedBox(height: 20),

            // Date Range
            const Text(
              'Date Range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate == null
                          ? 'Start Date'
                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate == null
                          ? 'End Date'
                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sort By
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildSortChip('Newest First', 'newest', _sortBy),
                _buildSortChip('Oldest First', 'oldest', _sortBy),
                _buildSortChip('Most Upvoted', 'mostUpvoted', _sortBy),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentValue) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildSortChip(String label, String value, String currentValue) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.accent.withValues(alpha: 0.15),
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.accent : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}
