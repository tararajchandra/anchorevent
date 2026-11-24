import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:graphics/graphics.dart';
import 'package:reactiv/reactiv.dart';

import '../../main_shell/controller/marg_app.controller.dart';

class SchemesView extends StatelessWidget {
  const SchemesView({
    required this.controller,
    super.key,
  });

  final MargAppController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ReactiveBuilder<List<BookingSchemeEntity>>(
      reactiv: controller.bookingSchemes,
      builder: (context, schemes) {
        return ReactiveBuilder<SchemeProgressEntity>(
          reactiv: controller.schemeProgress,
          builder: (context, progress) {
            final totalPairs = progress.currentPairs;

            return ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    GraphicsStringConsts.schemesTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    GraphicsStringConsts.schemesSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(160),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Your Booked Total:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$totalPairs Pairs',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ...schemes.map((scheme) {
              final isUnlocked = totalPairs >= scheme.minPairs;
              final fraction = scheme.minPairs > 0
                  ? (totalPairs / scheme.minPairs).clamp(0.0, 1.0)
                  : 0.0;
              final pairsLeft = scheme.minPairs > totalPairs
                  ? scheme.minPairs - totalPairs
                  : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? GraphicsColorConsts.accentEmerald.withAlpha(isDark ? 25 : 15)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: isUnlocked
                        ? GraphicsColorConsts.accentEmerald
                        : theme.dividerColor,
                    width: isUnlocked ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          scheme.schemeName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isUnlocked
                                ? GraphicsColorConsts.accentEmerald
                                : null,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? GraphicsColorConsts.accentEmerald
                                : theme.colorScheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            isUnlocked
                                ? GraphicsStringConsts.unlockedBadge
                                : GraphicsStringConsts.inProgressBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isUnlocked
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      'Target: ${scheme.minPairs} Pairs',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Reward: ${scheme.rewardDescription}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(170),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 7.0,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked
                              ? GraphicsColorConsts.accentEmerald
                              : GraphicsColorConsts.warningAmber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          isUnlocked
                              ? 'Reward achieved!'
                              : '$pairsLeft more pairs needed',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUnlocked
                                ? GraphicsColorConsts.accentEmerald
                                : GraphicsColorConsts.warningAmber,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$totalPairs / ${scheme.minPairs} Prs',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.textTheme.bodySmall?.color?.withAlpha(140),
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
      },
    );
  }
}
