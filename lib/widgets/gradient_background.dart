import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool useSafeArea;

  const GradientBackground({
    super.key,
    required this.child,
    this.appBar,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return Scaffold(
          extendBodyBehindAppBar: appBar != null,
          extendBody: true,
          appBar: appBar,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.getBackground(isDark),
                  AppTheme.getBackground(isDark),
                ],
              ),
            ),
            child: useSafeArea ? SafeArea(bottom: false, child: this.child) : this.child,
          ),
        );
      },
    );
  }
}
