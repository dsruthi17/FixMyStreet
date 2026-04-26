import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/helpers.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final String title;
  final String category;
  final String status;
  final String location;
  final String timeAgo;
  final String? imageUrl; // Deprecated: Use mediaUrls instead
  final List<Map<String, dynamic>>? mediaUrls; // New: Support multiple media
  final int upvotes;
  final bool showAdminControls;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChange;

  const ComplaintCard({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    required this.location,
    required this.timeAgo,
    this.imageUrl,
    this.mediaUrls,
    this.upvotes = 0,
    this.showAdminControls = false,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(category);

    // Get first media URL from mediaUrls or fall back to deprecated imageUrl
    String? firstMediaUrl;
    String? mediaType;

    if (mediaUrls != null && mediaUrls!.isNotEmpty) {
      final firstMedia = mediaUrls!.first;
      firstMediaUrl = firstMedia['url'] as String?;
      mediaType = firstMedia['type'] as String?;
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      firstMediaUrl = imageUrl;
      mediaType = 'image';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Video on the left (25% width)
            if (firstMediaUrl != null && firstMediaUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                    width: 100, // Fixed width for image
                    height: 140, // Fixed height
                    child: mediaType == 'video'
                        ? Container(
                            color: Colors.black,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  size: 40,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.videocam,
                                        size: 10, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : firstMediaUrl.startsWith('data:')
                            ? _buildBase64Image(firstMediaUrl, compact: true)
                            : CachedNetworkImage(
                                imageUrl: firstMediaUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image,
                                      size: 30, color: Colors.grey),
                                ),
                              )),
              ),

            // Content on the right (75% width)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Status row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Helpers.getCategoryIcon(category),
                                size: 14,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatCategory(category),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        StatusBadge(status: status, isSmall: true),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Location & Time
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),

                    // Admin controls
                    if (showAdminControls) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Change Status:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildStatusOption('pending', 'Pending'),
                                  const SizedBox(width: 6),
                                  _buildStatusOption(
                                      'in_progress', 'In Progress'),
                                  const SizedBox(width: 6),
                                  _buildStatusOption('resolved', 'Resolved'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Upvotes bar
                    if (upvotes > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined,
                              size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '$upvotes upvotes',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isActive = status == value;
    final color = AppColors.getStatusColor(value);

    return GestureDetector(
      onTap: () => onStatusChange?.call(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBase64Image(String dataUrl, {bool compact = false}) {
    try {
      final base64String = dataUrl.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        height: compact ? null : 160,
        width: compact ? null : double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: compact ? null : 160,
            color: Colors.grey.shade200,
            child: Icon(Icons.broken_image,
                size: compact ? 30 : 40, color: Colors.grey),
          );
        },
      );
    } catch (e) {
      return Container(
        height: compact ? null : 160,
        color: Colors.grey.shade200,
        child: Icon(Icons.broken_image,
            size: compact ? 30 : 40, color: Colors.grey),
      );
    }
  }

  String _formatCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'roads':
        return 'Roads';
      case 'water':
        return 'Water';
      case 'electricity':
        return 'Electricity';
      case 'sanitation':
        return 'Sanitation';
      case 'public_abuse':
        return 'Public Abuse';
      default:
        return cat;
    }
  }
}
