import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/gradient_button.dart';

class FeedbackScreen extends StatefulWidget {
  final String complaintId;

  const FeedbackScreen({super.key, required this.complaintId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  double _rating = 0;
  double _qualityRating = 0;
  final _feedbackController = TextEditingController();
  bool _isSubmitted = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  void _submitFeedback() {
    // Submit to Firestore (placeholder logic)
    setState(() => _isSubmitted = true);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.rateFeedback),
        backgroundColor: AppColors.primary,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: _isSubmitted ? _buildThankYou() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.rate_review_rounded,
              size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 28),
        const Text(
          AppStrings.howSatisfied,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 32),

        // Overall rating
        const Text(
          'Overall Satisfaction',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 6),
          itemBuilder: (context, _) =>
              const Icon(Icons.star_rounded, color: Colors.amber),
          unratedColor: Colors.grey.shade300,
          itemSize: 44,
          onRatingUpdate: (rating) => setState(() => _rating = rating),
        ),
        const SizedBox(height: 8),
        Text(
          _getRatingLabel(_rating),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),

        // Resolution quality
        const Text(
          'Resolution Quality',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        RatingBar.builder(
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 6),
          itemBuilder: (context, _) =>
              const Icon(Icons.star_rounded, color: Colors.teal),
          unratedColor: Colors.grey.shade300,
          itemSize: 36,
          onRatingUpdate: (rating) => setState(() => _qualityRating = rating),
        ),
        const SizedBox(height: 32),

        // Comment
        TextField(
          controller: _feedbackController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppStrings.additionalFeedback,
            hintText: 'Tell us more about your experience...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 32),

        GradientButton(
          text: AppStrings.submitFeedback,
          gradient: AppColors.successGradient,
          icon: Icons.send_rounded,
          onPressed: _rating == 0 ? null : _submitFeedback,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.skip),
        ),
      ],
    );
  }

  Widget _buildThankYou() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child:
              Icon(Icons.thumb_up_rounded, size: 60, color: AppColors.success),
        ),
        const SizedBox(height: 32),
        const Text(
          'Thank You!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Your feedback helps us improve our services\nfor the community.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        GradientButton(
          text: 'Back to Home',
          icon: Icons.home_rounded,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return '';
    if (rating <= 1) return 'Very Poor';
    if (rating <= 2) return 'Poor';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent!';
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }
}
