// wrapper element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';

// Legacy wrapper for backward compatibility
class LegacyInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffix;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const LegacyInputField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.controller,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          style: AppTheme.getBodyLarge(isDark: isDark),
          onChanged: onChanged,
          validator: validator,
          decoration: AppTheme.inputDecoration(
            label: label,
            hint: hint,
            prefixIcon: prefixIcon,
            suffix: suffix,
            isDark: isDark,
          ),
        );
      },
    );
  }
}
