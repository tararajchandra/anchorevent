import 'package:flutter/material.dart';

import '../../graphics_consts/graphics_color_consts.dart';
import '../../graphics_consts/graphics_string_consts.dart';

class OrderEditItemData {
  final String itemCode;
  final String productName;
  final String company;
  final double rate;
  final double mrp;
  int qtyPairs;

  OrderEditItemData({
    required this.itemCode,
    required this.productName,
    required this.company,
    required this.rate,
    required this.mrp,
    required this.qtyPairs,
  });

  double get lineTotal => qtyPairs * rate;
}

class OrderEditSheet extends StatefulWidget {
  final String billNo;
  final List<OrderEditItemData> initialItems;

  const OrderEditSheet({
    super.key,
    required this.billNo,
    required this.initialItems,
  });

  static Future<List<OrderEditItemData>?> show({
    required BuildContext context,
    required String billNo,
    required List<OrderEditItemData> initialItems,
  }) {
    return showModalBottomSheet<List<OrderEditItemData>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: OrderEditSheet(
            billNo: billNo,
            initialItems: initialItems,
          ),
        );
      },
    );
  }

  @override
  State<OrderEditSheet> createState() => _OrderEditSheetState();
}

class _OrderEditSheetState extends State<OrderEditSheet> {
  late List<OrderEditItemData> _items;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems
        .map(
          (item) => OrderEditItemData(
            itemCode: item.itemCode,
            productName: item.productName,
            company: item.company,
            rate: item.rate,
            mrp: item.mrp,
            qtyPairs: item.qtyPairs > 0 ? item.qtyPairs : 1,
          ),
        )
        .toList();
    _controllers = _items
        .map((item) => TextEditingController(text: item.qtyPairs.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalPairs {
    var sum = 0;
    for (final item in _items) {
      sum += item.qtyPairs;
    }
    return sum;
  }

  double get _totalAmount {
    var sum = 0.0;
    for (final item in _items) {
      sum += item.lineTotal;
    }
    return sum;
  }

  void _updateQty(int index, int newQty) {
    if (newQty <= 0) {
      _removeItem(index);
      return;
    }
    setState(() {
      _items[index].qtyPairs = newQty;
      _controllers[index].text = newQty.toString();
    });
  }

  void _removeItem(int index) {
    if (index < 0 || index >= _items.length) {
      return;
    }
    setState(() {
      _items.removeAt(index);
      final removed = _controllers.removeAt(index);
      removed.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? GraphicsColorConsts.surfaceSlate
        : GraphicsColorConsts.cardLight;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
        border: Border.all(color: theme.dividerColor),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${GraphicsStringConsts.editOrderSheetTitle} '
                        '• ${widget.billNo}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        GraphicsStringConsts.editOrderSheetSubtitle,
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
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 40.0,
                    color: GraphicsColorConsts.dangerRed,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    GraphicsStringConsts.removeAllItemsWarning,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: GraphicsColorConsts.dangerRed,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                shrinkWrap: true,
                itemCount: _items.length,
                separatorBuilder: (context, idx) =>
                    const SizedBox(height: 10.0),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final displayMrp = item.mrp > 0 ? item.mrp : item.rate;
                  final mrpStr = displayMrp % 1 == 0
                      ? displayMrp.toStringAsFixed(0)
                      : displayMrp.toStringAsFixed(2);

                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? GraphicsColorConsts.cardSlate
                          : GraphicsColorConsts.backgroundLight,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item.productName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: GraphicsColorConsts
                                              .accentCrimson
                                              .withValues(
                                            alpha: isDark ? 0.22 : 0.10,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          'MRP ₹$mrpStr',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: isDark
                                                ? GraphicsColorConsts.dangerRed
                                                : GraphicsColorConsts
                                                    .accentCrimson,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${item.rate.toStringAsFixed(2)} / Pair',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color:
                                              GraphicsColorConsts.primaryTeal,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(index),
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 32.0,
                                minHeight: 32.0,
                              ),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20.0,
                                color: GraphicsColorConsts.dangerRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  iconSize: 20.0,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 32.0,
                                    minHeight: 32.0,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                  ),
                                  onPressed: () =>
                                      _updateQty(index, item.qtyPairs - 1),
                                ),
                                SizedBox(
                                  width: 54.0,
                                  child: TextField(
                                    controller: _controllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 6.0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onChanged: (text) {
                                      final parsed = int.tryParse(text);
                                      if (parsed != null && parsed > 0) {
                                        setState(() {
                                          _items[index].qtyPairs = parsed;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  iconSize: 20.0,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  constraints: const BoxConstraints(
                                    minWidth: 32.0,
                                    minHeight: 32.0,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () =>
                                      _updateQty(index, item.qtyPairs + 1),
                                ),
                              ],
                            ),
                            Text(
                              '₹${item.lineTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: GraphicsColorConsts.primaryTeal,
                                fontWeight: FontWeight.w800,
                              ),
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$_totalPairs Pairs Total',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: GraphicsColorConsts.primaryTeal,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Total: ₹${_totalAmount.toStringAsFixed(2)}',
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
                      backgroundColor: _items.isEmpty
                          ? GraphicsColorConsts.dangerRed
                          : GraphicsColorConsts.primaryTeal,
                      foregroundColor: _items.isEmpty
                          ? Colors.white
                          : GraphicsColorConsts.backgroundDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(_items),
                    icon: Icon(
                      _items.isEmpty
                          ? Icons.delete_forever_rounded
                          : Icons.check_circle_rounded,
                    ),
                    label: Text(
                      _items.isEmpty
                          ? GraphicsStringConsts.removeOrderCta
                          : GraphicsStringConsts.saveOrderChangesCta,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _items.isEmpty
                            ? Colors.white
                            : GraphicsColorConsts.backgroundDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
