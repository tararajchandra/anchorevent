import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';

import '../../main_shell/controller/marg_app.controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    required this.controller,
    super.key,
  });

  final MargAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReactiveBuilder<DealerProfileEntity>(
      reactiv: controller.dealerProfile,
      builder: (context, profile) {
        final displayShop = profile.shopName.isNotEmpty
            ? profile.shopName
            : 'MY SHOE STORE';
        final displaySubtitle = profile.phone.isNotEmpty
            ? '${profile.phone} • ${profile.address}'
            : 'Seasonal Shoe Booking';

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            ReactiveBuilder<List<SalesBillEntity>>(
              reactiv: controller.savedBills,
              builder: (context, bills) {
                return ShopSummaryHeaderCard(
                  shopName: displayShop,
                  licenseSubtitle: displaySubtitle,
                  billCount: bills.length,
                  totalPairs: controller.todayTotalPairs,
                  totalSalesFormatted: CurrencyUtils.formatInrCompact(
                    controller.todayTotalSales,
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),
            ReactiveBuilder<SchemeProgressEntity>(
              reactiv: controller.schemeProgress,
              builder: (context, progress) {
                final next = progress.nextScheme;
                final achieved = progress.achievedScheme;
                final schemeTitle =
                    next?.schemeName ?? achieved?.schemeName ?? 'Booking Scheme';
                final target = next?.minPairs ?? achieved?.minPairs ?? 100;
                final badge = next?.rewardDescription ?? achieved?.rewardDescription ?? '';

                return SchemeProgressBannerCard(
                  schemeName: schemeTitle,
                  currentPairs: progress.currentPairs,
                  targetPairs: target,
                  nudgeText: progress.getNudgeText(),
                  progressFraction: progress.progressFraction,
                  rewardBadgeText: badge,
                  onTap: () => controller.switchTab(AppTabEnum.schemes),
                );
              },
            ),
            const SizedBox(height: 14.0),
            PrimaryGradientButton(
              label: GraphicsStringConsts.startNewBookingCta,
              icon: Icons.qr_code_scanner_rounded,
              onPressed: () => controller.switchTab(AppTabEnum.scan),
            ),
            const SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  GraphicsStringConsts.todaysBookingsTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                InkWell(
                  onTap: () => controller.switchTab(AppTabEnum.myOrders),
                  child: Text(
                    GraphicsStringConsts.viewAllExportCta,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            ReactiveBuilder<List<SalesBillEntity>>(
              reactiv: controller.savedBills,
              builder: (context, bills) {
                if (bills.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 42.0,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(140),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          GraphicsStringConsts.noBookingsTodayTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          GraphicsStringConsts.noBookingsTodaySubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: bills.map((bill) {
                    return RecentBillRowCard(
                      partyName: bill.partyName,
                      billNo: bill.billNo,
                      subtitleText:
                          'Booked: ${bill.totalPairs} Pairs '
                          '(${bill.brandsSummary}) • ${bill.createdTime}',
                      amountText: CurrencyUtils.formatInr(bill.totalAmount),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
