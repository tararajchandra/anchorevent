import '../../../utils/enums/scheme_reward_type_enum.dart';

class BookingSchemeEntity {
  const BookingSchemeEntity({
    required this.id,
    required this.schemeName,
    required this.minPairs,
    required this.rewardDescription,
    required this.rewardType,
    this.discountPercent = 0.0,
    this.isActive = true,
  });

  factory BookingSchemeEntity.fromJson(Map<String, dynamic> json) {
    return BookingSchemeEntity(
      id: json['id']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      minPairs: int.tryParse(json['min_pairs']?.toString() ?? '0') ?? 0,
      rewardDescription: json['reward_description']?.toString() ?? '',
      rewardType: SchemeRewardTypeEnum.fromString(json['reward_type']?.toString()),
      discountPercent: double.tryParse(json['discount_percent']?.toString() ?? '0.0') ?? 0.0,
      isActive: json['is_active'] == true || json['is_active']?.toString() == 'true',
    );
  }

  final String id;
  final String schemeName;
  final int minPairs;
  final String rewardDescription;
  final SchemeRewardTypeEnum rewardType;
  final double discountPercent;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheme_name': schemeName,
      'min_pairs': minPairs,
      'reward_description': rewardDescription,
      'reward_type': rewardType.name,
      'discount_percent': discountPercent,
      'is_active': isActive,
    };
  }
}
