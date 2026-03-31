import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost }
enum ButtonSize { small, medium, large }

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final List<Color>? customGradient;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customGradient,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = false);
      _animationController.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              height: _getButtonHeight(),
              decoration: _getButtonDecoration(isEnabled),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: _getButtonPadding(),
                  child: Row(
                    mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: _getIconSize(),
                          height: _getIconSize(),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTextColor(isEnabled),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: _getIconSize(),
                          color: _getTextColor(isEnabled),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: _getTextStyle(isEnabled),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  BoxDecoration _getButtonDecoration(bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: widget.customGradient ?? [
              AppTheme.primaryBlue,
              AppTheme.primaryBlueDark,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled && !_isPressed ? [
            BoxShadow(
              color: (widget.customGradient?.first ?? AppTheme.primaryBlue)
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ButtonVariant.secondary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.surfaceLight.withValues(alpha: opacity),
              AppTheme.surfaceLight.withValues(alpha: opacity),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled && !_isPressed ? [
            BoxShadow(
              color: AppTheme.surfaceLight.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: opacity),
            width: 1.5,
          ),
        );
      
      case ButtonVariant.ghost:
        return BoxDecoration(
          color: AppTheme.cardBackground.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.cardBorder.withValues(alpha: opacity),
            width: 1,
          ),
        );
    }
  }

  Color _getTextColor(bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return Colors.white.withValues(alpha: opacity);
      case ButtonVariant.outline:
        return AppTheme.primaryBlue.withValues(alpha: opacity);
      case ButtonVariant.ghost:
        return AppTheme.textPrimary.withValues(alpha: opacity);
    }
  }

  TextStyle _getTextStyle(bool isEnabled) {
    final baseStyle = widget.size == ButtonSize.small
        ? AppTheme.labelMedium
        : widget.size == ButtonSize.medium
            ? AppTheme.labelLarge
            : AppTheme.bodyLarge;
    
    return baseStyle.copyWith(
      color: _getTextColor(isEnabled),
      fontWeight: FontWeight.w600,
    );
  }
}