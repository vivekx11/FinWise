import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finwise/main.dart';
import 'package:finwise/utils/theme_manager.dart';

void main() {
  testWidgets('FinanceCalculatorApp loads successfully', (
    WidgetTester tester,
  ) async {
    // Create a theme manager for testing
    final themeManager = ThemeManager();
    await themeManager.initialize();
    
    // Build the app
    await tester.pumpWidget(FinWiseApp(themeManager: themeManager));

    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify splash screen loads
    expect(find.text('Finance Calculator'), findsOneWidget);
  });
}
