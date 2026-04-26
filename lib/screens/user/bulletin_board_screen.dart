import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/complaint_model.dart';
import '../../core/utils/helpers.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import 'complaint_detail_screen.dart';

class BulletinBoardScreen extends StatefulWidget {
  const BulletinBoardScreen({super.key});

  @override
  State<BulletinBoardScreen> createState() => _BulletinBoardScreenState();
}

class _BulletinBoardScreenState extends State<BulletinBoardScreen> {
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';
  String _sortBy = 'newest'; // newest, oldest, mostUpvoted, nearMe

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ComplaintProvider>(context, listen: false);
      provider.streamAllComplaints();
    });
  }

  List<Complaint> _applySortAndFilter(List<Complaint> complaints) {
    var filtered = complaints;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((c) => c.category == _selectedCategory).toList();
    }

    // Filter by status
    if (_selectedStatus != 'all') {
      filtered = filtered.where((c) => c.status == _selectedStatus).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'mostUpvoted':
        filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);
    final provider = Provider.of<ComplaintProvider>(context);
    final complaints = _applySortAndFilter(provider.complaints);

    // Check user role
    final isOfficerOrAdmin = auth.isOfficer || auth.isAdmin;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Community Bulletin'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter & Sort',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.streamAllComplaints();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            // Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.accent.withOpacity(0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.campaign,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Issues',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'View and support issues reported by your community',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${complaints.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Active Filters Display
            if (_selectedCategory != 'all' ||
                _selectedStatus != 'all' ||
                _sortBy != 'newest')
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.blue.withOpacity(0.1),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedCategory != 'all')
                      _buildActiveFilterChip(
                        'Category: ${_selectedCategory[0].toUpperCase()}${_selectedCategory.substring(1)}',
                        () => setState(() => _selectedCategory = 'all'),
                      ),
                    if (_selectedStatus != 'all')
                      _buildActiveFilterChip(
                        'Status: ${_selectedStatus}',
                        () => setState(() => _selectedStatus = 'all'),
                      ),
                    if (_sortBy != 'newest')
                      _buildActiveFilterChip(
                        'Sort: ${_sortBy}',
                        () => setState(() => _sortBy = 'newest'),
                      ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'all';
                          _selectedStatus = 'all';
                          _sortBy = 'newest';
                        });
                      },
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear All'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

            // Complaints List
            Expanded(
              child: complaints.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_outlined,
                              size: 80, color: AppColors.textTertiary),
                          const SizedBox(height: 16),
                          Text(
                            'No complaints found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = complaints[index];
                        return _buildBulletinComplaintCard(
                          complaint,
                          isOfficerOrAdmin,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletinComplaintCard(
      Complaint complaint, bool showFullDetails) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetailScreen(complaint: complaint),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.getCategoryColor(complaint.category)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Helpers.getCategoryIcon(complaint.category),
                      color: AppColors.getCategoryColor(complaint.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title & Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint.categoryDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.getCategoryColor(complaint.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.getStatusColor(complaint.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.getStatusColor(complaint.status)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      complaint.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getStatusColor(complaint.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                complaint.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      complaint.address.isNotEmpty
                          ? complaint.address
                          : 'Location captured',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  // Upvotes
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${complaint.upvotes}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time
                  Icon(Icons.access_time,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatDateTime(complaint.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  // User info (conditional)
                  if (showFullDetails || !complaint.isAnonymous)
                    Row(
                      children: [
                        Icon(
                          complaint.isAnonymous
                              ? Icons.visibility_off
                              : Icons.person_outline,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          complaint.isAnonymous
                              ? 'Anonymous'
                              : complaint.userName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.visibility_off,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Anonymous',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.filter_list, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Category Filter
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterOption('All', 'all', _selectedCategory, (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                    _buildFilterOption('Roads', 'roads', _selectedCategory,
                        (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                    _buildFilterOption('Water', 'water', _selectedCategory,
                        (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                    _buildFilterOption(
                        'Electricity', 'electricity', _selectedCategory, (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                    _buildFilterOption(
                        'Sanitation', 'sanitation', _selectedCategory, (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                    _buildFilterOption('Garbage', 'garbage', _selectedCategory,
                        (val) {
                      setModalState(() => _selectedCategory = val);
                      setState(() => _selectedCategory = val);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Filter
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterOption('All', 'all', _selectedStatus, (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() => _selectedStatus = val);
                    }),
                    _buildFilterOption('Pending', 'pending', _selectedStatus,
                        (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() => _selectedStatus = val);
                    }),
                    _buildFilterOption(
                        'In Progress', 'in_progress', _selectedStatus, (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() => _selectedStatus = val);
                    }),
                    _buildFilterOption('Resolved', 'resolved', _selectedStatus,
                        (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() => _selectedStatus = val);
                    }),
                    _buildFilterOption('Rejected', 'rejected', _selectedStatus,
                        (val) {
                      setModalState(() => _selectedStatus = val);
                      setState(() => _selectedStatus = val);
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Sort Options
                Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterOption('Newest First', 'newest', _sortBy,
                        (val) {
                      setModalState(() => _sortBy = val);
                      setState(() => _sortBy = val);
                    }),
                    _buildFilterOption('Oldest First', 'oldest', _sortBy,
                        (val) {
                      setModalState(() => _sortBy = val);
                      setState(() => _sortBy = val);
                    }),
                    _buildFilterOption('Most Upvoted', 'mostUpvoted', _sortBy,
                        (val) {
                      setModalState(() => _sortBy = val);
                      setState(() => _sortBy = val);
                    }),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    String value,
    String currentValue,
    Function(String) onTap,
  ) {
    final isSelected = currentValue == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(value),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.textTertiary.withOpacity(0.3),
      ),
    );
  }
}
