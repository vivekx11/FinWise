// bottom bar hai ye 
// update the bottom bar 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getBackground(isDark),
            border: Border(
              top: BorderSide(
                color: isDark 
                    ? AppTheme.cardBorder.withValues(alpha: 0.1) 
                    : AppTheme.cardBorderLight.withValues(alpha: 0.3), 
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: AppTheme.getTextMuted(isDark),
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: isSmallScreen ? 10 : 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal, 
                fontSize: isSmallScreen ? 10 : 12,
              ),
              iconSize: isSmallScreen ? 20 : 24,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate_outlined),
                  activeIcon: Icon(Icons.calculate_rounded),
                  label: 'Tools',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history_rounded),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
