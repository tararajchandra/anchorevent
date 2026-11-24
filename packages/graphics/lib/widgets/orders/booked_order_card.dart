import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class BookedOrderLineData {
  final String productName;
  final String company;
  final int qtyPairs;
  final String rateFormatted;
  final String mrpFormatted;
  final String lineTotalFormatted;

  const BookedOrderLineData({
    required this.productName,
    required this.company,
    required this.qtyPairs,
    required this.rateFormatted,
    required this.mrpFormatted,
    required this.lineTotalFormatted,
  });
}

class BookedOrderCard extends StatelessWidget {
  final String billNo;
  final String billDate;
  final String createdTime;
  final int totalPairs;
  final String totalAmountFormatted;
  final List<BookedOrderLineData> items;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPdfSlip;
  final VoidCallback onShareWhatsApp;

  const BookedOrderCard({
    super.key,
    required this.billNo,
    required this.billDate,
    required this.createdTime,
    required this.totalPairs,
    required this.totalAmountFormatted,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.onPdfSlip,
    required this.onShareWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateTimeLabel = billDate.isNotEmpty
        ? '$billDate • $createdTime'
        : createdTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18.0),
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? GraphicsColorConsts.cardSlate.withValues(alpha: 0.6)
                  : GraphicsColorConsts.backgroundLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(17.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              billNo,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontFamily: 'monospace',
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: GraphicsColorConsts.accentEmerald
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              GraphicsStringConsts.confirmedStatusBadge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w800,
                                color: GraphicsColorConsts.accentEmerald,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        '$dateTimeLabel  •  '
                        '${GraphicsStringConsts.orderItemsCountSummary(
                          items.length,
                          totalPairs,
                        )}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              theme.textTheme.bodySmall?.color?.withAlpha(155),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      totalAmountFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: GraphicsColorConsts.warningAmber,
                      ),
                    ),
                    Text(
                      '$totalPairs Pairs',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 6.0),
            child: Column(
              children: List<Widget>.generate(items.length, (idx) {
                final item = items[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _OrderLineRow(item: item, isDark: isDark),
                );
              }),
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16.0),
                        label: const Text(GraphicsStringConsts.editOrderLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16.0,
                        ),
                        label:
                            const Text(GraphicsStringConsts.deleteOrderLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GraphicsColorConsts.dangerRed,
                          side: const BorderSide(
                            color: GraphicsColorConsts.dangerRed,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPdfSlip,
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 16.0,
                        ),
                        label: const Text(GraphicsStringConsts.pdfSlipLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              theme.textTheme.bodyMedium?.color,
                          side: BorderSide(color: theme.dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onShareWhatsApp,
                        icon: const Icon(Icons.share_rounded, size: 16.0),
                        label: const Text(GraphicsStringConsts.whatsAppLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GraphicsColorConsts.accentEmerald,
                          foregroundColor: Colors.white,
                          elevation: 0.0,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          ),
        ],
      ),
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  final BookedOrderLineData item;
  final bool isDark;

  const _OrderLineRow({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3.0),
              Wrap(
                spacing: 6.0,
                runSpacing: 3.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  if (item.company.isNotEmpty)
                    Text(
                      item.company,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (item.mrpFormatted.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        color: GraphicsColorConsts.accentCrimson
                            .withValues(alpha: isDark ? 0.22 : 0.10),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        GraphicsStringConsts.mrpBadgeText(item.mrpFormatted),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10.0,
                          color: isDark
                              ? GraphicsColorConsts.dangerRed
                              : GraphicsColorConsts.accentCrimson,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              item.lineTotalFormatted,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: GraphicsColorConsts.primaryTeal,
              ),
            ),
            Text(
              '${item.qtyPairs} Prs × ${item.rateFormatted}',
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.textTheme.bodySmall?.color?.withAlpha(155),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
