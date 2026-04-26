import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // Google Maps API Key - Replace with your actual key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Default map location (New Delhi, India)
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const double defaultZoom = 14.0;

  // Media upload limits
  static const int maxMediaFiles = 5;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const int maxVideoLengthSeconds = 60;

  // Pagination
  static const int complaintsPerPage = 20;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // Categories
  static const List<Map<String, dynamic>> categories = [
    {
      'id': 'roads',
      'name': 'Roads',
      'icon': Icons.add_road,
      'color': 0xFF6366F1
    },
    {
      'id': 'water',
      'name': 'Water',
      'icon': Icons.water_drop,
      'color': 0xFF06B6D4
    },
    {
      'id': 'electricity',
      'name': 'Electricity',
      'icon': Icons.electric_bolt,
      'color': 0xFFF59E0B
    },
    {
      'id': 'sanitation',
      'name': 'Sanitation',
      'icon': Icons.cleaning_services,
      'color': 0xFF10B981
    },
    {
      'id': 'public_abuse',
      'name': 'Public Abuse',
      'icon': Icons.warning_amber,
      'color': 0xFFEF4444
    },
    {
      'id': 'other',
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': 0xFF8B5CF6
    },
  ];

  // Status options
  static const List<String> statusOptions = [
    'pending',
    'in_progress',
    'resolved',
    'rejected',
  ];
}
