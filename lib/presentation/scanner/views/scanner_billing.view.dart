import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';

import '../../main_shell/controller/marg_app.controller.dart';

class ScannerBillingView extends StatelessWidget {
  final MargAppController controller;

  const ScannerBillingView({
    super.key,
    required this.controller,
  });

  Future<void> _handleBarcode(BuildContext context, String rawBarcode) async {
    if (!controller.canProcessBarcodeScan()) {
      return;
    }
    var artMapping = controller.lookupArticleMapping(rawBarcode);
    if (artMapping == null &&
        rawBarcode.trim().toUpperCase().startsWith('MARG_ART:')) {
      artMapping = await controller.syncAndLookupArticleMapping(rawBarcode);
      if (!context.mounted || !controller.canProcessBarcodeScan()) {
        return;
      }
    }
    final resolvedMapping = artMapping;
    if (resolvedMapping != null && resolvedMapping.variants.isNotEmpty) {
      controller.beginArticleSheetScan();
      controller.playScanBeep();
      try {
        final initialList = resolvedMapping.variants
            .map(
              (v) => ArticleVariantBookingItem(
                itemCode: v.itemCode,
                color: v.color,
                size: v.size,
                rate: v.rate,
                mrp: v.mrp,
                company:
                    v.company.isNotEmpty ? v.company : resolvedMapping.brand,
                productName: v.productName,
                isSelected: true,
                qtyPairs: 12,
              ),
            )
            .toList();

        final selected = await ArticleVariantSelectionSheet.show(
          context: context,
          brand: resolvedMapping.brand,
          articleNo: resolvedMapping.articleNo,
          initialVariants: initialList,
        );

        if (selected != null && selected.isNotEmpty && context.mounted) {
          controller.addArticleVariantsToCart(selected);
          AppSnackBar.showSuccess(
            context,
            GraphicsStringConsts.articleVariantsAddedSuccess(
              selected.length,
              resolvedMapping.articleNo,
            ),
          );
        }
      } finally {
        controller.endArticleSheetScan();
      }
    } else {
      controller.handleCameraBarcodeDetected(rawBarcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      children: <Widget>[
        ReactiveBuilder<bool>(
          reactiv: controller.isLiveCameraActive,
          builder: (context, isCameraOn) {
            return ReactiveBuilder<FootwearItemEntity?>(
              reactiv: controller.activeScannedItem,
              builder: (context, scannedItem) {
                return ReactiveBuilder<bool>(
                  reactiv: controller.isArticleSheetOpen,
                  builder: (context, isSheetOpen) {
                    final label = scannedItem != null
                        ? '${scannedItem.company} • ${scannedItem.product}'
                        : '';
                    return ScannerViewfinderCard(
                      isCameraActive: isCameraOn,
                      isShutterClosed: scannedItem != null || isSheetOpen,
                      scannedProductLabel: label,
                      onToggleCamera: () =>
                          controller.isLiveCameraActive.value = !isCameraOn,
                      onBarcodeDetected: (barcode) =>
                          _handleBarcode(context, barcode),
                      onSimulateKnownScan: controller.simulateKnownBarcodeScan,
                      onSimulateUnlinkedScan:
                          controller.simulateUnlinkedBarcodeScan,
                      onRescanTap: controller.clearActiveScannedItem,
                      knownBtnLabel: GraphicsStringConsts.scanKnownSampleBtn,
                      unlinkedBtnLabel:
                          GraphicsStringConsts.scanUnlinkedSampleBtn,
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 12.0),
        ReactiveBuilder<FootwearItemEntity?>(
          reactiv: controller.activeScannedItem,
          builder: (context, item) {
            if (item == null) {
              return const SizedBox.shrink();
            }
            return ReactiveBuilder<int>(
              reactiv: controller.scannedPairQty,
              builder: (context, currentQty) {
                return ScannedItemStepperCard(
                  brand: item.company,
                  itemCode: item.code,
                  productTitle: item.product,
                  categoryAndStock:
                      '${item.category} • Stock: ${item.closingStock} PAIR',
                  rateFormatted: CurrencyUtils.formatInr(item.effectiveRate),
                  mrpFormatted: CurrencyUtils.formatInrCompact(item.mrp),
                  currentQty: currentQty,
                  onQtyChanged: (val) => controller.scannedPairQty.value = val,
                  onAddToCart: controller.addActiveScannedItemToCart,
                );
              },
            );
          },
        ),
        const SizedBox(height: 14.0),
        ReactiveBuilder<List<BillItemEntity>>(
          reactiv: controller.cartItems,
          builder: (context, items) {
            final summaryLabel = GraphicsStringConsts.cartCountSummary(
              items.length,
              controller.cartTotalPairs,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      GraphicsStringConsts.currentCartHeader,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: GraphicsColorConsts.textMuted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      summaryLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: GraphicsColorConsts.primaryTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      GraphicsStringConsts.emptyCartHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: GraphicsColorConsts.textMuted,
                      ),
                    ),
                  )
                else
                  ...List<Widget>.generate(items.length, (idx) {
                    final cartItem = items[idx];
                    final displayMrp =
                        cartItem.mrp > 0 ? cartItem.mrp : cartItem.rate;
                    return CartItemRowCard(
                      productName: cartItem.productName,
                      itemCodeAndRate:
                          'Code: ${cartItem.itemCode} • '
                          '${CurrencyUtils.formatInr(cartItem.rate)} / Pair',
                      mrpFormatted: CurrencyUtils.formatInrCompact(displayMrp),
                      qtyPairs: cartItem.qtyPairs,
                      onQtyChanged: (newQty) =>
                          controller.updateCartItemQtyAt(idx, newQty),
                      lineTotalFormatted: CurrencyUtils.formatInr(
                        cartItem.lineAmount,
                      ),
                      onRemove: () => controller.removeCartItemAt(idx),
                    );
                  }),
                const SizedBox(height: 10.0),
                ReactiveBuilder<bool>(
                  reactiv: controller.isSavingBill,
                  builder: (context, isSaving) {
                    return BillCheckoutBottomBar(
                      grandTotalFormatted: CurrencyUtils.formatInr(
                        controller.cartGrandTotal,
                      ),
                      pairsSummary: CurrencyUtils.formatPairsCount(
                        controller.cartTotalPairs,
                      ),
                      isSaving: isSaving,
                      onSaveBill: () async {
                        final saved =
                            await controller.finalizeAndSaveCurrentBill();
                        if (saved != null && context.mounted) {
                          AppSnackBar.showSuccess(
                            context,
                            GraphicsStringConsts.bookingSavedSuccess(
                              saved.billNo,
                              saved.partyName,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
