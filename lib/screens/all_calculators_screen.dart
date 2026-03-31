import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AllCalculatorsScreen extends StatefulWidget {
  const AllCalculatorsScreen({super.key});

  @override
  State<AllCalculatorsScreen> createState() => _AllCalculatorsScreenState();
}

class _AllCalculatorsScreenState extends State<AllCalculatorsScreen> {
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
                 calculator['subtitle'].toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AppTheme.getBackground(isDark),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'All Calculators',
                style: AppTheme.getHeadingMedium(isDark: isDark).copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingM,
                  AppConstants.paddingS,
                  AppConstants.paddingM,
                  AppConstants.paddingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose from ${_getAllCalculators().length} financial tools',
                      style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
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
                    
                    // Show filtered results or no results message
                    if (_filteredCalculators.isEmpty && _searchController.text.isNotEmpty)
                      _buildNoResultsState(isDark)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                '${_filteredCalculators.length} calculator${_filteredCalculators.length == 1 ? '' : 's'} found',
                                style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          // All Calculators List
                          ..._filteredCalculators.map((calculator) => 
                            _buildCalculatorItem(context, isDark, calculator)
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  List<Map<String, dynamic>> _getAllCalculators() {
    return [
      {
        'title': 'EMI / Mortgage Calculator',
        'subtitle': 'Calculate monthly loan payments',
        'icon': Icons.percent_rounded,
        'screen': const EMICalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'SIP Calculator',
        'subtitle': 'Systematic investment planning',
        'icon': Icons.auto_graph_rounded,
        'screen': const SIPCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Compare Loans',
        'subtitle': 'Side by side loan comparison',
        'icon': Icons.compare_arrows_rounded,
        'screen': const CompareLoansScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'FD Calculator',
        'subtitle': 'Fixed deposit maturity calculator',
        'icon': Icons.savings_rounded,
        'screen': const FDCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'RD Calculator',
        'subtitle': 'Recurring deposit returns',
        'icon': Icons.account_balance_wallet_rounded,
        'screen': const RDCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'PPF Calculator',
        'subtitle': 'Public Provident Fund calculator',
        'icon': Icons.assured_workload_rounded,
        'screen': const PPFCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Lumpsum Calculator',
        'subtitle': 'One-time investment calculator',
        'icon': Icons.trending_up_rounded,
        'screen': const LumpsumCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Compound Interest Calculator',
        'subtitle': 'Compound interest calculator',
        'icon': Icons.account_balance_rounded,
        'screen': const CompoundInterestCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'CAGR Calculator',
        'subtitle': 'Compound Annual Growth Rate',
        'icon': Icons.show_chart_rounded,
        'screen': const CAGRCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Retirement Planner',
        'subtitle': 'Plan your retirement corpus',
        'icon': Icons.elderly_rounded,
        'screen': const RetirementPlannerScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Budget Planner',
        'subtitle': 'Monthly budget planning',
        'icon': Icons.account_balance_wallet_rounded,
        'screen': const BudgetPlannerScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'Savings Goal Calculator',
        'subtitle': 'Achieve your financial goals',
        'icon': Icons.flag_rounded,
        'screen': const SavingsGoalCalculatorScreen(),
        'color': Colors.indigo,
      },
      {
        'title': 'GST Calculator',
        'subtitle': 'Tax and GST calculator',
        'icon': Icons.receipt_long_rounded,
        'screen': const TaxScreen(),
        'color': Colors.indigo,
      },
    ];
  }

  Widget _buildCalculatorItem(BuildContext context, bool isDark, Map<String, dynamic> calculator) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateTo(context, calculator['screen'] as Widget),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurface(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (calculator['color'] as Color).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (calculator['color'] as Color).withValues(alpha: 0.2),
                        (calculator['color'] as Color).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    calculator['icon'] as IconData,
                    color: calculator['color'] as Color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        calculator['title'] as String,
                        style: AppTheme.getBodyLarge(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        calculator['subtitle'] as String,
                        style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: calculator['color'] as Color,
                  size: 16,
                ),
              ],
            ),
          ),
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