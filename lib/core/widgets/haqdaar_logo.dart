import 'package:flutter/material.dart';

/// Reusable HaqDaar Logo widget featuring the official emblem
/// with smooth rendering, optional glow, and fallback to vector scales.
class HaqDaarLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final bool showBorder;

  const HaqDaarLogo({
    super.key,
    this.size = 90.0,
    this.showShadow = true,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF135D38).withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
        border: showBorder
            ? Border.all(color: const Color(0xFFD4AF37), width: 2.5)
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/haqdaar_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant fallback if asset is loading or missing
            return Container(
              width: size,
              height: size,
              color: const Color(0xFF135D38),
              child: Center(
                child: Icon(
                  Icons.balance_rounded,
                  size: size * 0.55,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
