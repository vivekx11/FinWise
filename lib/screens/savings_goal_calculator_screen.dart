import 'dart:math';
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

class SavingsGoalCalculatorScreen extends StatefulWidget {
  const SavingsGoalCalculatorScreen({super.key});

  @override
  State<SavingsGoalCalculatorScreen> createState() => _SavingsGoalCalculatorScreenState();
}

class _SavingsGoalCalculatorScreenState extends State<SavingsGoalCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalAmountController = TextEditingController();
  final _currentSavingsController = TextEditingController();
  final _timeFrameController = TextEditingController();
  final _expectedReturnController = TextEditingController();

  double _monthlySIPRequired = 0;
  double _totalInvestment = 0;
  double _currentSavingsFutureValue = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculateSavingsGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goalAmount = double.tryParse(_goalAmountController.text) ?? 0;
    final currentSavings = double.tryParse(_currentSavingsController.text) ?? 0;
    final timeFrame = int.tryParse(_timeFrameController.text) ?? 0;
    final expectedReturn = double.tryParse(_expectedReturnController.text) ?? 0;

    if (goalAmount <= 0 || timeFrame <= 0 || expectedReturn <= 0) return;

    final years = timeFrame.toDouble();
    final rate = expectedReturn / 100;
    
    // Future value of current savings
    final currentSavingsFV = currentSavings * pow(1 + rate, years);
    
    // Additional amount needed
    final additionalNeeded = goalAmount - currentSavingsFV;
    
    if (additionalNeeded <= 0) {
      // Goal already achievable with current savings
      setState(() {
        _monthlySIPRequired = 0;
        _totalInvestment = 0;
        _currentSavingsFutureValue = currentSavingsFV;
        _showResult = true;
      });
    } else {
      // Calculate monthly SIP required
      final monthlyRate = rate / 12;
      final months = years * 12;
      
      // SIP formula to find PMT: FV = PMT × (((1 + r)^n - 1) / r) × (1 + r)
      final monthlySIP = additionalNeeded / 
          (((pow(1 + monthlyRate, months) - 1) / monthlyRate) * (1 + monthlyRate));
      
      setState(() {
        _monthlySIPRequired = monthlySIP;
        _totalInvestment = monthlySIP * months;
        _currentSavingsFutureValue = currentSavingsFV;
        _showResult = true;
      });
    }

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Savings Goal',
      title: 'Savings Goal Planning',
      result: _currencyFormat.format(goalAmount),
      details: {
        'Goal Amount': _currencyFormat.format(goalAmount),
        'Current Savings': _currencyFormat.format(currentSavings),
        'Time Frame': '$timeFrame Years',
        'Expected Return': '$expectedReturn% p.a.',
        'Monthly SIP Required': _currencyFormat.format(_monthlySIPRequired),
        'Current Savings Future Value': _currencyFormat.format(_currentSavingsFutureValue),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.flag_rounded.codePoint,
      colorValue: 0xFF06B6D4, // Cyan color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _goalAmountController.clear();
    _currentSavingsController.clear();
    _timeFrameController.clear();
    _expectedReturnController.clear();
    setState(() {
      _monthlySIPRequired = 0;
      _totalInvestment = 0;
      _currentSavingsFutureValue = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _goalAmountController.dispose();
    _currentSavingsController.dispose();
    _timeFrameController.dispose();
    _expectedReturnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'Savings Goal Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  // Goal Section
                  _buildSectionHeader('Your Financial Goal', Icons.flag_rounded, isDark),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Goal Amount',
                    hint: 'Enter your target amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _goalAmountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter goal amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Current Savings',
                    hint: 'Enter your current savings',
                    prefixIcon: Icons.savings,
                    controller: _currentSavingsController,
                    validator: (v) => null, // Optional field
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: LegacyInputField(
                          label: 'Time Frame',
                          hint: 'Years to achieve goal',
                          prefixIcon: Icons.calendar_today,
                          suffix: 'Years',
                          controller: _timeFrameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: LegacyInputField(
                          label: 'Expected Return',
                          hint: 'Expected annual return',
                          prefixIcon: Icons.trending_up,
                          suffix: '% p.a.',
                          controller: _expectedReturnController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  
                  // Popular Goals Section
                  _buildSectionHeader('Popular Goals', Icons.star_rounded, isDark),
                  const SizedBox(height: AppConstants.paddingM),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildGoalChip('Car - ₹10L', () => _goalAmountController.text = '1000000', isDark),
                      _buildGoalChip('House - ₹50L', () => _goalAmountController.text = '5000000', isDark),
                      _buildGoalChip('Education - ₹25L', () => _goalAmountController.text = '2500000', isDark),
                      _buildGoalChip('Wedding - ₹15L', () => _goalAmountController.text = '1500000', isDark),
                      _buildGoalChip('Vacation - ₹2L', () => _goalAmountController.text = '200000', isDark),
                      _buildGoalChip('Emergency - ₹5L', () => _goalAmountController.text = '500000', isDark),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Plan',
                          icon: Icons.calculate,
                          onPressed: _calculateSavingsGoal,
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
                      title: 'Savings Goal Plan',
                      items: [
                        ResultItem(
                          label: 'Goal Amount',
                          value: _currencyFormat.format(double.tryParse(_goalAmountController.text) ?? 0),
                          color: AppTheme.primaryStart,
                        ),
                        if (_monthlySIPRequired > 0) ...[
                          ResultItem(
                            label: 'Monthly SIP Required',
                            value: _currencyFormat.format(_monthlySIPRequired),
                            color: AppTheme.accentGreen,
                          ),
                          ResultItem(
                            label: 'Total Investment Needed',
                            value: _currencyFormat.format(_totalInvestment),
                          ),
                        ],
                        ResultItem(
                          label: 'Current Savings Future Value',
                          value: _currencyFormat.format(_currentSavingsFutureValue),
                        ),
                        if (_monthlySIPRequired == 0)
                          ResultItem(
                            label: 'Status',
                            value: 'Goal Achievable with Current Savings!',
                            color: AppTheme.accentGreen,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    _buildGoalTips(isDark),
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

  Widget _buildGoalChip(String text, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
          ),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTheme.getBodySmall(isDark: isDark).copyWith(
            color: AppTheme.primaryStart,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTips(bool isDark) {
    final timeFrame = int.tryParse(_timeFrameController.text) ?? 0;
    String tip = '';
    Color tipColor = AppTheme.accentGreen;
    IconData tipIcon = Icons.lightbulb;

    if (_monthlySIPRequired == 0) {
      tip = 'Great! Your current savings will grow to meet your goal. Consider investing in diversified funds.';
    } else if (timeFrame >= 10) {
      tip = 'Long-term goal! Consider equity mutual funds for potentially higher returns.';
    } else if (timeFrame >= 5) {
      tip = 'Medium-term goal. Consider balanced funds or hybrid investments.';
    } else {
      tip = 'Short-term goal. Consider debt funds or FDs for capital protection.';
      tipColor = Colors.orange;
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