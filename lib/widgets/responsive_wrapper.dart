import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool enableHorizontalPadding;
  final bool enableVerticalPadding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.padding,
    this.enableHorizontalPadding = true,
    this.enableVerticalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Determine device type
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 768;
    final isLargeScreen = screenWidth >= 768;
    
    // Calculate responsive padding
    double horizontalPadding = 16.0;
    double verticalPadding = 16.0;
    
    if (isSmallScreen) {
      horizontalPadding = 12.0;
      verticalPadding = 12.0;
    } else if (isMediumScreen) {
      horizontalPadding = 16.0;
      verticalPadding = 16.0;
    } else if (isLargeScreen) {
      horizontalPadding = 24.0;
      verticalPadding = 20.0;
    }
    
    // Use custom padding if provided
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: enableHorizontalPadding ? horizontalPadding : 0,
      vertical: enableVerticalPadding ? verticalPadding : 0,
    );
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.1,
        maxWidth: isLargeScreen ? 1200 : double.infinity, // Max width for large screens
      ),
      padding: effectivePadding,
      child: isLargeScreen 
          ? Center(child: child) // Center content on large screens
          : child,
    );
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    DeviceType deviceType;
    if (screenWidth < 360) {
      deviceType = DeviceType.small;
    } else if (screenWidth < 768) {
      deviceType = DeviceType.medium;
    } else {
      deviceType = DeviceType.large;
    }
    
    return builder(context, deviceType);
  }
}

enum DeviceType { small, medium, large }

class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 768;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.9;
    if (screenWidth > 768) return baseSize * 1.1;
    return baseSize;
  }
  
  static double getResponsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return basePadding * 0.75;
    if (screenWidth > 768) return basePadding * 1.25;
    return basePadding;
  }
  
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return const EdgeInsets.all(12.0);
    } else if (screenWidth < 768) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }
}