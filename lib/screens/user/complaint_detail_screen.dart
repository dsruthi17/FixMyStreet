import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/complaint_model.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/gradient_button.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/auth_provider.dart';
import '../common/feedback_screen.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  bool _isSaved = false;
  bool _hasUpvoted = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);
    final complaintProvider =
        Provider.of<ComplaintProvider>(context, listen: false);
    final currentUserId = auth.currentUser?.uid ?? '';

    return StreamBuilder<Complaint>(
      stream: complaintProvider.getComplaintStream(widget.complaint.id),
      initialData: widget.complaint,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
              backgroundColor: AppColors.primary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load complaint details',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final complaint = snapshot.data ?? widget.complaint;

        // ID-based ownership check (works for ALL complaints: anonymous, normal, old, new)
        final currentUserComplaintIds = auth.currentUser?.myComplaintIds ?? [];
        final isOwner = currentUserComplaintIds.contains(complaint.id);

        // Allow delete for: 1) Owner of the complaint, OR 2) Admin (can delete any complaint)
        final isAdmin = auth.currentUser?.isAdmin ?? false;
        final canDelete = isOwner || isAdmin;

        debugPrint('═══════════════════════════════════════════════════');
        debugPrint('COMPLAINT OWNERSHIP DEBUG (ID-BASED)');
        debugPrint('Current User ID: "$currentUserId"');
        debugPrint('User Role: ${auth.currentUser?.role}');
        debugPrint('Is Admin: $isAdmin');
        debugPrint(
            'User Complaint IDs: ${currentUserComplaintIds.length} complaints');
        debugPrint('Complaint ID: ${complaint.id}');
        debugPrint(
            'ID in User List: ${currentUserComplaintIds.contains(complaint.id)}');
        debugPrint('Is Anonymous: ${complaint.isAnonymous}');
        debugPrint('Is Owner: $isOwner');
        debugPrint('Can Delete: $canDelete');
        debugPrint('Complaint Status: ${complaint.status}');
        debugPrint('═══════════════════════════════════════════════════');
        debugPrint(
            '🖼️ IMAGE DEBUG: Media URLs Count: ${complaint.mediaUrls.length}');
        if (complaint.mediaUrls.isNotEmpty) {
          debugPrint('🖼️ First media: ${complaint.mediaUrls.first}');
          debugPrint(
              '🖼️ First media URL: ${complaint.mediaUrls.first['url']}');
          debugPrint(
              '🖼️ First media type: ${complaint.mediaUrls.first['type']}');
        } else {
          debugPrint('🖼️ No media URLs found in complaint');
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(isOwner
                ? 'My Complaint'
                : (isAdmin
                    ? 'Complaint Details (Admin)'
                    : 'Complaint Details')),
            backgroundColor: AppColors.primary,
            elevation: 0,
            actions: [
              if (canDelete)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    tooltip: 'Delete Complaint',
                    onPressed: () => _showDeleteDialog(context, complaint,
                        complaintProvider, isAdmin, isOwner),
                  ),
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              // Image Header with Overlay
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Main Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: complaint.mediaUrls.isNotEmpty &&
                              complaint.mediaUrls.first['url'] != null &&
                              complaint.mediaUrls.first['url']
                                  .toString()
                                  .isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:
                                  complaint.mediaUrls.first['url'].toString(),
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Loading image...',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                debugPrint('🖼️ IMAGE ERROR: $url');
                                debugPrint('🖼️ ERROR DETAILS: $error');
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image_outlined,
                                          size: 80, color: Colors.white54),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Text(
                                          error.toString(),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                              ),
                              child: const Icon(Icons.report_problem_outlined,
                                  size: 80, color: Colors.white54),
                            ),
                    ),
                    // Gradient Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      // Delete Info Banner (Only for owners on deletable complaints)
                      if (canDelete)
                        //   Container(
                        //     margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        //     padding: const EdgeInsets.all(16),
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(
                        //         colors: [
                        //           AppColors.error.withOpacity(0.1),
                        //           AppColors.warning.withOpacity(0.1),
                        //         ],
                        //       ),
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(
                        //         color: AppColors.error.withOpacity(0.3),
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.info_outline, color: AppColors.error, size: 24),
                        //         const SizedBox(width: 12),
                        //         Expanded(
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Text(
                        //                 'You can delete this complaint',
                        //                 style: TextStyle(
                        //                   fontWeight: FontWeight.w700,
                        //                   color: AppColors.error,
                        //                   fontSize: 13,
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 4),
                        //               Text(
                        //                 'Use the delete button in the top-right corner',
                        //                 style: TextStyle(
                        //                   fontSize: 12,
                        //                   color: AppColors.textSecondary,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // // Main Info Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status & Category
                              Row(
                                children: [
                                  StatusBadge(status: complaint.status),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.getCategoryColor(
                                              complaint.category)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.getCategoryColor(
                                                complaint.category)
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Helpers.getCategoryIcon(
                                              complaint.category),
                                          size: 16,
                                          color: AppColors.getCategoryColor(
                                              complaint.category),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          complaint.categoryDisplay,
                                          style: TextStyle(
                                            color: AppColors.getCategoryColor(
                                                complaint.category),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  if (complaint.isAnonymous)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility_off,
                                              size: 13,
                                              color: AppColors.textTertiary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Anonymous',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textTertiary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
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
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Time & User
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          Helpers.formatDateTime(
                                              complaint.createdAt),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                            complaint.isAnonymous && !isOwner
                                                ? Icons.visibility_off
                                                : Icons.person_outline,
                                            size: 14,
                                            color: AppColors.accent),
                                        const SizedBox(width: 4),
                                        Text(
                                          complaint.isAnonymous && !isOwner
                                              ? 'Anonymous User'
                                              : complaint.userName,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Description
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.description_outlined,
                                            size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      complaint.description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Location Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.location_on,
                                  color: AppColors.error, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textTertiary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    complaint.address.isNotEmpty
                                        ? complaint.address
                                        : 'Location captured',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (complaint.landmark.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Near: ${complaint.landmark}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Media Gallery
                      if (complaint.mediaUrls.isNotEmpty) ...[
                        // "Click to see full view" header
                        Center(
                          child: Text(
                            'Click to see full view',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Gallery thumbnails
                        Container(
                          height: 105,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Builder(
                            builder: (context) {
                              // Separate images and videos
                              final images = complaint.mediaUrls
                                  .where((m) => m['type'] != 'video')
                                  .toList();
                              final videos = complaint.mediaUrls
                                  .where((m) => m['type'] == 'video')
                                  .toList();

                              // Create display list: images first, then one video card
                              final displayItems = <Map<String, dynamic>>[];
                              displayItems.addAll(images);
                              if (videos.isNotEmpty) {
                                displayItems.add({
                                  'type': 'video_group',
                                  'url': videos.first['url'],
                                  'count': videos.length,
                                });
                              }

                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: displayItems.length,
                                itemBuilder: (context, index) {
                                  final item = displayItems[index];
                                  final isFirstItem = index == 0;
                                  final isVideoGroup =
                                      item['type'] == 'video_group';
                                  final mediaUrl =
                                      (item['url'] ?? '').toString();

                                  if (mediaUrl.isEmpty && !isVideoGroup) {
                                    return _buildEmptyThumbnail();
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      if (isVideoGroup) {
                                        // Show first video when clicking video group
                                        _showMediaViewer(
                                            context,
                                            videos.first['url'].toString(),
                                            true);
                                      } else {
                                        _showMediaViewer(
                                            context, mediaUrl, false);
                                      }
                                    },
                                    child: Container(
                                      width: 105,
                                      height: 105,
                                      margin: EdgeInsets.only(
                                        right: index < displayItems.length - 1
                                            ? 8
                                            : 0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isFirstItem
                                              ? AppColors.primary
                                              : Colors.grey.shade300,
                                          width: isFirstItem ? 2.5 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: isVideoGroup
                                            ? _buildVideoGroupThumbnail(
                                                item['count'] as int)
                                            : _buildImageThumbnail(mediaUrl),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Status Timeline
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timeline,
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Status Timeline',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...complaint.statusHistory.map((entry) {
                              return _buildTimelineItem(
                                status: entry['status'] ?? '',
                                comment: entry['comment'] ?? '',
                                date: entry['changedAt'] ?? '',
                                isLast: entry == complaint.statusHistory.last,
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              icon: _hasUpvoted
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_alt_outlined,
                              label: '${complaint.upvotes}\nUpvotes',
                              color: _hasUpvoted
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              onTap: () => _handleUpvote(complaint.id),
                            ),
                            _buildActionButton(
                              icon: Icons.share_outlined,
                              label: 'Share',
                              color: AppColors.accent,
                              onTap: () => _handleShare(complaint),
                            ),
                            _buildActionButton(
                              icon: _isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              label: _isSaved ? 'Saved' : 'Save',
                              color: _isSaved
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              onTap: () => _handleSave(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Feedback button (only if resolved)
                      if (complaint.status == 'resolved')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GradientButton(
                            text: 'Rate Resolution',
                            gradient: AppColors.successGradient,
                            icon: Icons.star_rounded,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FeedbackScreen(complaintId: complaint.id),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Complaint complaint,
    ComplaintProvider provider,
    bool isAdmin,
    bool isOwner,
  ) async {
    // Show status-specific message
    String message;
    String title = 'Delete Complaint?';

    if (isAdmin && !isOwner) {
      // Admin deleting someone else's complaint
      title = 'Delete Complaint? (Admin Action)';
      if (complaint.status == 'in_progress' || complaint.status == 'assigned') {
        message =
            'As an admin, you are about to delete a complaint that is currently ${complaint.status}. This will cancel ongoing work. Continue?';
      } else {
        message =
            'As an admin, you are about to delete this complaint. This action cannot be undone and will permanently remove the complaint from the system.';
      }
    } else if (complaint.status == 'resolved') {
      message =
          'This complaint has been resolved. Deleting it will remove it from your history. Are you sure?';
    } else if (complaint.status == 'rejected') {
      message =
          'This complaint was rejected. Are you sure you want to delete it from your history?';
    } else if (complaint.status == 'in_progress' ||
        complaint.status == 'assigned') {
      message =
          'This complaint is currently ${complaint.status}. Deleting it will cancel the ongoing work. Are you sure?';
    } else {
      message =
          'Are you sure you want to delete this complaint? This action cannot be undone.';
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting complaint...'),
              ],
            ),
          ),
        ),
      );

      final auth = Provider.of<AppAuthProvider>(context, listen: false);
      final success = await provider.deleteComplaint(
        complaint.id,
        auth.currentUser?.uid ?? '',
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Complaint deleted successfully'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context); // Go back to previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(provider.error ?? 'Failed to delete complaint'),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleUpvote(String complaintId) async {
    if (_hasUpvoted) {
      // Haptic feedback for already voted
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('You have already upvoted this complaint'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<ComplaintProvider>(context, listen: false);
      await provider.upvoteComplaint(complaintId);

      // Haptic feedback for successful upvote
      HapticFeedback.mediumImpact();

      setState(() {
        _hasUpvoted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.thumb_up, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Upvoted successfully! Thank you for your support.')),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Failed to upvote: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleShare(Complaint complaint) async {
    try {
      final String shareText = '''
🚨 URGENT: Community Issue Report

📌 ${complaint.title}

📋 Description:
${complaint.description}

📍 Location: ${complaint.address}
${complaint.landmark.isNotEmpty ? '🏷️ Near: ${complaint.landmark}' : ''}

🏷️ Category: ${complaint.categoryDisplay}
📊 Status: ${complaint.status.toUpperCase()}
👍 Community Support: ${complaint.upvotes} upvotes

⏰ Reported: ${Helpers.formatDateTime(complaint.createdAt)}

🔗 Help us fix our community! Download FixMyStreet App to report and track issues in real-time.

#FixMyStreet #CommunityAction #${complaint.category}
      ''';

      // Haptic feedback
      HapticFeedback.selectionClick();

      await Share.share(
        shareText,
        subject: 'FixMyStreet: ${complaint.title}',
      );

      // Show confirmation if shared successfully
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Shared successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Failed to share: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(_isSaved ? 'Saved to bookmarks' : 'Removed from bookmarks'),
          ],
        ),
        backgroundColor: _isSaved ? AppColors.success : AppColors.textSecondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showMediaViewer(BuildContext context, String mediaUrl, bool isVideo) {
    if (isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _VideoPlayerScreen(videoUrl: mediaUrl),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.5,
                  maxScale: 4,
                  child: CachedNetworkImage(
                    imageUrl: mediaUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String status,
    required String comment,
    required dynamic date,
    bool isLast = false,
  }) {
    final color = AppColors.getStatusColor(status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.5),
                          color.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatStatus(status),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 14,
                    ),
                  ),
                  if (comment.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        comment,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    // Check if this is a base64 data URL (stored in Firestore)
    if (imageUrl.startsWith('data:')) {
      try {
        // Extract base64 data from data URL
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ Base64 image error: $error');
            return Container(
              color: Colors.grey.shade100,
              child: Icon(Icons.broken_image, color: Colors.grey.shade400),
            );
          },
        );
      } catch (e) {
        debugPrint('🖼️ Failed to decode base64: $e');
        return Container(
          color: Colors.grey.shade100,
          child: Icon(Icons.broken_image, color: Colors.grey.shade400),
        );
      }
    }

    // Otherwise, use CachedNetworkImage for Storage URLs
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.grey.shade100,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        debugPrint('🖼️ Thumbnail error: $url');
        return Container(
          color: Colors.grey.shade100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey.shade400, size: 28),
              const SizedBox(height: 4),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoGroupThumbnail(int videoCount) {
    return Container(
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          // Play icon background
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: 38,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          // Video count badge
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$videoCount VIDEO${videoCount > 1 ? "S" : ""}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyThumbnail() {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported,
              color: Colors.grey.shade400, size: 32),
          const SizedBox(height: 4),
          Text(
            'No media',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Complaint Submitted';
      case 'assigned':
        return 'Assigned to Worker';
      case 'in_progress':
        return 'Work In Progress';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

// Video Player Screen Widget
class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Video', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _isInitialized = false;
                      });
                      _initializeVideo();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : !_isInitialized
                ? const CircularProgressIndicator(color: Colors.white)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      // Play/Pause Overlay
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          height: double.infinity,
                          child: _controller.value.isPlaying
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.play_circle_outline,
                                  size: 80,
                                  color: Colors.white70,
                                ),
                        ),
                      ),
                      // Video Controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: AppColors.primary,
                                  bufferedColor: Colors.white30,
                                  backgroundColor: Colors.white10,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_controller.value.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.position),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Text(
                                    ' / ',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      _controller.value.volume > 0
                                          ? Icons.volume_up
                                          : Icons.volume_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _controller.setVolume(
                                          _controller.value.volume > 0 ? 0 : 1,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
