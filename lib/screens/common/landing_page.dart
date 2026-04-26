import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_localizations.dart';
import '../../config/routes.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, localizations),
            _buildCategories(),
            _buildFeatures(context),
            _buildHowItWorks(context),
            _buildStats(),
            _buildContact(context),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════
  // HERO SECTION
  // ════════════════════════════
  Widget _buildHero(BuildContext context, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Nav bar
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('appName'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Register',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Hero content
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Text(
                'Community Issue Reporting',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Small Voices,',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              'Big Impact',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Every Complaint Counts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFCD34D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Empowering citizens in rural and semi-urban areas\nto report, track, and resolve community issues —\nfrom damaged roads to water shortages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.register),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Report an Issue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('How it Works'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════
  // CATEGORIES SECTION
  // ════════════════════════════
  Widget _buildCategories() {
    final categories = [
      {'emoji': '🛣️', 'name': 'Roads', 'desc': 'Potholes, damaged roads'},
      {'emoji': '💧', 'name': 'Water', 'desc': 'Water supply issues'},
      {
        'emoji': '⚡',
        'name': 'Electricity',
        'desc': 'Power cuts, faulty lights'
      },
      {'emoji': '🧹', 'name': 'Sanitation', 'desc': 'Waste & cleanliness'},
      {'emoji': '🌊', 'name': 'Drainage', 'desc': 'Blocked drains & flooding'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            'Report Issues By Category',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: categories
                .map((cat) => SizedBox(
                      width: 180,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(cat['emoji']!,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 10),
                            Text(cat['name']!,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(cat['desc']!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // FEATURES SECTION
  // ════════════════════════════
  Widget _buildFeatures(BuildContext context) {
    final features = [
      {
        'icon': Icons.report_rounded,
        'title': 'Easy Reporting',
        'desc':
            'Submit complaints with photos, location, and description in simple steps'
      },
      {
        'icon': Icons.phone_android,
        'title': 'SMS Login',
        'desc':
            'Citizens can login with mobile number — no email needed, works in rural areas'
      },
      {
        'icon': Icons.track_changes,
        'title': 'Real-Time Tracking',
        'desc':
            'Track your complaint status from pending to resolved in real-time'
      },
      {
        'icon': Icons.people,
        'title': 'Role-Based System',
        'desc':
            'Citizens report, Officers assign, Workers resolve — transparent workflow'
      },
      {
        'icon': Icons.map,
        'title': 'Map View',
        'desc': 'See all reported issues on a map near your location'
      },
      {
        'icon': Icons.language,
        'title': 'Multi-Language',
        'desc': 'Available in English and Hindi for wider accessibility'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            'Features',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'Built for rural communities with simplicity in mind',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: features
                .map((f) => SizedBox(
                      width: 320,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(f['icon'] as IconData,
                                  color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(height: 16),
                            Text(f['title'] as String,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(f['desc'] as String,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.5)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // HOW IT WORKS
  // ════════════════════════════
  Widget _buildHowItWorks(BuildContext context) {
    final steps = [
      {
        'step': '1',
        'title': 'Citizen Reports',
        'desc': 'Take a photo, describe the issue, and submit from your phone',
        'icon': Icons.camera_alt,
        'color': const Color(0xFF3B82F6)
      },
      {
        'step': '2',
        'title': 'Officer Reviews',
        'desc':
            'Officer receives the complaint and assigns it to a field worker',
        'icon': Icons.assignment_ind,
        'color': const Color(0xFFF59E0B)
      },
      {
        'step': '3',
        'title': 'Worker Resolves',
        'desc':
            'Worker goes to the location, fixes the issue, and uploads proof',
        'icon': Icons.build,
        'color': const Color(0xFF10B981)
      },
      {
        'step': '4',
        'title': 'Issue Resolved!',
        'desc': 'Citizen gets notified and can rate the resolution quality',
        'icon': Icons.check_circle,
        'color': const Color(0xFF8B5CF6)
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Text('How It Works',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: steps
                .map((s) => SizedBox(
                      width: 220,
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color:
                                  (s['color'] as Color).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s['icon'] as IconData,
                                color: s['color'] as Color, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  (s['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Step ${s['step']}',
                                style: TextStyle(
                                    color: s['color'] as Color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                          const SizedBox(height: 10),
                          Text(s['title'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 6),
                          Text(s['desc'] as String,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // STATS
  // ════════════════════════════
  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('500+', 'Issues Reported'),
          _statItem('350+', 'Issues Resolved'),
          _statItem('50+', 'Villages Covered'),
          _statItem('95%', 'Satisfaction Rate'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }

  // ════════════════════════════
  // CONTACT
  // ════════════════════════════
  Widget _buildContact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Text('Contact Us',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 30),
          Wrap(
            spacing: 30,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _contactCard(Icons.email, 'Email', 'fixmystreet@support.com'),
              _contactCard(Icons.phone, 'Helpline', '+91 1800-XXX-XXXX'),
              _contactCard(Icons.location_on, 'Office', 'District HQ, India'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String detail) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(detail,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════
  // FOOTER
  // ════════════════════════════
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_city, color: Colors.white54, size: 20),
              SizedBox(width: 8),
              Text('FixMyStreet',
                  style: TextStyle(
                      color: Colors.white54, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 FixMyStreet. Community Issue Reporting System.',
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
