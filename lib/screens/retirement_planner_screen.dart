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

class RetirementPlannerScreen extends StatefulWidget {
  const RetirementPlannerScreen({super.key});

  @override
  State<RetirementPlannerScreen> createState() => _RetirementPlannerScreenState();
}

class _RetirementPlannerScreenState extends State<RetirementPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  final _currentSavingsController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _inflationRateController = TextEditingController();

  double _requiredCorpus = 0;
  double _monthlySIPRequired = 0;
  double _totalInvestment = 0;
  double _currentSavingsValue = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculateRetirement() {
    if (!_formKey.currentState!.validate()) return;

    final currentAge = int.tryParse(_currentAgeController.text) ?? 0;
    final retirementAge = int.tryParse(_retirementAgeController.text) ?? 0;
    final monthlyExpenses = double.tryParse(_monthlyExpensesController.text) ?? 0;
    final currentSavings = double.tryParse(_currentSavingsController.text) ?? 0;
    final expectedReturn = double.tryParse(_expectedReturnController.text) ?? 0;
    final inflationRate = double.tryParse(_inflationRateController.text) ?? 0;

    if (currentAge <= 0 || retirementAge <= currentAge || monthlyExpenses <= 0 || 
        expectedReturn <= 0 || inflationRate <= 0) {
      return;
    }

    final yearsToRetirement = retirementAge - currentAge;
    final monthsToRetirement = yearsToRetirement * 12;
    
    // Calculate future value of current expenses considering inflation
    final futureMonthlyExpenses = monthlyExpenses * pow(1 + inflationRate / 100, yearsToRetirement);
    
    // Assuming 25 years post retirement (life expectancy)
    final postRetirementYears = 25;
    
    // Calculate required corpus using present value of annuity formula
    // Considering inflation during retirement as well
    final realReturnRate = (expectedReturn - inflationRate) / 100;
    final requiredCorpus = futureMonthlyExpenses * 12 * 
        ((1 - pow(1 + realReturnRate, -postRetirementYears)) / realReturnRate);
    
    // Future value of current savings
    final currentSavingsFutureValue = currentSavings * pow(1 + expectedReturn / 100, yearsToRetirement);
    
    // Remaining corpus needed
    final remainingCorpus = requiredCorpus - currentSavingsFutureValue;
    
    // Calculate monthly SIP required
    final monthlyReturn = expectedReturn / 12 / 100;
    final monthlySIP = remainingCorpus > 0 ? 
        remainingCorpus / (((pow(1 + monthlyReturn, monthsToRetirement) - 1) / monthlyReturn) * (1 + monthlyReturn)) : 0;

    setState(() {
      _requiredCorpus = requiredCorpus;
      _monthlySIPRequired = monthlySIP.toDouble();
      _totalInvestment = (monthlySIP * monthsToRetirement).toDouble();
      _currentSavingsValue = currentSavingsFutureValue;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Retirement',
      title: 'Retirement Planning',
      result: _currencyFormat.format(_requiredCorpus),
      details: {
        'Current Age': '$currentAge Years',
        'Retirement Age': '$retirementAge Years',
        'Monthly Expenses': _currencyFormat.format(monthlyExpenses),
        'Required Corpus': _currencyFormat.format(_requiredCorpus),
        'Monthly SIP Required': _currencyFormat.format(_monthlySIPRequired),
        'Current Savings Future Value': _currencyFormat.format(_currentSavingsValue),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.elderly_rounded.codePoint,
      colorValue: 0xFFEF4444, // Red color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _currentAgeController.clear();
    _retirementAgeController.clear();
    _monthlyExpensesController.clear();
    _currentSavingsController.clear();
    _expectedReturnController.clear();
    _inflationRateController.clear();
    setState(() {
      _requiredCorpus = 0;
      _monthlySIPRequired = 0;
      _totalInvestment = 0;
      _currentSavingsValue = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _monthlyExpensesController.dispose();
    _currentSavingsController.dispose();
    _expectedReturnController.dispose();
    _inflationRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'Retirement Planner'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: LegacyInputField(
                          label: 'Current Age',
                          hint: 'Your current age',
                          prefixIcon: Icons.person,
                          suffix: 'Years',
                          controller: _currentAgeController,
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: LegacyInputField(
                          label: 'Retirement Age',
                          hint: 'Planned retirement age',
                          prefixIcon: Icons.elderly,
                          suffix: 'Years',
                          controller: _retirementAgeController,
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Current Monthly Expenses',
                    hint: 'Your current monthly expenses',
                    prefixIcon: Icons.currency_rupee,
                    controller: _monthlyExpensesController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Current Savings',
                    hint: 'Your current retirement savings',
                    prefixIcon: Icons.savings,
                    controller: _currentSavingsController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: LegacyInputField(
                          label: 'Expected Return',
                          hint: 'Expected annual return',
                          prefixIcon: Icons.trending_up,
                          suffix: '% p.a.',
                          controller: _expectedReturnController,
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: LegacyInputField(
                          label: 'Inflation Rate',
                          hint: 'Expected inflation rate',
                          prefixIcon: Icons.trending_down,
                          suffix: '% p.a.',
                          controller: _inflationRateController,
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Plan Retirement',
                          icon: Icons.calculate,
                          onPressed: _calculateRetirement,
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
                      title: 'Retirement Plan Summary',
                      items: [
                        ResultItem(
                          label: 'Required Retirement Corpus',
                          value: _currencyFormat.format(_requiredCorpus),
                          color: AppTheme.primaryStart,
                        ),
                        ResultItem(
                          label: 'Monthly SIP Required',
                          value: _currencyFormat.format(_monthlySIPRequired),
                          color: AppTheme.accentGreen,
                        ),
                        ResultItem(
                          label: 'Current Savings Future Value',
                          value: _currencyFormat.format(_currentSavingsValue),
                        ),
                        ResultItem(
                          label: 'Total Investment Needed',
                          value: _currencyFormat.format(_totalInvestment),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}