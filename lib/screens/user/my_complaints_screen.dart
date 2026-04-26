import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../core/models/complaint_model.dart';
import '../../core/utils/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/loading_overlay.dart';
import 'complaint_detail_screen.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load user's complaints
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AppAuthProvider>(context, listen: false);
      final complaints = Provider.of<ComplaintProvider>(context, listen: false);
      if (auth.currentUser != null) {
        complaints.streamMyComplaints(auth.currentUser!.myComplaintIds);
      }
    });
  }

  List<Complaint> _filterByStatus(List<Complaint> complaints, String status) {
    if (status == 'all') return complaints;
    // Include 'assigned' status as part of 'in_progress'
    if (status == 'in_progress') {
      return complaints
          .where((c) => c.status == 'in_progress' || c.status == 'assigned')
          .toList();
    }
    return complaints.where((c) => c.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final complaints = Provider.of<ComplaintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('myComplaints')),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.translate('all')),
            Tab(text: localizations.translate('pending')),
            Tab(text: localizations.translate('active')),
            Tab(text: localizations.translate('resolved')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(complaints.myComplaints, 'all'),
          _buildList(complaints.myComplaints, 'pending'),
          _buildList(complaints.myComplaints, 'in_progress'),
          _buildList(complaints.myComplaints, 'resolved'),
        ],
      ),
    );
  }

  Widget _buildList(List<Complaint> allComplaints, String status) {
    final items = _filterByStatus(allComplaints, status);

    debugPrint('MyComplaints - Status: $status, Total items: ${items.length}');

    if (items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'No complaints here',
        subtitle: status == 'all'
            ? 'Your complaints will appear here'
            : 'Your $status complaints will appear here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final auth = Provider.of<AppAuthProvider>(context, listen: false);
        final complaints =
            Provider.of<ComplaintProvider>(context, listen: false);
        if (auth.currentUser != null) {
          complaints.streamMyComplaints(auth.currentUser!.myComplaintIds);
        }
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final c = items[index];
          debugPrint('Complaint Card - ${c.id}: ${c.title} [${c.status}]');
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ComplaintCard(
              title: c.title,
              category: c.category,
              status: c.status,
              location: c.address,
              timeAgo: timeago.format(c.createdAt),
              mediaUrls: c.mediaUrls,
              onTap: () {
                debugPrint('Opening complaint detail for: ${c.id}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComplaintDetailScreen(complaint: c),
                  ),
                ).then((_) {
                  // Refresh list after returning from detail view
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
