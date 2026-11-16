import 'booking_scheme_entity.dart';

class SchemeProgressEntity {
  const SchemeProgressEntity({
    required this.currentPairs,
    this.achievedScheme,
    this.nextScheme,
    this.pairsNeededForNext = 0,
    this.progressFraction = 0.0,
    this.isHighestUnlocked = false,
  });

  factory SchemeProgressEntity.calculate({
    required int currentPairs,
    required List<BookingSchemeEntity> availableSchemes,
  }) {
    if (availableSchemes.isEmpty) {
      return SchemeProgressEntity(currentPairs: currentPairs);
    }

    final activeSchemes = availableSchemes.where((s) => s.isActive).toList()
      ..sort((a, b) => a.minPairs.compareTo(b.minPairs));

    if (activeSchemes.isEmpty) {
      return SchemeProgressEntity(currentPairs: currentPairs);
    }

    BookingSchemeEntity? achieved;
    BookingSchemeEntity? next;

    for (final scheme in activeSchemes) {
      if (currentPairs >= scheme.minPairs) {
        achieved = scheme;
      } else {
        next = scheme;
        break;
      }
    }

    if (next == null) {
      return SchemeProgressEntity(
        currentPairs: currentPairs,
        achievedScheme: achieved,
        nextScheme: null,
        pairsNeededForNext: 0,
        progressFraction: 1.0,
        isHighestUnlocked: true,
      );
    }

    final targetPairs = next.minPairs;
    final needed = targetPairs > currentPairs ? targetPairs - currentPairs : 0;
    final progress = targetPairs > 0 ? (currentPairs / targetPairs).clamp(0.0, 1.0) : 0.0;

    return SchemeProgressEntity(
      currentPairs: currentPairs,
      achievedScheme: achieved,
      nextScheme: next,
      pairsNeededForNext: needed,
      progressFraction: progress,
      isHighestUnlocked: false,
    );
  }

  final int currentPairs;
  final BookingSchemeEntity? achievedScheme;
  final BookingSchemeEntity? nextScheme;
  final int pairsNeededForNext;
  final double progressFraction;
  final bool isHighestUnlocked;

  String getNudgeText() {
    if (isHighestUnlocked) {
      final name = achievedScheme?.schemeName ?? 'Highest Tier';
      return '🎉 Congratulations! You have achieved $name!';
    }
    final next = nextScheme;
    if (next != null) {
      return '🚀 Only $pairsNeededForNext pairs left to unlock ${next.schemeName}!';
    }
    return 'Book pairs to unlock exciting event rewards!';
  }
}
