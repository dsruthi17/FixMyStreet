import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_config.dart';
import '../../core/services/location_service.dart';
import '../../core/utils/app_localizations.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/loading_overlay.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedCategory = 'roads';
  bool _isAnonymous = false;
  bool _isLoading = false;
  bool _isLocationLoading = true;
  bool _locationInitialized = false;
  double? _latitude;
  double? _longitude;
  String _address = '';
  String? _locationError;

  final List<XFile> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize location only once after widget tree is built
    if (!_locationInitialized) {
      _locationInitialized = true;
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
      _address = localizations.translate('fetchingLocation');
    });

    try {
      final locationService = LocationService();
      debugPrint('Attempting to get current location...');
      final position = await locationService.getCurrentLocation();
      debugPrint(
          'Location received: ${position.latitude}, ${position.longitude}');

      final address = await locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      debugPrint('Address received: $address');

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          // If address geocoding failed, show coordinates instead
          if (address.contains('Unable to fetch')) {
            _address =
                '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          } else {
            _address = address;
          }
          _isLocationLoading = false;
          _locationError = null;
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(localizations.translate('locationCoordinatesFetched')),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() {
          _address = 'Unable to get location';
          _isLocationLoading = false;
          _locationError = e.toString().replaceAll('Exception: ', '');
        });

        // Show error with action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_locationError ??
                localizations.translate('failedToGetLocation')),
            duration: const Duration(seconds: 5),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedMedia.add(image));
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      setState(() => _selectedMedia.add(video));
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  Icons.camera_alt_rounded,
                  'Camera',
                  AppColors.primary,
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildMediaOption(
                  Icons.photo_library_rounded,
                  'Gallery',
                  AppColors.success,
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildMediaOption(
                  Icons.videocam_rounded,
                  'Video',
                  AppColors.accent,
                  () {
                    Navigator.pop(context);
                    _pickVideo();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      Helpers.showSnackBar(
          context, 'Location not available. Please enable location and retry.',
          isError: true);
      return;
    }

    // Validate custom category if "Other" is selected
    if (_selectedCategory == 'other' &&
        _customCategoryController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Please specify the type of problem',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AppAuthProvider>(context, listen: false);
      final complaintProvider =
          Provider.of<ComplaintProvider>(context, listen: false);

      // Use custom category if "Other" is selected, otherwise use selected category
      final categoryToSubmit = _selectedCategory == 'other'
          ? _customCategoryController.text.trim()
          : _selectedCategory;

      final success = await complaintProvider.submitComplaint(
        userId: auth.currentUser?.uid ?? '',
        userName: auth.currentUser?.displayName ?? 'User',
        userPhone: auth.currentUser?.phoneNumber ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: categoryToSubmit,
        latitude: _latitude!,
        longitude: _longitude!,
        address: _address,
        landmark: _landmarkController.text.trim(),
        isAnonymous: _isAnonymous,
        mediaXFiles: _selectedMedia, // Use XFiles for web compatibility
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        Helpers.showSnackBar(context, 'Failed to submit complaint',
            isError: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                localizations.translate('complaintSubmitted'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.translate('complaintSubmittedMsg'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: localizations.translate('ok'),
                gradient: AppColors.successGradient,
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  _resetForm();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _landmarkController.clear();
    _customCategoryController.clear();
    setState(() {
      _selectedCategory = 'roads';
      _isAnonymous = false;
      _selectedMedia.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('reportIssue')),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Submitting complaint...',
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Category selection
              Text(
                localizations.translate('selectCategory'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConfig.categories.map((cat) {
                  return CategoryChip(
                    icon: cat['icon'] as IconData,
                    label: cat['name'] as String,
                    color: Color(cat['color'] as int),
                    isSelected: _selectedCategory == cat['id'],
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat['id'] as String),
                  );
                }).toList(),
              ),

              // Custom category input (shown only when "Other" is selected)
              if (_selectedCategory == 'other') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _customCategoryController,
                  label: 'Specify Problem Type',
                  hint: 'e.g., Street Lights, Drainage, etc.',
                  prefixIcon: Icons.edit_outlined,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please specify the problem type'
                      : null,
                ),
              ],
              const SizedBox(height: 24),

              // Title
              CustomTextField(
                controller: _titleController,
                label: localizations.translate('title'),
                hint: 'Brief title of the issue',
                prefixIcon: Icons.title,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: localizations.translate('description'),
                hint: 'Describe the issue in detail...',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Landmark
              CustomTextField(
                controller: _landmarkController,
                label: localizations.translate('landmark'),
                hint: 'Nearby landmark',
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 20),

              // Location display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _locationError != null
                      ? AppColors.error.withOpacity(0.05)
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _locationError != null
                        ? AppColors.error.withOpacity(0.3)
                        : AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _locationError != null
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _locationError != null
                            ? Icons.location_off
                            : Icons.my_location,
                        color: _locationError != null
                            ? AppColors.error
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _locationError != null
                                ? 'Location Error'
                                : localizations.translate('currentLocation'),
                            style: TextStyle(
                              fontSize: 11,
                              color: _locationError != null
                                  ? AppColors.error
                                  : AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          _isLocationLoading
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(localizations
                                        .translate('fetchingLocation')),
                                  ],
                                )
                              : Text(
                                  _locationError ?? _address,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: _locationError != null
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: _locationError != null
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                      onPressed:
                          _isLocationLoading ? null : _getCurrentLocation,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Media upload
              Text(
                localizations.translate('uploadMedia'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMedia.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedMedia.length) {
                      return GestureDetector(
                        onTap: _showMediaPicker,
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.primary, size: 32),
                              const SizedBox(height: 6),
                              Text(
                                'Add Media',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedMedia[index].path,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  )
                                : Image.file(
                                    File(_selectedMedia[index].path),
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 14,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedMedia.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Anonymous toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isAnonymous
                      ? AppColors.accent.withOpacity(0.08)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isAnonymous
                        ? AppColors.accent.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      color: _isAnonymous
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.submitAnonymous,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Your identity will be hidden',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isAnonymous,
                      onChanged: (v) => setState(() => _isAnonymous = v),
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              GradientButton(
                text: localizations.translate('submitComplaint'),
                onPressed: _isLoading ? null : _submitComplaint,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _landmarkController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }
}
