import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class SchemeProgressBannerCard extends StatelessWidget {
  const SchemeProgressBannerCard({
    required this.schemeName,
    required this.currentPairs,
    required this.targetPairs,
    required this.nudgeText,
    required this.progressFraction,
    super.key,
    this.rewardBadgeText,
    this.onTap,
  });

  final String schemeName;
  final int currentPairs;
  final int targetPairs;
  final String nudgeText;
  final double progressFraction;
  final String? rewardBadgeText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerBg = isDark
        ? GraphicsColorConsts.cardSlate.withAlpha(200)
        : GraphicsColorConsts.surfaceLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: containerBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: GraphicsColorConsts.warningAmber.withAlpha(isDark ? 120 : 160),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: GraphicsColorConsts.warningAmber.withAlpha(isDark ? 15 : 25),
              blurRadius: 10.0,
              offset: const Offset(0.0, 3.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: GraphicsColorConsts.warningAmber,
                      size: 20.0,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      schemeName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$currentPairs / $targetPairs Pairs',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progressFraction.clamp(0.0, 1.0),
                minHeight: 8.0,
                backgroundColor: isDark
                    ? GraphicsColorConsts.borderSlate
                    : Colors.amber.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  GraphicsColorConsts.warningAmber,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nudgeText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.amber.shade100 : Colors.amber.shade900,
                    ),
                  ),
                ),
                if (rewardBadgeText != null && (rewardBadgeText ?? '').isNotEmpty) ...[
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: GraphicsColorConsts.warningAmber.withAlpha(isDark ? 50 : 35),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      rewardBadgeText ?? '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
