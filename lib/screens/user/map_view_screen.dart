import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_config.dart';
import '../../core/services/location_service.dart';
import '../../providers/complaint_provider.dart';
import '../../core/models/complaint_model.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  String _activeFilter = 'all';

  List<Marker> _buildMarkers(List<Complaint> complaints) {
    final filtered = _activeFilter == 'all'
        ? complaints
        : complaints.where((c) => c.status == _activeFilter).toList();

    return filtered.where((c) => c.latitude != 0 && c.longitude != 0).map((c) {
      final color = _getMarkerColor(c.status);
      return Marker(
        point: LatLng(c.latitude, c.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showComplaintBottomSheet(c),
          child: Icon(
            Icons.location_on,
            size: 40,
            color: color,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 3),
            ],
          ),
        ),
      );
    }).toList();
  }

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
      case 'assigned':
        return AppColors.info;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }

  void _showComplaintBottomSheet(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getCategoryColor(complaint.category)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    complaint.categoryDisplay,
                    style: TextStyle(
                      color: AppColors.getCategoryColor(complaint.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getStatusColor(complaint.status)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatStatus(complaint.status),
                    style: TextStyle(
                      color: AppColors.getStatusColor(complaint.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              complaint.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    complaint.address.isNotEmpty
                        ? complaint.address
                        : '${complaint.latitude.toStringAsFixed(4)}, ${complaint.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        16.0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get location')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.complaintsMap),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    AppConfig.defaultLatitude,
                    AppConfig.defaultLongitude,
                  ),
                  initialZoom: AppConfig.defaultZoom,
                  minZoom: 5,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fixmystreet',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(provider.complaints),
                  ),
                ],
              ),

              // Legend
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Pending', AppColors.warning),
                      _buildLegendItem('In Progress', AppColors.info),
                      _buildLegendItem('Resolved', AppColors.success),
                    ],
                  ),
                ),
              ),

              // My location FAB
              Positioned(
                bottom: 90,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'my_location',
                  onPressed: _goToCurrentLocation,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.my_location, size: 20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppStrings.filterComplaints,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ...[
              {
                'value': 'all',
                'label': 'All Complaints',
                'icon': Icons.all_inclusive
              },
              {'value': 'pending', 'label': 'Pending', 'icon': Icons.schedule},
              {
                'value': 'in_progress',
                'label': 'In Progress',
                'icon': Icons.engineering
              },
              {
                'value': 'resolved',
                'label': 'Resolved',
                'icon': Icons.check_circle
              },
            ].map((item) => ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: _activeFilter == item['value']
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                  title: Text(item['label'] as String),
                  trailing: _activeFilter == item['value']
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _activeFilter = item['value'] as String);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String s) {
    switch (s) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'assigned':
        return 'Assigned';
      case 'resolved':
        return 'Resolved';
      default:
        return s;
    }
  }
}
