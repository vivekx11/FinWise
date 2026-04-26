// calculate


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

class CAGRCalculatorScreen extends StatefulWidget {
  const CAGRCalculatorScreen({super.key});

  @override
  State<CAGRCalculatorScreen> createState() => _CAGRCalculatorScreenState();
}

class _CAGRCalculatorScreenState extends State<CAGRCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _initialValueController = TextEditingController();
  final _finalValueController = TextEditingController();
  final _timePeriodController = TextEditingController();

  double _cagrRate = 0;
  double _totalGrowth = 0;
  double _absoluteReturn = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  final _percentFormat = NumberFormat('#,##0.00');

  void _calculateCAGR() {
    if (!_formKey.currentState!.validate()) return;

    final initialValue = double.tryParse(_initialValueController.text) ?? 0;
    final finalValue = double.tryParse(_finalValueController.text) ?? 0;
    final years = double.tryParse(_timePeriodController.text) ?? 0;

    if (initialValue <= 0 || finalValue <= 0 || years <= 0) return;

    // CAGR Formula: (Final Value / Initial Value)^(1/n) - 1
    final cagr = pow(finalValue / initialValue, 1 / years) - 1;
    final totalGrowthPercent = ((finalValue - initialValue) / initialValue) * 100;
    final absoluteReturns = finalValue - initialValue;

    setState(() {
      _cagrRate = cagr * 100;
      _totalGrowth = totalGrowthPercent;
      _absoluteReturn = absoluteReturns;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'CAGR',
      title: 'CAGR Analysis',
      result: '${_percentFormat.format(_cagrRate)}%',
      details: {
        'Initial Value': _currencyFormat.format(initialValue),
        'Final Value': _currencyFormat.format(finalValue),
        'Time Period': '$years Years',
        'CAGR': '${_percentFormat.format(_cagrRate)}%',
        'Total Growth': '${_percentFormat.format(_totalGrowth)}%',
        'Absolute Returns': _currencyFormat.format(_absoluteReturn),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.show_chart_rounded.codePoint,
      colorValue: 0xFF3B82F6, // Blue color
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _initialValueController.clear();
    _finalValueController.clear();
    _timePeriodController.clear();
    setState(() {
      _cagrRate = 0;
      _totalGrowth = 0;
      _absoluteReturn = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _initialValueController.dispose();
    _finalValueController.dispose();
    _timePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'CAGR Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryStart.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      border: Border.all(
                        color: AppTheme.primaryStart.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryStart,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'CAGR shows the annual growth rate of your investment over time',
                            style: AppTheme.getBodySmall(isDark: isDark).copyWith(
                              color: AppTheme.primaryStart,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  LegacyInputField(
                    label: 'Initial Investment Value',
                    hint: 'Enter starting value',
                    prefixIcon: Icons.currency_rupee,
                    controller: _initialValueController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter initial value';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Final Investment Value',
                    hint: 'Enter current/final value',
                    prefixIcon: Icons.currency_rupee,
                    controller: _finalValueController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter final value';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Investment Period',
                    hint: 'Enter time period',
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
                          text: 'Calculate CAGR',
                          icon: Icons.calculate,
                          onPressed: _calculateCAGR,
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
                      title: 'CAGR Analysis Results',
                      items: [
                        ResultItem(
                          label: 'CAGR (Annual Growth Rate)',
                          value: '${_percentFormat.format(_cagrRate)}%',
                          color: AppTheme.primaryStart,
                        ),
                        ResultItem(
                          label: 'Total Growth',
                          value: '${_percentFormat.format(_totalGrowth)}%',
                          color: AppTheme.accentGreen,
                        ),
                        ResultItem(
                          label: 'Absolute Returns',
                          value: _currencyFormat.format(_absoluteReturn),
                        ),
                        ResultItem(
                          label: 'Investment Period',
                          value: '${_timePeriodController.text} Years',
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
