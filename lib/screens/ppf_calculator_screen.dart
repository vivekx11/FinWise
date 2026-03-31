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

class PPFCalculatorScreen extends StatefulWidget {
  const PPFCalculatorScreen({super.key});

  @override
  State<PPFCalculatorScreen> createState() => _PPFCalculatorScreenState();
}

class _PPFCalculatorScreenState extends State<PPFCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearlyInvestmentController = TextEditingController();
  final _timePeriodController = TextEditingController();

  final double _ppfRate = AppConstants.currentPPFRate;
  double _investedAmount = 0;
  double _interestEarned = 0;
  double _maturityAmount = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  void _calculatePPF() {
    if (!_formKey.currentState!.validate()) return;
    final yearlyInvestment = double.tryParse(_yearlyInvestmentController.text) ?? 0;
    final years = int.tryParse(_timePeriodController.text) ?? 0;
    if (yearlyInvestment <= 0 || years < 15) return;

    final r = _ppfRate / 100;
    double maturity = 0;
    for (int i = 0; i < years; i++) {
      maturity = (maturity + yearlyInvestment) * (1 + r);
    }

    setState(() {
      _investedAmount = yearlyInvestment * years;
      _maturityAmount = maturity;
      _interestEarned = maturity - _investedAmount;
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'PPF',
      title: 'PPF Calculation',
      result: _currencyFormat.format(_maturityAmount),
      details: {
        'Yearly Investment': _currencyFormat.format(yearlyInvestment),
        'PPF Rate': '$_ppfRate% p.a.',
        'Time Period': '$years Years',
        'Total Investment': _currencyFormat.format(_investedAmount),
        'Interest Earned': _currencyFormat.format(_interestEarned),
      },
      timestamp: DateTime.now(),
      iconCode: Icons.assured_workload_rounded.codePoint,
      colorValue: 0xFF764ba2,
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _yearlyInvestmentController.clear();
    _timePeriodController.clear();
    setState(() { _investedAmount = 0; _interestEarned = 0; _maturityAmount = 0; _showResult = false; });
  }

  @override
  void dispose() {
    _yearlyInvestmentController.dispose();
    _timePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'PPF Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
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
                        const Icon(Icons.info_outline, color: AppTheme.primaryStart),
                        const SizedBox(width: AppConstants.paddingS),
                        Expanded(
                          child: Text(
                            'Current PPF Rate: $_ppfRate% p.a.\nMax yearly investment: ₹1,50,000',
                            style: AppTheme.getBodySmall(isDark: isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  LegacyInputField(
                    label: 'Yearly Investment',
                    hint: 'Enter yearly amount (max ₹1,50,000)',
                    prefixIcon: Icons.currency_rupee,
                    controller: _yearlyInvestmentController,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      final val = double.tryParse(v!) ?? 0;
                      if (val > 150000) return 'Max ₹1,50,000 allowed';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'Time Period (Years)',
                    hint: 'Minimum 15 years',
                    prefixIcon: Icons.calendar_today,
                    suffix: 'Years',
                    controller: _timePeriodController,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Required';
                      final val = int.tryParse(v!) ?? 0;
                      if (val < 15) return 'Minimum 15 years';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate Maturity',
                          icon: Icons.calculate,
                          onPressed: _calculatePPF,
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
                      title: 'PPF Maturity Details',
                      items: [
                        ResultItem(
                          label: 'Total Investment',
                          value: _currencyFormat.format(_investedAmount),
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
