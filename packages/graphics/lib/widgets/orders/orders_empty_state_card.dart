import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_string_consts.dart';

class OrdersEmptyStateCard extends StatelessWidget {
  final VoidCallback onStartScanning;

  const OrdersEmptyStateCard({
    super.key,
    required this.onStartScanning,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 76.0,
              height: 76.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 38.0,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              GraphicsStringConsts.noBookingsYetTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              GraphicsStringConsts.noBookingsYetSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: onStartScanning,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18.0),
              label: const Text(GraphicsStringConsts.startScanningSamplesCta),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
