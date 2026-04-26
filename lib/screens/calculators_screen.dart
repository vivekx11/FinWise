// calculator 

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/theme_manager.dart';
import 'emi_calculator_screen.dart';
import 'compare_loans_screen.dart';
import 'tax_screen.dart';
import 'sip_calculator_screen.dart';
import 'fd_calculator_screen.dart';
import 'rd_calculator_screen.dart';
import 'ppf_calculator_screen.dart';
import 'lumpsum_calculator_screen.dart';
import 'compound_interest_calculator_screen.dart';
import 'retirement_planner_screen.dart';
import 'cagr_calculator_screen.dart';
import 'budget_planner_screen.dart';
import 'savings_goal_calculator_screen.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCalculators = [];
  List<Map<String, dynamic>> _filteredCalculators = [];

  @override
  void initState() {
    super.initState();
    _allCalculators = _getAllCalculators();
    _filteredCalculators = _allCalculators;
    _searchController.addListener(_filterCalculators);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCalculators() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCalculators = _allCalculators;
      } else {
        _filteredCalculators = _allCalculators.where((calculator) {
          return calculator['title'].toLowerCase().contains(query) ||
                 calculator['subtitle'].toLowerCase().contains(query) ||
                 calculator['category'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  List<Map<String, dynamic>> _getAllCalculators() {
    return [
      {
        'title': 'EMI / Mortgage Calculator',
        'subtitle': 'Calculate monthly EMI for loans',
        'icon': Icons.percent_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const EMICalculatorScreen(),
        'category': 'Loans & EMI',
      },
      {
        'title': 'Compare Loans',
        'subtitle': 'Compare different loan offers side by side',
        'icon': Icons.compare_arrows_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const CompareLoansScreen(),
        'category': 'Loans & EMI',
      },
      {
        'title': 'SIP Calculator',
        'subtitle': 'Plan your systematic investment portfolio',
        'icon': Icons.auto_graph_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const SIPCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'FD Calculator',
        'subtitle': 'Calculate fixed deposit maturity amount',
        'icon': Icons.savings_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const FDCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'RD Calculator',
        'subtitle': 'Calculate recurring deposit returns',
        'icon': Icons.account_balance_wallet_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const RDCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'PPF Calculator',
        'subtitle': 'Plan your Public Provident Fund investments',
        'icon': Icons.assured_workload_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const PPFCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'Lumpsum Calculator',
        'subtitle': 'Calculate returns on one-time investments',
        'icon': Icons.trending_up_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const LumpsumCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'Compound Interest Calculator',
        'subtitle': 'Calculate compound interest on investments',
        'icon': Icons.account_balance_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const CompoundInterestCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'CAGR Calculator',
        'subtitle': 'Calculate Compound Annual Growth Rate',
        'icon': Icons.show_chart_rounded,
        'gradientColors': AppTheme.successGradient.colors,
        'screen': const CAGRCalculatorScreen(),
        'category': 'Investments',
      },
      {
        'title': 'Retirement Planner',
        'subtitle': 'Plan your retirement corpus and investments',
        'icon': Icons.elderly_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const RetirementPlannerScreen(),
        'category': 'Financial Planning',
      },
      {
        'title': 'Budget Planner',
        'subtitle': 'Plan and track your monthly budget',
        'icon': Icons.account_balance_wallet_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const BudgetPlannerScreen(),
        'category': 'Financial Planning',
      },
      {
        'title': 'Savings Goal Calculator',
        'subtitle': 'Plan to achieve your financial goals',
        'icon': Icons.flag_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const SavingsGoalCalculatorScreen(),
        'category': 'Financial Planning',
      },
      {
        'title': 'GST Calculator',
        'subtitle': 'Calculate GST inclusive/exclusive amounts',
        'icon': Icons.receipt_rounded,
        'gradientColors': AppTheme.primaryGradient.colors,
        'screen': const TaxScreen(),
        'category': 'Tax & GST',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return Column(
          children: [
            // Fixed Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingL,
                AppConstants.paddingM,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All Calculators', style: AppTheme.getHeadingLarge(isDark: isDark).copyWith(
                    color: isDark ? AppTheme.getTextPrimary(isDark) : Colors.black,
                  )),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a calculator to get started',
                    style: AppTheme.getBodyMedium(isDark: isDark),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(
                        color: Colors.indigo.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setSearchState) {
                        return Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                                  fontSize: 14,
                                ),
                                onChanged: (value) {
                                  setSearchState(() {});
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search calculators...',
                                  hintStyle: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setSearchState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: isDark ? Colors.white : Colors.black,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingM,
                  0,
                  AppConstants.paddingM,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show filtered results or categorized view
                    if (_searchController.text.isNotEmpty)
                      _buildSearchResults(isDark)
                    else
                      _buildCategorizedView(isDark),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_filteredCalculators.isEmpty) {
      return _buildNoResultsState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${_filteredCalculators.length} calculator${_filteredCalculators.length == 1 ? '' : 's'} found',
            style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Search results list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredCalculators.length,
          itemBuilder: (context, index) {
            final calculator = _filteredCalculators[index];
            return _buildCalculatorTile(
              context,
              calculator['title'],
              calculator['subtitle'],
              calculator['icon'],
              calculator['gradientColors'],
              calculator['screen'],
              isDark,
            );
          },
        ),
      ],
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(isDark),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppTheme.cardBorder
                    : AppTheme.cardBorderLight,
              ),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No calculators found',
            style: AppTheme.getHeadingSmall(
              isDark: isDark,
            ).copyWith(color: AppTheme.getTextSecondary(isDark)),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: AppTheme.getBodyMedium(
              isDark: isDark,
            ).copyWith(color: isDark ? Colors.white : Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizedView(bool isDark) {
    // Group calculators by category
    Map<String, List<Map<String, dynamic>>> categorizedCalculators = {};
    for (var calculator in _allCalculators) {
      String category = calculator['category'];
      if (!categorizedCalculators.containsKey(category)) {
        categorizedCalculators[category] = [];
      }
      categorizedCalculators[category]!.add(calculator);
    }

    // Define category order and icons
    Map<String, IconData> categoryIcons = {
      'Loans & EMI': Icons.account_balance_rounded,
      'Investments': Icons.trending_up_rounded,
      'Financial Planning': Icons.account_balance_wallet_rounded,
      'Tax & GST': Icons.receipt_long_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (String category in categoryIcons.keys)
          if (categorizedCalculators.containsKey(category)) ...[
            _buildSectionHeader(category, categoryIcons[category]!, isDark),
            const SizedBox(height: 12),
            
            // Use ListView.builder for better performance
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categorizedCalculators[category]!.length,
              itemBuilder: (context, index) {
                final calculator = categorizedCalculators[category]![index];
                return _buildCalculatorTile(
                  context,
                  calculator['title'],
                  calculator['subtitle'],
                  calculator['icon'],
                  calculator['gradientColors'],
                  calculator['screen'],
                  isDark,
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryStart.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryStart,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.getHeadingSmall(isDark: isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
    Widget screen,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.getCardDecoration(isDark: isDark),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTheme.getBodySmall(isDark: isDark),
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.getTextMuted(isDark),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
