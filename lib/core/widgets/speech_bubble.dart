import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Speech bubble widget for character instructions
class SpeechBubble extends StatelessWidget {
  final String text;
  final bool tailOnLeft;
  final Color? backgroundColor;
  final Color? textColor;

  const SpeechBubble({
    super.key,
    required this.text,
    this.tailOnLeft = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(
        color: backgroundColor ?? const Color(0xFFFFF9F0), // Light cream background
        tailOnLeft: tailOnLeft,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          text,
          style: AppTextStyles.instruction.copyWith(
            color: textColor ?? AppColors.textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;
  final bool tailOnLeft;

  _SpeechBubblePainter({
    required this.color,
    required this.tailOnLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Main bubble rectangle with rounded corners
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - 10),
      const Radius.circular(12),
    );
    path.addRRect(rect);

    // Add tail
    if (tailOnLeft) {
      path.moveTo(20, size.height - 10);
      path.lineTo(15, size.height);
      path.lineTo(30, size.height - 10);
    } else {
      path.moveTo(size.width - 30, size.height - 10);
      path.lineTo(size.width - 15, size.height);
      path.lineTo(size.width - 20, size.height - 10);
    }

    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black26, 4, false);

    // Draw bubble
    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFD4C4B0) // Softer beige border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3; // Slightly thicker for better visibility
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
