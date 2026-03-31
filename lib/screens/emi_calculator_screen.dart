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

enum LoanType { home, car, personal }

class EMICalculatorScreen extends StatefulWidget {
  const EMICalculatorScreen({super.key});

  @override
  State<EMICalculatorScreen> createState() => _EMICalculatorScreenState();
}

class _EMICalculatorScreenState extends State<EMICalculatorScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  // Controllers for each loan type
  final Map<LoanType, GlobalKey<FormState>> _formKeys = {
    LoanType.home: GlobalKey<FormState>(),
    LoanType.car: GlobalKey<FormState>(),
    LoanType.personal: GlobalKey<FormState>(),
  };
  
  final Map<LoanType, TextEditingController> _loanAmountControllers = {
    LoanType.home: TextEditingController(),
    LoanType.car: TextEditingController(),
    LoanType.personal: TextEditingController(),
  };
  
  final Map<LoanType, TextEditingController> _interestRateControllers = {
    LoanType.home: TextEditingController(),
    LoanType.car: TextEditingController(),
    LoanType.personal: TextEditingController(),
  };
  
  final Map<LoanType, TextEditingController> _tenureControllers = {
    LoanType.home: TextEditingController(),
    LoanType.car: TextEditingController(),
    LoanType.personal: TextEditingController(),
  };

  final Map<LoanType, bool> _isYears = {
    LoanType.home: true,
    LoanType.car: true,
    LoanType.personal: true,
  };
  
  final Map<LoanType, double> _emi = {
    LoanType.home: 0,
    LoanType.car: 0,
    LoanType.personal: 0,
  };
  
  final Map<LoanType, double> _totalInterest = {
    LoanType.home: 0,
    LoanType.car: 0,
    LoanType.personal: 0,
  };
  
  final Map<LoanType, double> _totalPayment = {
    LoanType.home: 0,
    LoanType.car: 0,
    LoanType.personal: 0,
  };
  
  final Map<LoanType, bool> _showResult = {
    LoanType.home: false,
    LoanType.car: false,
    LoanType.personal: false,
  };

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> _loanTypes = [
    {
      'type': LoanType.home,
      'title': 'Home Loan',
      'icon': Icons.home_rounded,
      'color': Colors.indigo,
      'gradient': [Color(0xFF4c63d2), Color(0xFF7c4dff)],
    },
    {
      'type': LoanType.car,
      'title': 'Car Loan',
      'icon': Icons.directions_car_rounded,
      'color': Colors.indigo,
      'gradient': [Color(0xFF4c63d2), Color(0xFF7c4dff)],
    },
    {
      'type': LoanType.personal,
      'title': 'Personal Loan',
      'icon': Icons.person_rounded,
      'color': Colors.indigo,
      'gradient': [Color(0xFF4c63d2), Color(0xFF7c4dff)],
    },
  ];

  LoanType get _currentLoanType => _loanTypes[_currentIndex]['type'];

  void _calculateEMI() {
    final currentType = _currentLoanType;
    if (!_formKeys[currentType]!.currentState!.validate()) return;

    final principal = double.tryParse(_loanAmountControllers[currentType]!.text) ?? 0;
    final annualRate = double.tryParse(_interestRateControllers[currentType]!.text) ?? 0;
    final tenure = int.tryParse(_tenureControllers[currentType]!.text) ?? 0;

    if (principal <= 0 || annualRate <= 0 || tenure <= 0) return;

    final monthlyRate = annualRate / 12 / 100;
    final months = _isYears[currentType]! ? tenure * 12 : tenure;

    // EMI = P × r × (1 + r)^n / ((1 + r)^n – 1)
    final powValue = pow(1 + monthlyRate, months);
    final emi = principal * monthlyRate * powValue / (powValue - 1);

    setState(() {
      _emi[currentType] = emi;
      _totalPayment[currentType] = emi * months;
      _totalInterest[currentType] = _totalPayment[currentType]! - principal;
      _showResult[currentType] = true;
    });

    // Save to history
    final loanTypeData = _loanTypes[_currentIndex];
    final calculation = CalculationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'EMI - ${loanTypeData['title']}',
      title: '${loanTypeData['title']} EMI',
      result: _currencyFormat.format(_emi[currentType]),
      details: {
        'Loan Type': loanTypeData['title'],
        'Principal': _currencyFormat.format(principal),
        'Interest Rate': '$annualRate%',
        'Tenure': '$tenure ${_isYears[currentType]! ? 'Years' : 'Months'}',
        'Total Interest': _currencyFormat.format(_totalInterest[currentType]),
        'Total Payment': _currencyFormat.format(_totalPayment[currentType]),
      },
      timestamp: DateTime.now(),
      iconCode: loanTypeData['icon'].codePoint,
      colorValue: loanTypeData['gradient'][0].value,
    );
    HistoryService.instance.saveCalculation(calculation);
  }

  void _reset() {
    final currentType = _currentLoanType;
    _loanAmountControllers[currentType]!.clear();
    _interestRateControllers[currentType]!.clear();
    _tenureControllers[currentType]!.clear();
    setState(() {
      _emi[currentType] = 0;
      _totalInterest[currentType] = 0;
      _totalPayment[currentType] = 0;
      _showResult[currentType] = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controllers in _loanAmountControllers.values) {
      controllers.dispose();
    }
    for (var controllers in _interestRateControllers.values) {
      controllers.dispose();
    }
    for (var controllers in _tenureControllers.values) {
      controllers.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        
        return GradientBackground(
          appBar: const CalculatorAppBar(title: 'EMI / Mortgage Calculator'),
          child: Column(
            children: [
              // Loan Type Tabs
              Container(
                margin: EdgeInsets.all(isSmallScreen ? 12 : AppConstants.paddingM),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.getSurface(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
                  ),
                ),
                child: Row(
                  children: List.generate(_loanTypes.length, (index) {
                    final loanType = _loanTypes[index];
                    final isSelected = _currentIndex == index;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = index);
                          _pageController.jumpToPage(index); // Direct jump without animation
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected 
                                ? LinearGradient(colors: loanType['gradient'])
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                loanType['icon'],
                                color: isSelected 
                                    ? Colors.white 
                                    : AppTheme.getTextSecondary(isDark),
                                size: isSmallScreen ? 18 : 20,
                              ),
                              SizedBox(height: isSmallScreen ? 2 : 4),
                              Text(
                                loanType['title'],
                                style: AppTheme.getBodySmall(isDark: isDark).copyWith(
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppTheme.getTextSecondary(isDark),
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_loanTypes.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: _currentIndex == index 
                          ? LinearGradient(colors: _loanTypes[index]['gradient'])
                          : null,
                      color: _currentIndex == index 
                          ? null 
                          : AppTheme.getTextMuted(isDark),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // PageView for loan types
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _loanTypes.length,
                  itemBuilder: (context, index) {
                    final loanType = _loanTypes[index]['type'] as LoanType;
                    return _buildLoanCalculator(loanType, isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoanCalculator(LoanType loanType, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 360;
        final responsivePadding = isSmallScreen ? 12.0 : AppConstants.paddingM;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(responsivePadding),
          child: Form(
            key: _formKeys[loanType],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LegacyInputField(
                  label: 'Loan Amount',
                  hint: 'Enter loan amount',
                  prefixIcon: Icons.currency_rupee,
                  controller: _loanAmountControllers[loanType]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter loan amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmallScreen ? 12 : AppConstants.paddingM),
                LegacyInputField(
                  label: 'Interest Rate',
                  hint: 'Enter annual interest rate',
                  prefixIcon: Icons.percent,
                  suffix: '%',
                  controller: _interestRateControllers[loanType]!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter interest rate';
                    }
                    return null;
                  },
                ),
                SizedBox(height: isSmallScreen ? 12 : AppConstants.paddingM),
                Flex(
                  direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: LegacyInputField(
                        label: 'Loan Tenure',
                        hint: 'Enter tenure',
                        prefixIcon: Icons.calendar_today,
                        controller: _tenureControllers[loanType]!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter tenure';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: isSmallScreen ? 0 : AppConstants.paddingM,
                      height: isSmallScreen ? 12 : 0,
                    ),
                    Container(
                      width: isSmallScreen ? double.infinity : null,
                      decoration: BoxDecoration(
                        color: AppTheme.getSurface(isDark),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        border: Border.all(
                          color: isDark ? AppTheme.cardBorder : AppTheme.cardBorderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: isSmallScreen ? MainAxisSize.max : MainAxisSize.min,
                        children: [
                          Expanded(
                            child: _buildToggleButton('Years', _isYears[loanType]!, () {
                              setState(() => _isYears[loanType] = true);
                            }),
                          ),
                          Expanded(
                            child: _buildToggleButton('Months', !_isYears[loanType]!, () {
                              setState(() => _isYears[loanType] = false);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : AppConstants.paddingL),
                Flex(
                  direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
                  children: [
                    Expanded(
                      child: CalculatorButton(
                        text: 'Calculate EMI',
                        icon: Icons.calculate,
                        onPressed: _calculateEMI,
                      ),
                    ),
                    SizedBox(
                      width: isSmallScreen ? 0 : AppConstants.paddingM,
                      height: isSmallScreen ? 12 : 0,
                    ),
                    if (!isSmallScreen)
                      IconButton(
                        onPressed: _reset,
                        icon: Icon(
                          Icons.refresh, 
                          color: AppTheme.getTextPrimary(isDark),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.getSurface(isDark),
                          padding: const EdgeInsets.all(16),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _reset,
                          icon: Icon(Icons.refresh),
                          label: Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_showResult[loanType]!) ...[
                  SizedBox(height: isSmallScreen ? 16 : AppConstants.paddingL),
                  LegacyResultCard(
                    title: '${_loanTypes.firstWhere((e) => e['type'] == loanType)['title']} EMI Breakdown',
                    items: [
                      ResultItem(
                        label: 'Monthly EMI',
                        value: _currencyFormat.format(_emi[loanType]),
                        color: _loanTypes.firstWhere((e) => e['type'] == loanType)['gradient'][0],
                      ),
                      ResultItem(
                        label: 'Principal Amount',
                        value: _currencyFormat.format(
                          double.tryParse(_loanAmountControllers[loanType]!.text) ?? 0,
                        ),
                      ),
                      ResultItem(
                        label: 'Total Interest',
                        value: _currencyFormat.format(_totalInterest[loanType]),
                        color: AppTheme.accentOrange,
                      ),
                      ResultItem(
                        label: 'Total Payment',
                        value: _currencyFormat.format(_totalPayment[loanType]),
                        color: AppTheme.accentGreen,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Text(
              text,
              style: AppTheme.getBodyMedium(isDark: isDark).copyWith(
                color: isSelected ? Colors.white : AppTheme.getTextSecondary(isDark),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
