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
import '../../widgets/language_selection_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.citizen;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Citizens & Workers register with phone number
  // Officers register with email
  bool get _isPhoneRole =>
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
            colors: [Color(0xFF7C3AED), Color(0xFFF8FAFC)],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.person_add, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(localizations.translate('createAccount'),
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Join FixMyStreet community',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 24),

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
                        const Text('Register as:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 10),
                        _buildRoleSelector(localizations),
                        const SizedBox(height: 24),

                        // Name
                        CustomTextField(
                          controller: _nameCtrl,
                          label: localizations.translate('fullName'),
                          hint: 'Enter your name',
                          prefixIcon: Icons.person,
                          autofillHints: const [AutofillHints.name],
                          validator: (v) => v == null || v.isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Phone (primary for citizens/workers)
                        if (_isPhoneRole) ...[
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
                          const SizedBox(height: 14),
                        ],

                        // Email (primary for officers, optional for citizens/workers)
                        if (!_isPhoneRole) ...[
                          CustomTextField(
                            controller: _emailCtrl,
                            label: localizations.translate('email'),
                            hint: 'Enter your email',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email is required';
                              }
                              if (!v.contains('@') || !v.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Optional phone for officers
                          CustomTextField(
                            controller: _phoneCtrl,
                            label: 'Mobile Number (optional)',
                            hint: '+91 XXXXX XXXXX',
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Password
                        CustomTextField(
                          controller: _passwordCtrl,
                          label: localizations.translate('password'),
                          hint: 'Min 6 characters',
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Department (for officers)
                        if (_selectedRole == UserRole.officer)
                          Column(children: [
                            CustomTextField(
                              controller: _deptCtrl,
                              label: 'Department',
                              hint: 'e.g. Roads, Water, Sanitation',
                              prefixIcon: Icons.business,
                            ),
                            const SizedBox(height: 14),
                          ]),

                        // Hint for phone-based users
                        if (_isPhoneRole)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.7)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Use your mobile number and password to login next time',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

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
                          text: localizations.translate('createAccount'),
                          icon: Icons.check,
                          gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
                          isLoading: auth.isLoading,
                          onPressed: () => _register(auth),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localizations.translate('alreadyHaveAccount')),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.login),
                      child: Text(localizations.translate('signIn'),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
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
      ],
    );
  }

  Widget _roleChip(String label, IconData icon, UserRole role) {
    final isActive = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7C3AED) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? const Color(0xFF7C3AED) : Colors.grey.shade300),
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

  Future<void> _register(AppAuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    // For citizens/workers: convert phone to email
    final String email;
    if (_isPhoneRole) {
      final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      final digits =
          phone.length > 10 ? phone.substring(phone.length - 10) : phone;
      email = '$digits@fixmystreet.app';
    } else {
      email = _emailCtrl.text.trim();
    }

    final success = await auth.signUp(
      email: email,
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      role: _selectedRole,
      department: _deptCtrl.text.trim(),
    );

    if (success && mounted) {
      // Show language selection dialog for first-time users
      final selectedLanguage = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LanguageSelectionDialog(),
      );

      if (selectedLanguage != null && mounted) {
        // Update user's language preference
        final localeProvider =
            Provider.of<LocaleProvider>(context, listen: false);
        await auth.updateLanguage(selectedLanguage);
        localeProvider.setLocale(Locale(selectedLanguage));
      }

      if (mounted) {
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
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _deptCtrl.dispose();
    super.dispose();
  }
}
