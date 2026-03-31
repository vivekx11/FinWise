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

class CompareLoansScreen extends StatefulWidget {
  const CompareLoansScreen({super.key});

  @override
  State<CompareLoansScreen> createState() => _CompareLoansScreenState();
}

class _CompareLoansScreenState extends State<CompareLoansScreen> {
  final _formKey = GlobalKey<FormState>();

  // Loan A Controllers
  final _loanAAmountController = TextEditingController();
  final _loanAInterestController = TextEditingController();
  final _loanATenureController = TextEditingController();

  // Loan B Controllers
  final _loanBAmountController = TextEditingController();
  final _loanBInterestController = TextEditingController();
  final _loanBTenureController = TextEditingController();

  Map<String, double> _loanAResults = {};
  Map<String, double> _loanBResults = {};
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  Map<String, double> _calculateLoan(double principal, double annualRate, int months) {
    if (principal <= 0 || annualRate <= 0 || months <= 0) {
      return {'emi': 0, 'totalInterest': 0, 'totalPayment': 0};
    }

    final monthlyRate = annualRate / 12 / 100;
    final powValue = pow(1 + monthlyRate, months);
    final emi = principal * monthlyRate * powValue / (powValue - 1);
    final totalPayment = emi * months;
    final totalInterest = totalPayment - principal;

    return {
      'emi': emi,
      'totalInterest': totalInterest,
      'totalPayment': totalPayment,
    };
  }

  void _compare() {
    if (!_formKey.currentState!.validate()) return;

    final loanAAmount = double.tryParse(_loanAAmountController.text) ?? 0;
    final loanAInterest = double.tryParse(_loanAInterestController.text) ?? 0;
    final loanATenure = int.tryParse(_loanATenureController.text) ?? 0;

    final loanBAmount = double.tryParse(_loanBAmountController.text) ?? 0;
    final loanBInterest = double.tryParse(_loanBInterestController.text) ?? 0;
    final loanBTenure = int.tryParse(_loanBTenureController.text) ?? 0;

    setState(() {
      _loanAResults = _calculateLoan(loanAAmount, loanAInterest, loanATenure * 12);
      _loanBResults = _calculateLoan(loanBAmount, loanBInterest, loanBTenure * 12);
      _showResult = true;
    });
  }

  void _reset() {
    _loanAAmountController.clear();
    _loanAInterestController.clear();
    _loanATenureController.clear();
    _loanBAmountController.clear();
    _loanBInterestController.clear();
    _loanBTenureController.clear();
    setState(() {
      _loanAResults = {};
      _loanBResults = {};
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _loanAAmountController.dispose();
    _loanAInterestController.dispose();
    _loanATenureController.dispose();
    _loanBAmountController.dispose();
    _loanBInterestController.dispose();
    _loanBTenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'Compare Loans'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  _buildLoanSection(
                    title: 'Loan A',
                    color: AppTheme.primaryStart,
                    amountController: _loanAAmountController,
                    interestController: _loanAInterestController,
                    tenureController: _loanATenureController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  _buildLoanSection(
                    title: 'Loan B',
                    color: AppTheme.accentOrange,
                    amountController: _loanBAmountController,
                    interestController: _loanBInterestController,
                    tenureController: _loanBTenureController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Compare',
                          icon: Icons.compare_arrows,
                          onPressed: _compare,
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
                    _buildComparisonResults(isDark),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoanSection({
    required String title,
    required Color color,
    required TextEditingController amountController,
    required TextEditingController interestController,
    required TextEditingController tenureController,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(title, style: AppTheme.getHeadingSmall(isDark: isDark)),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          LegacyInputField(
            label: 'Loan Amount',
            prefixIcon: Icons.currency_rupee,
            controller: amountController,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: LegacyInputField(
                  label: 'Interest (%)',
                  prefixIcon: Icons.percent,
                  controller: interestController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: LegacyInputField(
                  label: 'Tenure (Years)',
                  prefixIcon: Icons.calendar_today,
                  controller: tenureController,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResults(bool isDark) {
    final emiDiff = (_loanAResults['emi'] ?? 0) - (_loanBResults['emi'] ?? 0);
    final interestDiff = (_loanAResults['totalInterest'] ?? 0) - (_loanBResults['totalInterest'] ?? 0);
    final paymentDiff = (_loanAResults['totalPayment'] ?? 0) - (_loanBResults['totalPayment'] ?? 0);

    return Column(
      children: [
        _buildResultRow(
          'Monthly EMI',
          _loanAResults['emi'] ?? 0,
          _loanBResults['emi'] ?? 0,
          isDark,
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildResultRow(
          'Total Interest',
          _loanAResults['totalInterest'] ?? 0,
          _loanBResults['totalInterest'] ?? 0,
          isDark,
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildResultRow(
          'Total Payment',
          _loanAResults['totalPayment'] ?? 0,
          _loanBResults['totalPayment'] ?? 0,
          isDark,
        ),
        const SizedBox(height: AppConstants.paddingL),
        LegacyResultCard(
          title: 'Difference (A - B)',
          items: [
            ResultItem(
              label: 'EMI Difference',
              value: _currencyFormat.format(emiDiff.abs()),
              color: emiDiff > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
            ),
            ResultItem(
              label: 'Interest Difference',
              value: _currencyFormat.format(interestDiff.abs()),
              color: interestDiff > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
            ),
            ResultItem(
              label: 'Total Difference',
              value: _currencyFormat.format(paymentDiff.abs()),
              color: paymentDiff > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, double loanA, double loanB, bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.getResultLabel(isDark: isDark)),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryStart,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Loan A', style: AppTheme.getBodySmall(isDark: isDark)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(loanA),
                      style: AppTheme.getResultValue(isDark: isDark).copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Loan B', style: AppTheme.getBodySmall(isDark: isDark)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFormat.format(loanB),
                      style: AppTheme.getResultValue(isDark: isDark).copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
