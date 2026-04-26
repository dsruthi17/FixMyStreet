import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.citizen;

  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Citizens & Workers login with phone number
  // Officers & Admin login with email
  bool get _isPhoneLogin =>
      _selectedRole == UserRole.citizen || _selectedRole == UserRole.worker;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final auth = Provider.of<AppAuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D4ED8), Color(0xFFF8FAFC)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.location_city, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(localizations.translate('appName'),
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(localizations.translate('signInToContinue'),
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 30),

                // Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.translate('iAmA'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        _buildRoleSelector(localizations),
                        const SizedBox(height: 24),

                        // Phone field (for citizens & workers)
                        if (_isPhoneLogin) ...[
                          CustomTextField(
                            controller: _phoneCtrl,
                            label: localizations.translate('phone'),
                            hint: 'Enter your 10-digit mobile number',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Mobile number is required';
                              }
                              final cleaned =
                                  v.replaceAll(RegExp(r'[^0-9]'), '');
                              if (cleaned.length < 10) {
                                return 'Enter a valid 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Email field (for officers & admin)
                        if (!_isPhoneLogin) ...[
                          CustomTextField(
                            controller: _emailCtrl,
                            label: localizations.translate('email'),
                            hint: 'Enter your email',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) => v == null || v.isEmpty
                                ? 'Email is required'
                                : null,
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Password field
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: localizations.translate('password'),
                          hint: 'Enter password',
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          autofillHints: const [AutofillHints.password],
                          validator: (v) => v == null || v.isEmpty
                              ? 'Password is required'
                              : null,
                        ),
                        const SizedBox(height: 8),

                        if (!_isPhoneLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.forgotPassword),
                              child: Text(
                                  localizations.translate('forgotPassword'),
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Error
                        if (auth.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(auth.error!,
                                          style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 13))),
                                ],
                              ),
                            ),
                          ),

                        GradientButton(
                          text: localizations.translate('signIn'),
                          icon: Icons.login,
                          isLoading: auth.isLoading,
                          onPressed: () => _login(auth),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.translate('dontHaveAccount')),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: Text(localizations.translate('register'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),

                TextButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.landing),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(localizations.translate('backToHome')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(AppLocalizations localizations) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _roleChip(
            localizations.translate('user'), Icons.person, UserRole.citizen),
        _roleChip(
            localizations.translate('worker'), Icons.build, UserRole.worker),
        _roleChip(
            localizations.translate('officer'), Icons.badge, UserRole.officer),
        _roleChip(localizations.translate('admin'), Icons.admin_panel_settings,
            UserRole.admin),
      ],
    );
  }

  Widget _roleChip(String label, IconData icon, UserRole role) {
    final isActive = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRole = role;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isActive ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _login(AppAuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    // For citizens/workers: convert phone to email
    final String email;
    if (_isPhoneLogin) {
      final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      // Take last 10 digits
      final digits =
          phone.length > 10 ? phone.substring(phone.length - 10) : phone;
      email = '$digits@fixmystreet.app';
    } else {
      email = _emailCtrl.text.trim();
    }

    final success = await auth.signIn(email, _passwordCtrl.text);
    if (success && mounted) {
      // Sync user's preferred language
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      auth.syncLanguageWithLocale(localeProvider);
      _navigateByRole(auth);
    }
  }

  void _navigateByRole(AppAuthProvider auth) {
    final role = auth.currentUser?.role ?? UserRole.citizen;
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
      case UserRole.officer:
        Navigator.pushReplacementNamed(context, AppRoutes.officerDashboard);
        break;
      case UserRole.worker:
        Navigator.pushReplacementNamed(context, AppRoutes.workerDashboard);
        break;
      case UserRole.citizen:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
