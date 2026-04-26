import 'package:flutter/material.dart';
import '../screens/common/landing_page.dart';
import '../screens/common/splash_screen.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/about_screen.dart';
import '../screens/common/faq_screen.dart';
import '../screens/common/notifications_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/submit_complaint_screen.dart';
import '../screens/user/my_complaints_screen.dart';
import '../screens/user/map_view_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/officer/officer_dashboard.dart';
import '../screens/worker/worker_dashboard.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const String landing = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String submitComplaint = '/submit-complaint';
  static const String myComplaints = '/my-complaints';
  static const String mapView = '/map';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String faq = '/faq';
  static const String notifications = '/notifications';
  static const String feedback = '/feedback';
  static const String officerDashboard = '/officer-dashboard';
  static const String workerDashboard = '/worker-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  static Map<String, WidgetBuilder> get routes => {
        landing: (_) => const LandingPage(),
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        home: (_) => const HomeScreen(),
        submitComplaint: (_) => const SubmitComplaintScreen(),
        myComplaints: (_) => const MyComplaintsScreen(),
        mapView: (_) => const MapViewScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        about: (_) => const AboutScreen(),
        faq: (_) => const FaqScreen(),
        notifications: (_) => const NotificationsScreen(),
        officerDashboard: (_) => const OfficerDashboardScreen(),
        workerDashboard: (_) => const WorkerDashboardScreen(),
        adminDashboard: (_) => const AdminDashboardScreen(),
      };
}
