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

class FDCalculatorScreen extends StatefulWidget {
  const FDCalculatorScreen({super.key});

  @override
  State<FDCalculatorScreen> createState() => _FDCalculatorScreenState();
}

class _FDCalculatorScreenState extends State<FDCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();

  String _selectedCompounding = 'Quarterly';
  bool _isYears = true;
  double _maturityAmount = 0;
  double _totalInterest = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculateFD() {
    if (!_formKey.currentState!.validate()) return;
    final principal = double.tryParse(_principalController.text) ?? 0;
    final annualRate = double.tryParse(_interestRateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;
    if (principal <= 0 || annualRate <= 0 || tenure <= 0) return;

    final n = AppConstants.compoundingFrequency[_selectedCompounding] ?? 4;
    final years = _isYears ? tenure.toDouble() : tenure / 12;
    final rate = annualRate / 100;
    final maturityAmount = principal * pow(1 + rate / n, n * years);

    setState(() {
      _maturityAmount = maturityAmount;
      _totalInterest = maturityAmount - principal;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'FD',
      title: 'FD Calculation',
      result: _currencyFormat.format(_maturityAmount),
      details: {
        'Principal': _currencyFormat.format(principal),
        'Interest Rate': '$annualRate% p.a.',
        'Tenure': '$tenure ${_isYears ? 'Years' : 'Months'}',
        'Compounding': _selectedCompounding,
        'Interest Earned': _currencyFormat.format(_totalInterest),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.savings_rounded.codePoint,
      colorValue: 0xFFfa709a,
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _principalController.clear();
    _interestRateController.clear();
    _tenureController.clear();
    setState(() { _maturityAmount = 0; _totalInterest = 0; _showResult = false; });
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'FD Calculator'),
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
                    hint: 'Enter deposit amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _principalController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Interest Rate',
                    hint: 'Enter annual rate',
                    prefixIcon: Icons.percent,
                    suffix: '% p.a.',
                    controller: _interestRateController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: LegacyInputField(
                          label: 'Tenure',
                          hint: 'Enter tenure',
                          prefixIcon: Icons.calendar_today,
                          controller: _tenureController,
                          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.cardBackground : Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                          border: Border.all(color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight),
                          boxShadow: isDark ? null : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildToggle('Years', _isYears, () => setState(() => _isYears = true), isDark),
                            _buildToggle('Months', !_isYears, () => setState(() => _isYears = false), isDark),
                          ],
                        ),
                      ),
                    ],
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
                          text: 'Calculate Maturity',
                          icon: Icons.calculate,
                          onPressed: _calculateFD,
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
                      title: 'FD Maturity Details',
                      items: [
                        ResultItem(
                          label: 'Principal Amount',
                          value: _currencyFormat.format(double.tryParse(_principalController.text) ?? 0),
                        ),
                        ResultItem(
                          label: 'Total Interest Earned',
                          value: _currencyFormat.format(_totalInterest),
                          color: AppTheme.accentGreen,
                        ),
                        ResultItem(
                          label: 'Maturity Amount',
                          value: _currencyFormat.format(_maturityAmount),
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

  Widget _buildToggle(String text, bool selected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : (isDark ? null : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
