// home page 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/theme_manager.dart';
import 'emi_calculator_screen.dart';
import 'compare_loans_screen.dart';
import 'sip_calculator_screen.dart';
import 'all_calculators_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final responsivePadding = isSmallScreen ? 12.0 : AppConstants.paddingM;
        
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            responsivePadding,
            AppConstants.paddingL,
            responsivePadding,
            MediaQuery.of(context).padding.bottom + 100, // Responsive bottom padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, isDark),
              SizedBox(height: isSmallScreen ? 16 : 24),
              
              SizedBox(height: isSmallScreen ? 4 : 8),
              
              // Section Title
              _buildSectionHeader(context, isDark),
              SizedBox(height: isSmallScreen ? 16 : 20),
              
              // Simple Grid
              _buildAnimatedSimpleGrid(context, isDark),
              
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // Financial Tools Section
              _buildFinancialToolsSection(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
            color: AppTheme.getTextSecondary(isDark),
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Wrap(
          children: [
            Text(
              'Welcome to ', 
              style: AppTheme.getHeadingLarge(isDark: isDark).copyWith(
                color: isDark ? AppTheme.getTextPrimary(isDark) : Colors.black,
                fontSize: isSmallScreen ? 24 : 28,
              )
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
              ).createShader(bounds),
              child: Text(
                'FinWise!',
                style: AppTheme.getHeadingLarge(isDark: isDark).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isSmallScreen ? 24 : 28,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),
        Text(
          'What would you like to calculate today?',
          style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
            color: isDark ? AppTheme.getTextSecondary(isDark) : Colors.black87,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Access',
                    style: AppTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textPrimary : Colors.black,
                      fontSize: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Choose a calculator to get started',
                    style: AppTheme.bodySmall.copyWith(
                      color: isDark ? AppTheme.textMuted : Colors.black54,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentTeal.withValues(alpha: 0.2),
                    AppTheme.accentTeal.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                border: Border.all(
                  color: AppTheme.accentTeal.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.apps_rounded,
                    size: isSmallScreen ? 14 : 16,
                    color: AppTheme.accentTeal,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    '13 Tools',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedSimpleGrid(BuildContext context, bool isDark) {
    final cards = [
      // EMI / Mortgage Calculator
      {
        'title': 'EMI / Mortgage Calculator',
        'subtitle': 'Calculate your monthly loan payments instantly',
        'icon': Icons.percent_rounded,
        'screen': const EMICalculatorScreen(),
        'color': Colors.indigo,
      },
      // SIP Calculator
      {
        'title': 'SIP Calculator',
        'subtitle': 'Plan your systematic investment',
        'icon': Icons.auto_graph_rounded,
        'screen': const SIPCalculatorScreen(),
        'color': Colors.indigo,
      },
      // Compare Loans
      {
        'title': 'Compare Loans',
        'subtitle': 'Side by side loan comparison',
        'icon': Icons.compare_arrows_rounded,
        'screen': const CompareLoansScreen(),
        'color': Colors.indigo,
      },
    ];

    return Column(
      children: List.generate(cards.length, (index) {
        final card = cards[index];
        return Container(
          margin: EdgeInsets.only(bottom: index < cards.length - 1 ? 16 : 0),
          child: _buildCalculatorCard(
            context,
            isDark,
            card['title'] as String,
            card['subtitle'] as String,
            card['icon'] as IconData,
            card['screen'] as Widget,
            card['color'] as Color,
          ),
        );
      }),
    );
  }

  Widget _buildFinancialToolsSection(BuildContext context, bool isDark) {
    final tools = [
      {
        'title': 'FD Calculator',
        'icon': Icons.savings_rounded,
      },
      {
        'title': 'RD Calculator', 
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'title': 'PPF Calculator',
        'icon': Icons.assured_workload_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Tools',
                style: AppTheme.getHeadingSmall(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateTo(context, const AllCalculatorsScreen()),
                child: Text(
                  'See all',
                  style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tools List
          ...tools.map((tool) => _buildToolItem(
            context,
            isDark,
            tool['title'] as String,
            tool['icon'] as IconData,
          )),
        ],
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, bool isDark, String title, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateTo(context, const AllCalculatorsScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.indigo,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white : Colors.black,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
    Widget screen,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GestureDetector(
      onTap: () => _navigateTo(context, screen),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: AppTheme.getSurface(isDark),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: isSmallScreen ? 8 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            
            SizedBox(width: isSmallScreen ? 12 : 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.getHeadingSmall(isDark: isDark).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimary(isDark),
                      fontSize: isSmallScreen ? 16 : 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    subtitle,
                    style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: isSmallScreen ? 16 : 18,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
