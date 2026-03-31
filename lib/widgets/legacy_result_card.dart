import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/theme_manager.dart';

// Legacy wrapper for backward compatibility
class LegacyResultCard extends StatelessWidget {
  final List<ResultItem> items;
  final String? title;

  const LegacyResultCard({
    super.key,
    required this.items,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDark = themeManager.isDarkMode;
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: AppTheme.getCardDecoration(isDark: isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(title!, style: AppTheme.getHeadingSmall(isDark: isDark)),
                    const SizedBox(height: AppConstants.paddingM),
                  ],
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.label, style: AppTheme.getResultLabel(isDark: isDark)),
                            Text(
                              item.value,
                              style: AppTheme.getResultValue(isDark: isDark).copyWith(
                                color: item.color ?? AppTheme.getTextPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ResultItem {
  final String label;
  final String value;
  final Color? color;

  const ResultItem({
    required this.label,
    required this.value,
    this.color,
  });
}