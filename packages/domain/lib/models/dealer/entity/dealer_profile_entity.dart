class DealerProfileEntity {
  const DealerProfileEntity({
    required this.phone,
    required this.shopName,
    required this.address,
    this.dealerCode = '',
    this.routeDay = '',
    this.pin = '',
    this.isExistingMargDealer = false,
    this.isLoggedIn = false,
  });

  factory DealerProfileEntity.empty() {
    return const DealerProfileEntity(
      phone: '',
      shopName: '',
      address: '',
      dealerCode: '',
      routeDay: '',
      pin: '',
      isExistingMargDealer: false,
      isLoggedIn: false,
    );
  }

  factory DealerProfileEntity.fromJson(Map<String, dynamic> json) {
    return DealerProfileEntity(
      phone: json['phone']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      dealerCode: json['dealer_code']?.toString() ?? '',
      routeDay: json['route_day']?.toString() ?? '',
      pin: json['pin']?.toString() ?? '',
      isExistingMargDealer: json['is_existing_marg_dealer'] == true,
      isLoggedIn: json['is_logged_in'] == true,
    );
  }

  final String phone;
  final String shopName;
  final String address;
  final String dealerCode;
  final String routeDay;
  final String pin;
  final bool isExistingMargDealer;
  final bool isLoggedIn;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'shop_name': shopName,
      'address': address,
      'dealer_code': dealerCode,
      'route_day': routeDay,
      'pin': pin,
      'is_existing_marg_dealer': isExistingMargDealer,
      'is_logged_in': isLoggedIn,
    };
  }

  DealerProfileEntity copyWith({
    String? phone,
    String? shopName,
    String? address,
    String? dealerCode,
    String? routeDay,
    String? pin,
    bool? isExistingMargDealer,
    bool? isLoggedIn,
  }) {
    return DealerProfileEntity(
      phone: phone ?? this.phone,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      dealerCode: dealerCode ?? this.dealerCode,
      routeDay: routeDay ?? this.routeDay,
      pin: pin ?? this.pin,
      isExistingMargDealer: isExistingMargDealer ?? this.isExistingMargDealer,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
