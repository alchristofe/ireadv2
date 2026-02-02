import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Character avatar widget with animation support
class CharacterAvatar extends StatefulWidget {
  final String imagePath;
  final double size;
  final bool animate;

  const CharacterAvatar({
    super.key,
    required this.imagePath,
    this.size = 150,
    this.animate = false,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? _animation.value : 0),
          child: child,
        );
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          widget.imagePath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain, // Changed from cover to contain to prevent cropping
          errorBuilder: (context, error, stackTrace) {
            // Placeholder if image not found
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.person,
                size: widget.size * 0.6,
                color: AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}
