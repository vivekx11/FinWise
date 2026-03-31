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

class SIPCalculatorScreen extends StatefulWidget {
  const SIPCalculatorScreen({super.key});

  @override
  State<SIPCalculatorScreen> createState() => _SIPCalculatorScreenState();
}

class _SIPCalculatorScreenState extends State<SIPCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyInvestmentController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _timePeriodController = TextEditingController();

  double _investedAmount = 0;
  double _estimatedReturns = 0;
  double _totalValue = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  void _calculateSIP() {
    if (!_formKey.currentState!.validate()) return;

    final monthlyInvestment = double.tryParse(_monthlyInvestmentController.text) ?? 0;
    final annualReturn = double.tryParse(_expectedReturnController.text) ?? 0;
    final years = int.tryParse(_timePeriodController.text) ?? 0;

    if (monthlyInvestment <= 0 || annualReturn <= 0 || years <= 0) return;

    final months = years * 12;
    final monthlyRate = annualReturn / 12 / 100;

    // SIP Formula: M × ({[1 + r]^n – 1} / r) × (1 + r)
    final futureValue = monthlyInvestment * 
        (pow(1 + monthlyRate, months) - 1) / monthlyRate * 
        (1 + monthlyRate);

    setState(() {
      _investedAmount = monthlyInvestment * months;
      _totalValue = futureValue;
      _estimatedReturns = _totalValue - _investedAmount;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'SIP',
      title: 'SIP Investment',
      result: _currencyFormat.format(_totalValue),
      timestamp: DateTime.now(),
      details: {
        'Monthly Investment': _currencyFormat.format(monthlyInvestment),
        'Expected Return': '$annualReturn% p.a.',
        'Time Period': '$years Years',
        'Total Investment': _currencyFormat.format(_investedAmount),
        'Estimated Returns': _currencyFormat.format(_estimatedReturns),
      },
      iconCode: Icons.auto_graph_rounded.codePoint,
      colorValue: 0xFF6366F1, // AppTheme.accentGreen equivalent
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _monthlyInvestmentController.clear();
    _expectedReturnController.clear();
    _timePeriodController.clear();
    setState(() {
      _investedAmount = 0;
      _estimatedReturns = 0;
      _totalValue = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _monthlyInvestmentController.dispose();
    _expectedReturnController.dispose();
    _timePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'SIP Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Monthly Investment',
                    hint: 'Enter monthly SIP amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _monthlyInvestmentController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter monthly investment';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Expected Return Rate',
                    hint: 'Enter expected annual return',
                    prefixIcon: Icons.trending_up,
                    suffix: '% p.a.',
                    controller: _expectedReturnController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expected return rate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Time Period',
                    hint: 'Enter investment period',
                    prefixIcon: Icons.calendar_today,
                    suffix: 'Years',
                    controller: _timePeriodController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter time period';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Returns',
                          icon: Icons.calculate,
                          onPressed: _calculateSIP,
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
                      title: 'SIP Investment Summary',
                      items: [
                        ResultItem(
                          label: 'Total Investment',
                          value: _currencyFormat.format(_investedAmount),
                        ),
                        ResultItem(
                          label: 'Estimated Returns',
                          value: _currencyFormat.format(_estimatedReturns),
                          color: AppTheme.accentGreen,
                        ),
                        ResultItem(
                          label: 'Total Value',
                          value: _currencyFormat.format(_totalValue),
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