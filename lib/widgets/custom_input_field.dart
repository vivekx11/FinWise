// input field hai ye 
// input field 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? value;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? suffix;
  final bool isRequired;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.isRequired = false,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.enabled = true,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _borderColorAnimation = ColorTween(
      begin: AppTheme.cardBorder,
      end: AppTheme.primaryStart,
    ).animate(_animationController);
    
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _validateInput();
    }
  }

  void _handleTextChange() {
    widget.onChanged(_controller.text);
    if (_errorText != null) {
      _validateInput();
    }
  }

  void _validateInput() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              widget.label,
              style: AppTheme.labelMedium.copyWith(
                color: hasError ? AppTheme.accentRed : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.accentRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Input field with animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isFocused ? [
                  BoxShadow(
                    color: (hasError ? AppTheme.accentRed : AppTheme.primaryStart)
                        .withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                maxLength: widget.maxLength,
                enabled: widget.enabled,
                style: AppTheme.bodyLarge.copyWith(
                  color: widget.enabled ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textHint,
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Container(
                          margin: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            widget.prefixIcon,
                            color: hasError 
                                ? AppTheme.accentRed 
                                : _isFocused 
                                    ? AppTheme.primaryStart 
                                    : AppTheme.textMuted,
                            size: 20,
                          ),
                        )
                      : null,
                  suffixText: widget.suffix,
                  suffixStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: hasError 
                      ? AppTheme.accentRed.withValues(alpha: 0.05)
                      : _isFocused
                          ? AppTheme.primaryStart.withValues(alpha: 0.05)
                          : AppTheme.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: hasError ? AppTheme.accentRed : _borderColorAnimation.value!,
                      width: _isFocused ? 2 : 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: hasError ? AppTheme.accentRed : AppTheme.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: hasError ? AppTheme.accentRed : AppTheme.primaryStart,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.accentRed, width: 2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.accentRed, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  counterText: '', // Hide character counter
                ),
              ),
            );
          },
        ),
        
        // Error message with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: hasError ? 24 : 0,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppTheme.accentRed,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.accentRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
