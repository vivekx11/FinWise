import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/theme_manager.dart';
import 'currency_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = false;

  Future<void> _launchPrivacyPolicy() async {
    const String privacyUrl = 'https://www.moneycalculator.site/#privacy';
    
    try {
      final Uri uri = Uri.parse(privacyUrl);
      
      // Check if URL can be launched first
      final bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        // Try to launch the URL
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && mounted) {
          _showPrivacyUrlFallback();
        }
      } else {
        // Cannot launch URL, show fallback
        if (mounted) {
          _showPrivacyUrlFallback();
        }
      }
    } catch (e) {
      // Error occurred, show fallback
      if (mounted) {
        _showPrivacyUrlFallback();
      }
    }
  }
  
  void _showPrivacyUrlFallback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please visit our privacy policy at:'),
            const SizedBox(height: 4),
            Text(
              'www.moneycalculator.site/#privacy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingM,
            AppConstants.paddingL,
            AppConstants.paddingM,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTheme.getHeadingLarge(isDark: isDark).copyWith(
                color: isDark ? AppTheme.getTextPrimary(isDark) : Colors.black,
              )),
              const SizedBox(height: 8),
              Text(
                'Customize your experience',
                style: AppTheme.getBodyMedium(isDark: isDark),
              ),
              const SizedBox(height: 32),
              
              // Preferences Section
              _buildSectionTitle('Preferences', isDark),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.palette_rounded,
                title: 'Theme',
                subtitle: isDark ? 'Dark mode enabled' : 'Light mode enabled',
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeManager.toggleTheme();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(!value ? 'Switched to light mode' : 'Switched to dark mode'),
                        backgroundColor: AppTheme.getSurface(!value),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: AppTheme.primaryBlue,
                  inactiveThumbColor: AppTheme.getTextMuted(isDark),
                  inactiveTrackColor: AppTheme.getSurface(isDark),
                ),
                isDark: isDark,
              ),
              _buildSettingsTile(
                icon: Icons.notifications_rounded,
                title: 'Notifications',
                subtitle: 'Enable push notifications',
                trailing: Switch(
                  value: _notifications,
                  onChanged: (value) {
                    setState(() => _notifications = value);
                  },
                  activeColor: AppTheme.primaryBlue,
                  inactiveThumbColor: AppTheme.getTextMuted(isDark),
                  inactiveTrackColor: AppTheme.getSurface(isDark),
                ),
                isDark: isDark,
              ),
              _buildSettingsTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                subtitle: 'Indian Rupee (₹)',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.getTextMuted(isDark),
                  size: 16,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencySelectionScreen(),
                    ),
                  );
                },
                isDark: isDark,
              ),
              
              const SizedBox(height: 32),
              
              // About Section
              _buildSectionTitle('About', isDark),
              const SizedBox(height: 12),
              _buildSettingsTile(
                icon: Icons.info_rounded,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.getTextMuted(isDark),
                  size: 16,
                ),
                isDark: isDark,
              ),
              _buildSettingsTile(
                icon: Icons.star_rounded,
                title: 'Rate App',
                subtitle: 'Share your feedback',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.getTextMuted(isDark),
                  size: 16,
                ),
                onTap: () {
                  // Handle rate app functionality here
                  // You can add app store rating logic here
                },
                isDark: isDark,
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.getTextMuted(isDark),
                  size: 16,
                ),
                onTap: () => _launchPrivacyPolicy(),
                isDark: isDark,
              ),
              
              const SizedBox(height: 40),
              
              // Stats Banner
              _buildStatsBanner(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.15),
            AppTheme.primaryBlueDark.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Tools at Your Fingertips',
                      style: AppTheme.getHeadingSmall(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.getTextPrimary(isDark) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Calculate, compare, and plan your finances',
                      style: AppTheme.getBodySmall(isDark: isDark).copyWith(
                        color: isDark ? AppTheme.getTextSecondary(isDark) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.calculate_rounded, '13', 'Calculators', isDark),
              _buildStatDivider(),
              _buildStatItem(Icons.speed_rounded, 'Fast', 'Results', isDark),
              _buildStatDivider(),
              _buildStatItem(Icons.security_rounded, '100%', 'Secure', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.getTextPrimary(isDark) : Colors.black,
          ),
        ),
        Text(
          label,
          style: AppTheme.getBodySmall(isDark: isDark).copyWith(
            color: isDark ? AppTheme.getTextSecondary(isDark) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.cardBorder,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryBlue,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.getCardDecoration(isDark: isDark),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.getBodySmall(isDark: isDark),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}