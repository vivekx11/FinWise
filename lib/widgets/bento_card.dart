//bentogrid.dart
// grid ui

import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/app_constants.dart';

enum BentoSize { small, medium, large, wide, tall }

class BentoCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final BentoSize size;
  final VoidCallback onTap;
  final bool isDark;

  const BentoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.size = BentoSize.small,
    required this.onTap,
    this.isDark = true,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _hoverController;
  late AnimationController _shimmerController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Press animation
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    // Hover animation
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start shimmer animation
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _hoverController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleHoverEnter(PointerEvent event) {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _handleHoverExit(PointerEvent event) {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLarge = widget.size == BentoSize.large;
    final bool isMedium = widget.size == BentoSize.medium;

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _elevationAnimation,
            _shimmerAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors[0].withValues(
                        alpha: 0.3 * _elevationAnimation.value,
                      ),
                      blurRadius: 20 + (10 * _elevationAnimation.value),
                      offset: Offset(0, 8 + (4 * _elevationAnimation.value)),
                    ),
                    if (_isPressed)
                      BoxShadow(
                        color: widget.gradientColors[0].withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isDark ? [
                            widget.gradientColors[0].withValues(
                              alpha: 0.15 + (0.05 * _elevationAnimation.value),
                            ),
                            widget.gradientColors[1].withValues(
                              alpha: 0.08 + (0.03 * _elevationAnimation.value),
                            ),
                          ] : [
                            Colors.white.withValues(
                              alpha: 0.9 + (0.1 * _elevationAnimation.value),
                            ),
                            Colors.white.withValues(
                              alpha: 0.8 + (0.2 * _elevationAnimation.value),
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                        border: Border.all(
                          color: widget.isDark 
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 0.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Shimmer effect
                          if (_isHovered)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                                  gradient: LinearGradient(
                                    begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                                    end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          
                          // Decorative gradient orbs
                          _buildBackgroundOrbs(isLarge),
                          
                          // Content
                          Padding(
                            padding: EdgeInsets.all(isLarge ? 24 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: isLarge
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceBetween,
                              children: [
                                // Icon Container
                                _buildIconContainer(isLarge, isMedium),
                                
                                if (isLarge) const SizedBox(height: 20),
                                
                                // Text Content
                                _buildTextContent(isLarge, isMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs(bool isLarge) {
    return Stack(
      children: [
        // Primary orb
        Positioned(
          right: -30,
          top: -30,
          child: Container(
            width: isLarge ? 140 : 100,
            height: isLarge ? 140 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.gradientColors[0].withValues(alpha: 0.3),
                  widget.gradientColors[0].withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Secondary orb
        Positioned(
          left: -20,
          bottom: -20,
          child: Container(
            width: isLarge ? 80 : 60,
            height: isLarge ? 80 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.gradientColors[1].withValues(alpha: 0.2),
                  widget.gradientColors[1].withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconContainer(bool isLarge, bool isMedium) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 18 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
        borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: widget.gradientColors[1].withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: isLarge ? 36 : isMedium ? 28 : 24,
      ),
    );
  }

  Widget _buildTextContent(bool isLarge, bool isMedium) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            widget.title,
            style: isLarge
                ? AppTheme.getHeadingMedium(isDark: widget.isDark).copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : isMedium
                    ? AppTheme.getBodyLarge(isDark: widget.isDark).copyWith(
                        fontWeight: FontWeight.w600,
                      )
                    : AppTheme.getBodyMedium(isDark: widget.isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? AppTheme.textPrimary : Colors.black,
                      ),
            maxLines: isLarge ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (widget.subtitle != null) ...[
            SizedBox(height: isLarge ? 8 : 4),
            Text(
              widget.subtitle!,
              style: isLarge
                  ? AppTheme.getBodyMedium(isDark: widget.isDark).copyWith(
                      color: widget.isDark ? AppTheme.textSecondary : Colors.black87,
                    )
                  : AppTheme.getBodySmall(isDark: widget.isDark).copyWith(
                      color: widget.isDark ? AppTheme.textSecondary : Colors.black87,
                    ),
              maxLines: isLarge ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Action indicator for large cards
          if (isLarge) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.gradientColors[0].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Calculate',
                    style: AppTheme.labelMedium.copyWith(
                      color: widget.gradientColors[0],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: widget.gradientColors[0],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
