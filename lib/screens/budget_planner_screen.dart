import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/theme_manager.dart';
import '../widgets/gradient_background.dart';
import '../widgets/legacy_input_field.dart';
import '../widgets/legacy_result_card.dart';
import '../widgets/calculator_button.dart';
import '../widgets/calculator_app_bar.dart';
import '../services/history_service.dart';
import '../models/calculation_model.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyIncomeController = TextEditingController();
  final _housingController = TextEditingController();
  final _foodController = TextEditingController();
  final _transportationController = TextEditingController();
  final _utilitiesController = TextEditingController();
  final _entertainmentController = TextEditingController();
  final _otherExpensesController = TextEditingController();

  double _totalExpenses = 0;
  double _remainingAmount = 0;
  double _savingsPercentage = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _percentFormat = NumberFormat('#,##0.0');

  void _calculateBudget() {
    if (!_formKey.currentState!.validate()) return;

    final monthlyIncome = double.tryParse(_monthlyIncomeController.text) ?? 0;
    final housing = double.tryParse(_housingController.text) ?? 0;
    final food = double.tryParse(_foodController.text) ?? 0;
    final transportation = double.tryParse(_transportationController.text) ?? 0;
    final utilities = double.tryParse(_utilitiesController.text) ?? 0;
    final entertainment = double.tryParse(_entertainmentController.text) ?? 0;
    final otherExpenses = double.tryParse(_otherExpensesController.text) ?? 0;

    if (monthlyIncome <= 0) return;

    final totalExpenses = housing + food + transportation + utilities + entertainment + otherExpenses;
    final remaining = monthlyIncome - totalExpenses;
    final savingsPercent = monthlyIncome > 0 ? (remaining / monthlyIncome) * 100 : 0;

    setState(() {
      _totalExpenses = totalExpenses;
      _remainingAmount = remaining;
      _savingsPercentage = savingsPercent.toDouble();
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Budget',
      title: 'Budget Planning',
      result: _currencyFormat.format(_remainingAmount),
      details: {
        'Monthly Income': _currencyFormat.format(monthlyIncome),
        'Total Expenses': _currencyFormat.format(_totalExpenses),
        'Remaining Amount': _currencyFormat.format(_remainingAmount),
        'Savings Rate': '${_percentFormat.format(_savingsPercentage)}%',
        'Housing': _currencyFormat.format(housing),
        'Food': _currencyFormat.format(food),
        'Transportation': _currencyFormat.format(transportation),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: 0xFFF59E0B, // Amber color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _monthlyIncomeController.clear();
    _housingController.clear();
    _foodController.clear();
    _transportationController.clear();
    _utilitiesController.clear();
    _entertainmentController.clear();
    _otherExpensesController.clear();
    setState(() {
      _totalExpenses = 0;
      _remainingAmount = 0;
      _savingsPercentage = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _housingController.dispose();
    _foodController.dispose();
    _transportationController.dispose();
    _utilitiesController.dispose();
    _entertainmentController.dispose();
    _otherExpensesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'Budget Planner'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  // Income Section
                  _buildSectionHeader('Income', Icons.account_balance_rounded, isDark),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Monthly Income',
                    hint: 'Enter your monthly income',
                    prefixIcon: Icons.currency_rupee,
                    controller: _monthlyIncomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter monthly income';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  
                  // Expenses Section
                  _buildSectionHeader('Monthly Expenses', Icons.receipt_long_rounded, isDark),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Housing (Rent/EMI)',
                    hint: 'Enter housing expenses',
                    prefixIcon: Icons.home,
                    controller: _housingController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Food & Groceries',
                    hint: 'Enter food expenses',
                    prefixIcon: Icons.restaurant,
                    controller: _foodController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Transportation',
                    hint: 'Enter transport expenses',
                    prefixIcon: Icons.directions_car,
                    controller: _transportationController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Utilities (Electricity, Water, etc.)',
                    hint: 'Enter utility expenses',
                    prefixIcon: Icons.electrical_services,
                    controller: _utilitiesController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Entertainment & Lifestyle',
                    hint: 'Enter entertainment expenses',
                    prefixIcon: Icons.movie,
                    controller: _entertainmentController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Other Expenses',
                    hint: 'Enter other expenses',
                    prefixIcon: Icons.more_horiz,
                    controller: _otherExpensesController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Budget',
                          icon: Icons.calculate,
                          onPressed: _calculateBudget,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      IconButton(
                        onPressed: _reset,
                        icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.cardBackground : Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                  if (_showResult) ...[
                    const SizedBox(height: AppConstants.paddingL),
                    LegacyResultCard(
                      title: 'Budget Analysis',
                      items: [
                        ResultItem(
                          label: 'Monthly Income',
                          value: _currencyFormat.format(double.tryParse(_monthlyIncomeController.text) ?? 0),
                        ),
                        ResultItem(
                          label: 'Total Expenses',
                          value: _currencyFormat.format(_totalExpenses),
                          color: _totalExpenses > (double.tryParse(_monthlyIncomeController.text) ?? 0) 
                              ? Colors.red : null,
                        ),
                        ResultItem(
                          label: 'Remaining Amount',
                          value: _currencyFormat.format(_remainingAmount),
                          color: _remainingAmount >= 0 ? AppTheme.accentGreen : Colors.red,
                        ),
                        ResultItem(
                          label: 'Savings Rate',
                          value: '${_percentFormat.format(_savingsPercentage)}%',
                          color: _savingsPercentage >= 20 ? AppTheme.accentGreen : 
                                 _savingsPercentage >= 10 ? Colors.orange : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    _buildBudgetTips(isDark),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildBudgetTips(bool isDark) {
    String tip = '';
    Color tipColor = AppTheme.accentGreen;
    IconData tipIcon = Icons.check_circle;

    if (_savingsPercentage >= 20) {
      tip = 'Excellent! You\'re saving 20%+ of your income. Keep it up!';
      tipColor = AppTheme.accentGreen;
      tipIcon = Icons.check_circle;
    } else if (_savingsPercentage >= 10) {
      tip = 'Good savings rate! Try to increase it to 20% for better financial health.';
      tipColor = Colors.orange;
      tipIcon = Icons.info;
    } else if (_savingsPercentage >= 0) {
      tip = 'Consider reducing expenses to save at least 10-20% of your income.';
      tipColor = Colors.red;
      tipIcon = Icons.warning;
    } else {
      tip = 'Your expenses exceed income! Review and cut unnecessary expenses.';
      tipColor = Colors.red;
      tipIcon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: tipColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            tipIcon,
            color: tipColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.getBodySmall(isDark: isDark).copyWith(
                color: tipColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}