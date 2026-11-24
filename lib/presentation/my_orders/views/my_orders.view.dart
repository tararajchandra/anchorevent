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

  Future<void> _handleEditOrder(
    BuildContext context,
    SalesBillEntity bill,
  ) async {
    final initialItems = bill.items
        .map(
          (item) => OrderEditItemData(
            itemCode: item.itemCode,
            productName: item.productName,
            company: item.company,
            rate: item.rate,
            mrp: item.mrp,
            qtyPairs: item.qtyPairs,
          ),
        )
        .toList();

    final edited = await OrderEditSheet.show(
      context: context,
      billNo: bill.billNo,
      initialItems: initialItems,
    );
    if (edited == null || !context.mounted) {
      return;
    }

    final wasDeleted = edited.isEmpty;
    final ok = await controller.updateSavedBillItems(
      bill: bill,
      editedItems: edited,
    );
    if (ok && context.mounted) {
      AppSnackBar.showSuccess(
        context,
        wasDeleted
            ? GraphicsStringConsts.orderDeletedSuccess(bill.billNo)
            : GraphicsStringConsts.orderUpdatedSuccess(bill.billNo),
      );
    }
  }

  Future<void> _handleDeleteOrder(
    BuildContext context,
    SalesBillEntity bill,
  ) async {
    final confirmed = await ConfirmActionDialog.show(
      context: context,
      title: GraphicsStringConsts.deleteOrderDialogTitle,
      message: GraphicsStringConsts.deleteOrderDialogContent(bill.billNo),
      confirmLabel: GraphicsStringConsts.deleteOrderConfirmLabel,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final ok = await controller.deleteSavedBill(bill);
    if (ok && context.mounted) {
      AppSnackBar.showSuccess(
        context,
        GraphicsStringConsts.orderDeletedSuccess(bill.billNo),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReactiveBuilder<List<SalesBillEntity>>(
      reactiv: controller.savedBills,
      builder: (context, bills) {
        if (bills.isEmpty) {
          return OrdersEmptyStateCard(
            onStartScanning: () => controller.switchTab(AppTabEnum.scan),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            ReactiveBuilder<SchemeProgressEntity>(
              reactiv: controller.schemeProgress,
              builder: (context, progress) {
                final achieved = progress.achievedScheme;
                final next = progress.nextScheme;
                final bannerText = achieved != null
                    ? GraphicsStringConsts.qualifiedSchemeBanner(
                        achieved.schemeName,
                        achieved.rewardDescription,
                      )
                    : GraphicsStringConsts.nextSchemeTargetBanner(
                        progress.pairsNeededForNext,
                        next?.schemeName ?? 'Next Reward',
                      );

                return OrdersSummaryHeaderCard(
                  ordersCount: bills.length,
                  totalPairs: controller.todayTotalPairs,
                  totalValueFormatted:
                      CurrencyUtils.formatInr(controller.todayTotalSales),
                  schemeBannerText: bannerText,
                  schemeProgressFraction: progress.progressFraction,
                  isSchemeAchieved: achieved != null,
                  onSchemeTap: () => controller.switchTab(AppTabEnum.schemes),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Text(
              GraphicsStringConsts.ordersBreakdownTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.textTheme.bodySmall?.color?.withAlpha(160),
              ),
            ),
            const SizedBox(height: 10.0),
            ...bills.map((bill) {
              final lineItems = bill.items.map((item) {
                final displayMrp = item.mrp > 0 ? item.mrp : item.rate;
                return BookedOrderLineData(
                  productName: item.productName,
                  company: item.company,
                  qtyPairs: item.qtyPairs,
                  rateFormatted: CurrencyUtils.formatInrCompact(item.rate),
                  mrpFormatted: CurrencyUtils.formatInrCompact(displayMrp),
                  lineTotalFormatted: CurrencyUtils.formatInr(item.lineAmount),
                );
              }).toList();

              return BookedOrderCard(
                billNo: bill.billNo,
                billDate: bill.billDate,
                createdTime: bill.createdTime,
                totalPairs: bill.totalPairs,
                totalAmountFormatted: CurrencyUtils.formatInr(bill.totalAmount),
                items: lineItems,
                onEdit: () => _handleEditOrder(context, bill),
                onDelete: () => _handleDeleteOrder(context, bill),
                onPdfSlip: () {
                  AppSnackBar.showSuccess(
                    context,
                    GraphicsStringConsts.bookingSlipGeneratedSuccess(
                      bill.billNo,
                    ),
                  );
                },
                onShareWhatsApp: () {
                  AppSnackBar.showSuccess(
                    context,
                    GraphicsStringConsts.bookingSummarySharedSuccess,
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }
}
