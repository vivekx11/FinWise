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

class LumpsumCalculatorScreen extends StatefulWidget {
  const LumpsumCalculatorScreen({super.key});

  @override
  State<LumpsumCalculatorScreen> createState() => _LumpsumCalculatorScreenState();
}

class _LumpsumCalculatorScreenState extends State<LumpsumCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _investmentController = TextEditingController();
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

  void _calculateLumpsum() {
    if (!_formKey.currentState!.validate()) return;

    final investment = double.tryParse(_investmentController.text) ?? 0;
    final annualReturn = double.tryParse(_expectedReturnController.text) ?? 0;
    final years = int.tryParse(_timePeriodController.text) ?? 0;

    if (investment <= 0 || annualReturn <= 0 || years <= 0) return;

    // Compound Interest Formula: A = P(1 + r)^t
    final rate = annualReturn / 100;
    final futureValue = investment * pow(1 + rate, years);

    setState(() {
      _investedAmount = investment;
      _totalValue = futureValue;
      _estimatedReturns = _totalValue - _investedAmount;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Lumpsum',
      title: 'Lumpsum Investment',
      result: _currencyFormat.format(_totalValue),
      timestamp: DateTime.now(),
      details: {
        'Investment Amount': _currencyFormat.format(investment),
        'Expected Return': '$annualReturn% p.a.',
        'Time Period': '$years Years',
        'Total Investment': _currencyFormat.format(_investedAmount),
        'Estimated Returns': _currencyFormat.format(_estimatedReturns),
      },
      iconCode: Icons.trending_up_rounded.codePoint,
      colorValue: 0xFF10B981, // Green color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _investmentController.clear();
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
    _investmentController.dispose();
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
          appBar: const CalculatorAppBar(title: 'Lumpsum Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Investment Amount',
                    hint: 'Enter lumpsum amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _investmentController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter investment amount';
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
                          onPressed: _calculateLumpsum,
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
                      title: 'Lumpsum Investment Summary',
                      items: [
                        ResultItem(
                          label: 'Investment Amount',
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