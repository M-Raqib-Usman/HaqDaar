import 'package:flutter/material.dart';

/// Standard HaqDaar branding header containing the emblem, title, and subtitle.
/// Do not modify without verifying all screens that depend on it.
class AppBrandingHeader extends StatelessWidget {
  final String? subtitle;
  final IconData icon;
  final double iconSize;

  const AppBrandingHeader({
    super.key,
    this.subtitle,
    this.icon = Icons.gavel_rounded,
    this.iconSize = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'HaqDaar',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'حقدار • Legal Rights & Justice Platform',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
