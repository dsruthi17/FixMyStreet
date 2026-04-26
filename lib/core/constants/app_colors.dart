import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Palette ───
  static const Color primary = Color(0xFF2563EB);        // Vivid Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // ─── Secondary / Accent ───
  static const Color accent = Color(0xFFF59E0B);         // Amber
  static const Color accentLight = Color(0xFFFCD34D);
  static const Color accentDark = Color(0xFFD97706);

  // ─── Status Colors ───
  static const Color success = Color(0xFF10B981);         // Emerald
  static const Color warning = Color(0xFFF59E0B);         // Amber
  static const Color error = Color(0xFFEF4444);           // Red
  static const Color info = Color(0xFF3B82F6);            // Blue

  // ─── Neutrals ───
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // ─── Text ───
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Category Colors ───
  static const Color roads = Color(0xFF6366F1);           // Indigo
  static const Color water = Color(0xFF06B6D4);           // Cyan
  static const Color electricity = Color(0xFFF59E0B);     // Amber
  static const Color sanitation = Color(0xFF10B981);      // Emerald
  static const Color publicAbuse = Color(0xFFEF4444);     // Red

  // ─── Dark Theme ───
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'roads':
        return roads;
      case 'water':
        return water;
      case 'electricity':
        return electricity;
      case 'sanitation':
        return sanitation;
      case 'public abuse':
      case 'public_abuse':
        return publicAbuse;
      default:
        return primary;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warning;
      case 'in progress':
      case 'in_progress':
        return info;
      case 'resolved':
        return success;
      case 'rejected':
        return error;
      default:
        return textSecondary;
    }
  }
}
