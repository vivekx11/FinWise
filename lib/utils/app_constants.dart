import 'package:flutter/material.dart';

class AppConstants {
  // Responsive Padding & Margins
  static double paddingXSResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.01;
  static double paddingSResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.02;
  static double paddingMResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.04;
  static double paddingLResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.06;
  static double paddingXLResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.08;

  // Fixed Padding & Margins (for backward compatibility)
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Responsive Border Radius
  static double radiusSResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.02;
  static double radiusMResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.025;
  static double radiusLResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.035;
  static double radiusXLResponsive(BuildContext context) => MediaQuery.of(context).size.width * 0.05;

  // Fixed Border Radius (for backward compatibility)
  static const double radiusS = 8.0;
  static const double radiusM = 10.0;
  static const double radiusL = 14.0;
  static const double radiusXL = 20.0;

  // Screen Size Helpers
  static bool isSmallScreen(BuildContext context) => MediaQuery.of(context).size.width < 360;
  static bool isMediumScreen(BuildContext context) => MediaQuery.of(context).size.width >= 360 && MediaQuery.of(context).size.width < 768;
  static bool isLargeScreen(BuildContext context) => MediaQuery.of(context).size.width >= 768;
  
  // Responsive Font Sizes
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.9;
    if (screenWidth > 768) return baseSize * 1.1;
    return baseSize;
  }

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Calculator Limits
  static const double maxLoanAmount = 100000000; // 10 Cr
  static const double maxInterestRate = 50.0;
  static const int maxTenureYears = 40;
  static const int maxTenureMonths = 480;
  static const double maxSIPAmount = 10000000; // 1 Cr
  static const double maxPPFYearlyAmount = 150000; // 1.5 Lakh (PPF limit)
  static const double currentPPFRate = 7.1; // Current PPF rate

  // GST Rates
  static const List<double> gstRates = [5.0, 12.0, 18.0, 28.0];

  // Compounding Frequencies
  static const Map<String, int> compoundingFrequency = {
    'Yearly': 1,
    'Half-Yearly': 2,
    'Quarterly': 4,
    'Monthly': 12,
  };
}
