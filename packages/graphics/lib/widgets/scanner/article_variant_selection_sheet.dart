import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';

class ArticleVariantBookingItem {
  final String itemCode;
  final String color;
  final String size;
  final double rate;
  final double mrp;
  final String company;
  final String productName;
  bool isSelected;
  int qtyPairs;

  ArticleVariantBookingItem({
    required this.itemCode,
    required this.color,
    required this.size,
    required this.rate,
    required this.mrp,
    required this.company,
    required this.productName,
    this.isSelected = true,
    this.qtyPairs = 12,
  });
}

class ArticleVariantSelectionSheet extends StatefulWidget {
  final String brand;
  final String articleNo;
  final List<ArticleVariantBookingItem> initialVariants;

  const ArticleVariantSelectionSheet({
    super.key,
    required this.brand,
    required this.articleNo,
    required this.initialVariants,
  });

  static Future<List<ArticleVariantBookingItem>?> show({
    required BuildContext context,
    required String brand,
    required String articleNo,
    required List<ArticleVariantBookingItem> initialVariants,
  }) {
    return showModalBottomSheet<List<ArticleVariantBookingItem>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ArticleVariantSelectionSheet(
            brand: brand,
            articleNo: articleNo,
            initialVariants: initialVariants,
          ),
        );
      },
    );
  }

  @override
  State<ArticleVariantSelectionSheet> createState() =>
      _ArticleVariantSelectionSheetState();
}

class _ArticleVariantSelectionSheetState
    extends State<ArticleVariantSelectionSheet> {
  late List<ArticleVariantBookingItem> _items;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _items = widget.initialVariants
        .map(
          (item) => ArticleVariantBookingItem(
            itemCode: item.itemCode,
            color: item.color,
            size: item.size,
            rate: item.rate,
            mrp: item.mrp,
            company: item.company,
            productName: item.productName,
            isSelected: item.isSelected,
            qtyPairs: item.qtyPairs > 0 ? item.qtyPairs : 12,
          ),
        )
        .toList();

    _controllers = _items
        .map(
          (item) => TextEditingController(text: item.qtyPairs.toString()),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalSelectedPairs {
    var sum = 0;
    for (final item in _items) {
      if (item.isSelected) {
        sum += item.qtyPairs;
      }
    }
    return sum;
  }

  double get _totalEstimatedAmount {
    var sum = 0.0;
    for (final item in _items) {
      if (item.isSelected) {
        final effRate = item.rate > 0 ? item.rate : item.mrp;
        sum += item.qtyPairs * effRate;
      }
    }
    return sum;
  }

  void _onQtyChanged(int index, int newQty) {
    final validQty = newQty > 0 ? newQty : 1;
    setState(() {
      _items[index].qtyPairs = validQty;
      _controllers[index].text = validQty.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? GraphicsColorConsts.surfaceSlate
        : GraphicsColorConsts.cardLight;
    final borderColor = isDark
        ? GraphicsColorConsts.borderSlate
        : GraphicsColorConsts.borderLight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 10.0),
          Center(
            child: Container(
              width: 44.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: GraphicsColorConsts.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: GraphicsColorConsts.primaryTeal
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: GraphicsColorConsts.primaryTeal
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      widget.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: GraphicsColorConsts.primaryTeal,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Article: ${widget.articleNo}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Select colors & sizes to book',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: GraphicsColorConsts.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final item = _items[index];
                final effRate = item.rate > 0 ? item.rate : item.mrp;
                final controller = _controllers[index];

                return Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: item.isSelected
                        ? GraphicsColorConsts.primaryTeal.withValues(alpha: 0.08)
                        : (isDark
                            ? GraphicsColorConsts.cardSlate
                            : GraphicsColorConsts.surfaceLight),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: item.isSelected
                          ? GraphicsColorConsts.primaryTeal
                          : borderColor,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: item.isSelected,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        activeColor: GraphicsColorConsts.primaryTeal,
                        onChanged: (val) {
                          setState(() {
                            item.isSelected = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 4.0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                if (item.color.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: GraphicsColorConsts.primaryTeal
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      item.color,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: GraphicsColorConsts.primaryTeal,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                if (item.size.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                      vertical: 2.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? GraphicsColorConsts.surfaceSlate
                                          : GraphicsColorConsts.backgroundLight,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: isDark
                                            ? GraphicsColorConsts.borderSlate
                                            : GraphicsColorConsts.borderLight,
                                      ),
                                    ),
                                    child: Text(
                                      'Size: ${item.size}',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: isDark
                                            ? GraphicsColorConsts.textPrimary
                                            : GraphicsColorConsts.surfaceSlate,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '₹${effRate.toStringAsFixed(2)} / Pair',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: GraphicsColorConsts.primaryTeal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            iconSize: 20.0,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32.0,
                              minHeight: 32.0,
                            ),
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: item.isSelected
                                ? () => _onQtyChanged(index, item.qtyPairs - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 52.0,
                            child: TextField(
                              controller: controller,
                              enabled: item.isSelected,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                  vertical: 6.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onChanged: (text) {
                                final parsed = int.tryParse(text);
                                if (parsed != null && parsed > 0) {
                                  _items[index].qtyPairs = parsed;
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          IconButton(
                            iconSize: 20.0,
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32.0,
                              minHeight: 32.0,
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: item.isSelected
                                ? () => _onQtyChanged(index, item.qtyPairs + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$_totalSelectedPairs Pairs Selected',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: GraphicsColorConsts.primaryTeal,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Total: ₹${_totalEstimatedAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: GraphicsColorConsts.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GraphicsColorConsts.primaryTeal,
                    foregroundColor: GraphicsColorConsts.backgroundDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _totalSelectedPairs > 0
                      ? () {
                          final selected =
                              _items.where((i) => i.isSelected).toList();
                          Navigator.of(context).pop(selected);
                        }
                      : null,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                    'Submit Order',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: GraphicsColorConsts.backgroundDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
