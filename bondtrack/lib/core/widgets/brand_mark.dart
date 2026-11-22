import 'package:flutter/material.dart';
import 'package:bondtrack/core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 40,
    this.showWordmark = true,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.tealGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomPaint(painter: _BondMarkPainter()),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BONDTRACK',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: size * 0.4,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.7,
                height: 1,
                color: onDark ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'BOND INVESTMENTS',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: size * 0.2,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.35,
                height: 1,
                color: onDark
                    ? Colors.white.withValues(alpha: 0.62)
                    : AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BondMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.065
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.7)
      ..lineTo(size.width * 0.45, size.height * 0.48)
      ..lineTo(size.width * 0.61, size.height * 0.59)
      ..lineTo(size.width * 0.78, size.height * 0.31);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.31),
      size.width * 0.075,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.24, size.height * 0.7),
      size.width * 0.055,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
