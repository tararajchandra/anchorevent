import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';

import '../../main_shell/controller/marg_app.controller.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({
    required this.controller,
    super.key,
  });

  final MargAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveBuilder<List<SalesBillEntity>>(
      reactiv: controller.savedBills,
      builder: (context, bills) {
        if (bills.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 36.0,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    GraphicsStringConsts.noBookingsYetTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                    onPressed: () => controller.switchTab(AppTabEnum.scan),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18.0),
                    label: const Text(GraphicsStringConsts.startScanningSamplesCta),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: theme.dividerColor),
                boxShadow: <BoxShadow>[
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 10.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        GraphicsStringConsts.totalBookingsSummaryTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: GraphicsColorConsts.accentEmerald.withAlpha(isDark ? 40 : 25),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: GraphicsColorConsts.accentEmerald),
                        ),
                        child: Text(
                          GraphicsStringConsts.ordersConfirmedBadge(bills.length),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: GraphicsColorConsts.accentEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildSummaryTile(
                          context,
                          label: 'Total Pairs',
                          value: '${controller.todayTotalPairs} Prs',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _buildSummaryTile(
                          context,
                          label: 'Booking Value',
                          value: CurrencyUtils.formatInr(controller.todayTotalSales),
                          color: GraphicsColorConsts.warningAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  ReactiveBuilder<SchemeProgressEntity>(
                    reactiv: controller.schemeProgress,
                    builder: (context, progress) {
                      final achieved = progress.achievedScheme;
                      final text = achieved != null
                          ? '🎉 Qualified: ${achieved.schemeName} (${achieved.rewardDescription})'
                          : '🎯 Next Target: ${progress.pairsNeededForNext} more pairs for next reward!';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: GraphicsColorConsts.warningAmber.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: GraphicsColorConsts.warningAmber),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.stars_rounded,
                              size: 18.0,
                              color: GraphicsColorConsts.warningAmber,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                text,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              GraphicsStringConsts.ordersBreakdownTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
            ),
            const SizedBox(height: 8.0),
            ...bills.map((bill) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                bill.billNo,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              bill.createdTime,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withAlpha(140),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyUtils.formatInr(bill.totalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: GraphicsColorConsts.warningAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Items: ${bill.items.length} Articles • ${bill.totalPairs} Pairs Total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    ...bill.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '• ${item.productName} (${item.company})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                                ),
                              ),
                            ),
                            Text(
                              '${item.qtyPairs} Prs @ ₹${item.rate.toStringAsFixed(0)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              AppSnackBar.showSuccess(
                                context,
                                GraphicsStringConsts.bookingSlipGeneratedSuccess(bill.billNo),
                              );
                            },
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16.0),
                            label: const Text(GraphicsStringConsts.pdfSlipLabel),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AppSnackBar.showSuccess(
                                context,
                                GraphicsStringConsts.bookingSummarySharedSuccess,
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 16.0),
                            label: const Text(GraphicsStringConsts.whatsAppLabel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GraphicsColorConsts.accentEmerald,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDark ? GraphicsColorConsts.cardSlate : GraphicsColorConsts.backgroundLight,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(150),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
