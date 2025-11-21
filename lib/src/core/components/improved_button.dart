import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

/// Improved button with loading state and animations
class ImprovedButton extends StatefulWidget {
  const ImprovedButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.elevated,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool fullWidth;

  @override
  State<ImprovedButton> createState() => _ImprovedButtonState();
}

class _ImprovedButtonState extends State<ImprovedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  Widget _buildButton() {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          AppSpacing.gapSM,
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: _getIconSize()),
          AppSpacing.gapSM,
        ],
        Text(
          widget.label,
          style: textStyle,
        ),
      ],
    );

    Widget button;
    switch (widget.variant) {
      case ButtonVariant.elevated:
        button = ElevatedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            padding: padding,
            minimumSize: widget.fullWidth
                ? const Size(double.infinity, 0)
                : const Size(0, 0),
          ),
          child: content,
        );
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: padding,
            minimumSize: widget.fullWidth
                ? const Size(double.infinity, 0)
                : const Size(0, 0),
          ),
          child: content,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: TextButton.styleFrom(
            padding: padding,
            minimumSize: widget.fullWidth
                ? const Size(double.infinity, 0)
                : const Size(0, 0),
          ),
          child: content,
        );
        break;
    }
    
    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      child: button,
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _buildButton(),
    );
  }
}

enum ButtonVariant { elevated, outlined, text }
enum ButtonSize { small, medium, large }

