import 'package:flutter/material.dart';

/// Standard metric / summary card used across dashboards and financial screens in HaqDaar.
/// Strictly designed to match HaqDaar UI.
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final IconData? icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
    this.backgroundColor = Colors.white,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24, color: Colors.black87),
              const SizedBox(height: 8),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
