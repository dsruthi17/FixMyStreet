import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../providers/complaint_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.analytics_rounded, size: 22),
            SizedBox(width: 12),
            Text(
              'Analytics & Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _showExportDialog(),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          final total = provider.complaints.length;
          final pending = provider.countByStatus('pending');
          final inProgress = provider.countByStatus('in_progress');
          final resolved = provider.countByStatus('resolved');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                Row(
                  children: [
                    const Text(
                      'Time Period:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPeriodChip('7 Days', '7d'),
                            _buildPeriodChip('30 Days', '30d'),
                            _buildPeriodChip('90 Days', '90d'),
                            _buildPeriodChip('1 Year', '1y'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Key Metrics Grid
                const Text(
                  'Key Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.4,
                  children: [
                    _buildMetricCard(
                      'Total Reports',
                      total.toString(),
                      Icons.assignment_rounded,
                      AppColors.primary,
                      '+12% vs last period',
                      true,
                    ),
                    _buildMetricCard(
                      'Resolution Rate',
                      total > 0
                          ? '${((resolved / total) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      Icons.trending_up_rounded,
                      AppColors.success,
                      '+5.2% improvement',
                      true,
                    ),
                    _buildMetricCard(
                      'Avg. Response Time',
                      '2.4 hrs',
                      Icons.timer_rounded,
                      AppColors.info,
                      '-15% faster',
                      true,
                    ),
                    _buildMetricCard(
                      'Active Cases',
                      (pending + inProgress).toString(),
                      Icons.work_outline_rounded,
                      AppColors.warning,
                      'Needs attention',
                      false,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Status Distribution
                const Text(
                  'Status Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildStatusRow(
                          'Pending', pending, total, AppColors.warning),
                      const SizedBox(height: 16),
                      _buildStatusRow(
                          'In Progress', inProgress, total, AppColors.info),
                      const SizedBox(height: 16),
                      _buildStatusRow(
                          'Resolved', resolved, total, AppColors.success),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Category Performance
                const Text(
                  'Category Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: AppConfig.categories.map((cat) {
                      final count =
                          provider.countByCategory(cat['id'] as String);
                      final categoryResolved = provider.complaints
                          .where((c) =>
                              c.category == cat['id'] && c.status == 'resolved')
                          .length;
                      final resolutionRate = count > 0
                          ? ((categoryResolved / count) * 100)
                              .toStringAsFixed(0)
                          : '0';

                      return _buildCategoryPerformanceRow(
                        cat['name'] as String,
                        count,
                        resolutionRate,
                        Color(cat['color'] as int),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // Recent Trends
                const Text(
                  'Recent Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildTrendItem(
                        'Most Reported Category',
                        _getMostReportedCategory(provider),
                        Icons.trending_up_rounded,
                        AppColors.error,
                      ),
                      const Divider(height: 24),
                      _buildTrendItem(
                        'Best Resolution Time',
                        _getBestCategory(provider),
                        Icons.speed_rounded,
                        AppColors.success,
                      ),
                      const Divider(height: 24),
                      _buildTrendItem(
                        'Peak Reporting Hour',
                        '2 PM - 4 PM',
                        Icons.access_time_rounded,
                        AppColors.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isActive = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
    bool isPositive,
  ) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Icon(
                isPositive ? Icons.arrow_upward_rounded : Icons.remove_rounded,
                color: isPositive ? AppColors.success : AppColors.textTertiary,
                size: 18,
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            trend,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.success : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '$count (${(percentage * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPerformanceRow(
    String name,
    int count,
    String resolutionRate,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.category_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$count reports',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$resolutionRate% resolved',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMostReportedCategory(ComplaintProvider provider) {
    int maxCount = 0;
    String mostReported = 'N/A';
    for (var cat in AppConfig.categories) {
      final count = provider.countByCategory(cat['id'] as String);
      if (count > maxCount) {
        maxCount = count;
        mostReported = cat['name'] as String;
      }
    }
    return mostReported;
  }

  String _getBestCategory(ComplaintProvider provider) {
    double bestRate = 0;
    String bestCategory = 'N/A';
    for (var cat in AppConfig.categories) {
      final count = provider.countByCategory(cat['id'] as String);
      if (count > 0) {
        final resolved = provider.complaints
            .where((c) => c.category == cat['id'] && c.status == 'resolved')
            .length;
        final rate = resolved / count;
        if (rate > bestRate) {
          bestRate = rate;
          bestCategory = cat['name'] as String;
        }
      }
    }
    return bestCategory;
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Export Report'),
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
              onTap: () {
                Navigator.pop(context);
                _showMessage('Exporting to Excel...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('PDF Report'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Generating PDF...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_rounded),
              title: const Text('JSON Data'),
              onTap: () {
                Navigator.pop(context);
                _showMessage('Exporting JSON...');
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
