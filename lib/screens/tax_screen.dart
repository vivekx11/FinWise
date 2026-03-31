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

class TaxScreen extends StatefulWidget {
  const TaxScreen({super.key});

  @override
  State<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends State<TaxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _gstRateController = TextEditingController(text: '18');

  bool _isInclusiveGST = true;
  double _originalAmount = 0;
  double _gstAmount = 0;
  double _totalAmount = 0;
  bool _showResult = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  void _calculateGST() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final gstRate = double.tryParse(_gstRateController.text) ?? 0;

    if (amount <= 0 || gstRate < 0) return;

    setState(() {
      if (_isInclusiveGST) {
        // GST Inclusive: Extract GST from total amount
        _totalAmount = amount;
        _originalAmount = amount / (1 + gstRate / 100);
        _gstAmount = _totalAmount - _originalAmount;
      } else {
        // GST Exclusive: Add GST to base amount
        _originalAmount = amount;
        _gstAmount = amount * gstRate / 100;
        _totalAmount = _originalAmount + _gstAmount;
      }
      _showResult = true;
    });

    // Save to history
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'GST',
      title: 'GST Calculation',
      result: _currencyFormat.format(_totalAmount),
      timestamp: DateTime.now(),
      details: {
        'Type': _isInclusiveGST ? 'GST Inclusive' : 'GST Exclusive',
        'Input Amount': _currencyFormat.format(amount),
        'GST Rate': '$gstRate%',
        'Base Amount': _currencyFormat.format(_originalAmount),
        'GST Amount': _currencyFormat.format(_gstAmount),
      },
      iconCode: Icons.receipt_long_rounded.codePoint,
      colorValue: 0xFF6366F1,
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    _amountController.clear();
    _gstRateController.text = '18';
    setState(() {
      _originalAmount = 0;
      _gstAmount = 0;
      _totalAmount = 0;
      _showResult = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _gstRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'GST Calculator'),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingM),
                  
                  // GST Type Toggle
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardBackground : Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: isDark ? AppTheme.cardBorder : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isInclusiveGST = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isInclusiveGST 
                                    ? AppTheme.primaryStart 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Text(
                                'GST Inclusive',
                                textAlign: TextAlign.center,
                                style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                                  color: _isInclusiveGST 
                                      ? Colors.white 
                                      : (isDark ? AppTheme.textPrimary : Colors.black),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isInclusiveGST = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isInclusiveGST 
                                    ? AppTheme.primaryStart 
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Text(
                                'GST Exclusive',
                                textAlign: TextAlign.center,
                                style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                                  color: !_isInclusiveGST 
                                      ? Colors.white 
                                      : (isDark ? AppTheme.textPrimary : Colors.black),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: _isInclusiveGST ? 'Total Amount (with GST)' : 'Base Amount (without GST)',
                    hint: _isInclusiveGST ? 'Enter total amount' : 'Enter base amount',
                    prefixIcon: Icons.currency_rupee,
                    controller: _amountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  LegacyInputField(
                    label: 'GST Rate',
                    hint: 'Enter GST percentage',
                    prefixIcon: Icons.percent,
                    suffix: '%',
                    controller: _gstRateController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter GST rate';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  Row(
                    children: [
                      Expanded(
                        child: CalculatorButton(
                          text: 'Calculate GST',
                          icon: Icons.calculate,
                          onPressed: _calculateGST,
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
                      title: 'GST Calculation Result',
                      items: [
                        ResultItem(
                          label: 'Base Amount',
                          value: _currencyFormat.format(_originalAmount),
                        ),
                        ResultItem(
                          label: 'GST Amount',
                          value: _currencyFormat.format(_gstAmount),
                          color: AppTheme.accentOrange,
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
}