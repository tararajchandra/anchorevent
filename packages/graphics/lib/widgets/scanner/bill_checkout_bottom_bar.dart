import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class BillCheckoutBottomBar extends StatelessWidget {
  final String grandTotalFormatted;
  final String pairsSummary;
  final VoidCallback onSaveBill;
  final bool isSaving;

  const BillCheckoutBottomBar({
    super.key,
    required this.grandTotalFormatted,
    required this.pairsSummary,
    required this.onSaveBill,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isDark ? GraphicsColorConsts.surfaceSlate : GraphicsColorConsts.surfaceLight,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: theme.dividerColor),
        boxShadow: <BoxShadow>[
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8.0,
              offset: const Offset(0.0, 2.0),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                GraphicsStringConsts.bookingEstimateLabel(pairsSummary),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                grandTotalFormatted,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: GraphicsColorConsts.warningAmber,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GraphicsColorConsts.accentEmerald,
              foregroundColor: GraphicsColorConsts.backgroundDark,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12.0,
              ),
            ),
            onPressed: isSaving ? null : onSaveBill,
            icon: isSaving
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: GraphicsColorConsts.backgroundDark,
                    ),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 18.0),
            label: Text(
              isSaving
                  ? GraphicsStringConsts.savingBookingCta
                  : GraphicsStringConsts.confirmBookingCta,
              style: theme.textTheme.labelLarge?.copyWith(
                color: GraphicsColorConsts.backgroundDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
