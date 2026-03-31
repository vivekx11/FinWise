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

class CompoundInterestCalculatorScreen extends StatefulWidget {
  const CompoundInterestCalculatorScreen({super.key});

  @override
  State<CompoundInterestCalculatorScreen> createState() => _CompoundInterestCalculatorScreenState();
}

class _CompoundInterestCalculatorScreenState extends State<CompoundInterestCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _timePeriodController = TextEditingController();

  String _selectedCompounding = 'Yearly';
  double _principalAmount = 0;
  double _compoundInterest = 0;
  double _totalAmount = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculateCompoundInterest() {
    if (!_formKey.currentState!.validate()) return;
    
    final principal = double.tryParse(_principalController.text) ?? 0;
    final annualRate = double.tryParse(_interestRateController.text) ?? 0;
    final years = double.tryParse(_timePeriodController.text) ?? 0;
    
    if (principal <= 0 || annualRate <= 0 || years <= 0) return;

    final n = AppConstants.compoundingFrequency[_selectedCompounding] ?? 1;
    final rate = annualRate / 100;
    
    // Compound Interest Formula: A = P(1 + r/n)^(nt)
    final amount = principal * pow(1 + rate / n, n * years);
    final interest = amount - principal;

    setState(() {
      _principalAmount = principal;
      _totalAmount = amount;
      _compoundInterest = interest;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Compound Interest',
      title: 'Compound Interest',
      result: _currencyFormat.format(_totalAmount),
      details: {
        'Principal Amount': _currencyFormat.format(principal),
        'Interest Rate': '$annualRate% p.a.',
        'Time Period': '$years Years',
        'Compounding': _selectedCompounding,
        'Compound Interest': _currencyFormat.format(_compoundInterest),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.account_balance_rounded.codePoint,
      colorValue: 0xFF8B5CF6, // Purple color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _principalController.clear();
    _interestRateController.clear();
    _timePeriodController.clear();
    setState(() {
      _principalAmount = 0;
      _compoundInterest = 0;
      _totalAmount = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _timePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'Compound Interest Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Principal Amount',
                    hint: 'Enter principal amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _principalController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Interest Rate',
                    hint: 'Enter annual interest rate',
                    prefixIcon: Icons.percent,
                    suffix: '% p.a.',
                    controller: _interestRateController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Time Period',
                    hint: 'Enter time period',
                    prefixIcon: Icons.calendar_today,
                    suffix: 'Years',
                    controller: _timePeriodController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Text('Compounding Frequency', style: AppTheme.getBodyMedium(isDark: isDark)),
                  const SizedBox(height: AppConstants.paddingM),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.compoundingFrequency.keys
                        .map((f) => _buildChip(f, _selectedCompounding == f, () => setState(() => _selectedCompounding = f), isDark))
                        .toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Interest',
                          icon: Icons.calculate,
                          onPressed: _calculateCompoundInterest,
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
                      title: 'Compound Interest Summary',
                      items: [
                        ResultItem(
                          label: 'Principal Amount',
                          value: _currencyFormat.format(_principalAmount),
                        ),
                        ResultItem(
                          label: 'Compound Interest',
                          value: _currencyFormat.format(_compoundInterest),
                          color: AppTheme.accentGreen,
                        ),
                        ResultItem(
                          label: 'Total Amount',
                          value: _currencyFormat.format(_totalAmount),
                          color: AppTheme.primaryStart,
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

  Widget _buildChip(String text, bool selected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : (isDark ? AppTheme.cardBackground : Colors.white),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: selected ? Colors.transparent : (isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight),
          ),
          boxShadow: selected || isDark ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
            color: selected ? Colors.white : (isDark ? AppTheme.textSecondary : Colors.black87),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}