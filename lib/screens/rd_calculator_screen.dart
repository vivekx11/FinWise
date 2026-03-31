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

class RDCalculatorScreen extends StatefulWidget {
  const RDCalculatorScreen({super.key});

  @override
  State<RDCalculatorScreen> createState() => _RDCalculatorScreenState();
}

class _RDCalculatorScreenState extends State<RDCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyDepositController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();

  double _maturityAmount = 0;
  double _totalDeposits = 0;
  double _interestEarned = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculateRD() {
    if (!_formKey.currentState!.validate()) return;
    final monthlyDeposit = double.tryParse(_monthlyDepositController.text) ?? 0;
    final annualRate = double.tryParse(_interestRateController.text) ?? 0;
    final months = int.tryParse(_tenureController.text) ?? 0;
    if (monthlyDeposit <= 0 || annualRate <= 0 || months <= 0) return;

    // RD with quarterly compounding
    final n = 4; // Quarterly
    final r = annualRate / 100;
    double maturity = 0;
    for (int i = 0; i < months; i++) {
      final t = (months - i) / 12;
      maturity += monthlyDeposit * pow(1 + r / n, n * t);
    }

    setState(() {
      _totalDeposits = monthlyDeposit * months;
      _maturityAmount = maturity;
      _interestEarned = maturity - _totalDeposits;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'RD',
      title: 'RD Calculation',
      result: _currencyFormat.format(_maturityAmount),
      details: {
        'Monthly Deposit': _currencyFormat.format(monthlyDeposit),
        'Interest Rate': '$annualRate% p.a.',
        'Tenure': '$months Months',
        'Total Deposits': _currencyFormat.format(_totalDeposits),
        'Interest Earned': _currencyFormat.format(_interestEarned),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: 0xFFa8edea,
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _monthlyDepositController.clear();
    _interestRateController.clear();
    _tenureController.clear();
    setState(() { _maturityAmount = 0; _totalDeposits = 0; _interestEarned = 0; _showResult = false; });
  }

  @override
  void dispose() {
    _monthlyDepositController.dispose();
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
          appBar: const CalculatorAppBar(title: 'RD Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Monthly Deposit',
                    hint: 'Enter monthly amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _monthlyDepositController,
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
                  LegacyInputField(
                    label: 'Tenure (Months)',
                    hint: 'Enter tenure in months',
                    prefixIcon: Icons.calendar_today,
                    suffix: 'Months',
                    controller: _tenureController,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Maturity',
                          icon: Icons.calculate,
                          onPressed: _calculateRD,
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
                      title: 'RD Maturity Details',
                      items: [
                        ResultItem(
                          label: 'Total Deposits',
                          value: _currencyFormat.format(_totalDeposits),
                        ),
                        ResultItem(
                          label: 'Interest Earned',
                          value: _currencyFormat.format(_interestEarned),
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
}
