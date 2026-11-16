import 'dart:convert';

import 'package:services/services.dart';

import '../models/dealer/entity/dealer_profile_entity.dart';
import '../models/item/converter/footwear_item_converter.dart';
import '../models/item/entity/footwear_item_entity.dart';
import '../models/party/converter/party_ledger_converter.dart';
import '../models/party/entity/party_ledger_entity.dart';
import '../models/scheme/entity/booking_scheme_entity.dart';
import '../utils/enums/scheme_reward_type_enum.dart';
import '../utils/storage_key_consts.dart';

class MasterDataRepository {
  MasterDataRepository._();

  static final MasterDataRepository instance = MasterDataRepository._();

  static const String _itemMasterAsset = 'full_item_master.csv';
  static const String _partiesAsset = 'clean_parties.csv';
  static const String _storageKeyMappings = 'marg_barcode_mappings_v2';

  final Map<String, String> _barcodeToItemCode = <String, String>{};
  final Map<String, DealerProfileEntity> _registeredDealers =
      <String, DealerProfileEntity>{};

  List<FootwearItemEntity> _cachedItems = <FootwearItemEntity>[];
  List<PartyLedgerEntity> _cachedParties = <PartyLedgerEntity>[];

  static String normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  void _loadStoredDealers() {
    final rawJson = LocalStorage.instance.readString(
      StorageKeyConsts.registeredDealersJson,
    );
    if (rawJson == null || rawJson.isEmpty) {
      return;
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List<dynamic>) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final profile = DealerProfileEntity.fromJson(item);
            final normalized = normalizePhone(profile.phone);
            if (normalized.isNotEmpty && profile.pin.isNotEmpty) {
              _registeredDealers[normalized] = profile;
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _persistRegisteredDealers() async {
    final list = _registeredDealers.values.map((e) => e.toJson()).toList();
    await LocalStorage.instance.writeString(
      StorageKeyConsts.registeredDealersJson,
      jsonEncode(list),
    );
  }

  Future<ServiceResponse<List<DealerProfileEntity>>>
      loadRegisteredDealers() async {
    _loadStoredDealers();
    final cloudResp = await RestApi.instance.fetchCloudDealerRegistrations();
    final cloudMap = cloudResp.data;
    if (cloudMap != null && cloudMap.isNotEmpty) {
      var changed = false;
      for (final entry in cloudMap.entries) {
        final normalized = normalizePhone(entry.key);
        final row = entry.value;
        final pin = (row['pin'] ?? '').trim();
        if (normalized.isNotEmpty && pin.isNotEmpty) {
          final existing = _registeredDealers[normalized];
          if (existing == null || existing.pin != pin) {
            _registeredDealers[normalized] = DealerProfileEntity(
              phone: normalized,
              shopName: row['shop_name'] ?? '',
              address: row['address'] ?? '',
              pin: pin,
              isExistingMargDealer: true,
            );
            changed = true;
          }
        }
      }
      if (changed) {
        await _persistRegisteredDealers();
      }
    }
    return ServiceResponse<List<DealerProfileEntity>>.success(
      data: _registeredDealers.values.toList(),
    );
  }

  DealerProfileEntity? findRegisteredDealerByPhone(String rawPhone) {
    if (_registeredDealers.isEmpty) {
      _loadStoredDealers();
    }
    final normalized = normalizePhone(rawPhone);
    if (normalized.isEmpty) {
      return null;
    }
    return _registeredDealers[normalized];
  }

  Future<ServiceResponse<DealerProfileEntity>> registerDealerWithPin({
    required String phone,
    required String shopName,
    required String address,
    required String pin,
    required bool isExistingMargDealer,
  }) async {
    final cleanPhone = normalizePhone(phone);
    final cleanShop = shopName.trim().toUpperCase();
    final cleanAddr = address.trim();
    final cleanPin = pin.trim();

    await loadRegisteredDealers();
    final existing = _registeredDealers[cleanPhone];
    if (existing != null && existing.pin.isNotEmpty) {
      return ServiceResponse<DealerProfileEntity>.error(
        message: 'This mobile number is already registered. '
            'Please login with your 5-digit PIN.',
      );
    }

    final cloudResp = await RestApi.instance.registerCloudDealerWithPin(
      phone: cleanPhone,
      shopName: cleanShop,
      address: cleanAddr,
      pin: cleanPin,
    );
    if (!cloudResp.status.isSuccess) {
      return ServiceResponse<DealerProfileEntity>.error(
        message: cloudResp.message ??
            'This mobile number is already registered.',
      );
    }

    final profile = DealerProfileEntity(
      phone: cleanPhone,
      shopName: cleanShop,
      address: cleanAddr,
      pin: cleanPin,
      isExistingMargDealer: isExistingMargDealer,
    );
    _registeredDealers[cleanPhone] = profile;
    await _persistRegisteredDealers();
    return ServiceResponse<DealerProfileEntity>.success(data: profile);
  }

  Future<ServiceResponse<DealerProfileEntity>> verifyDealerPinLogin({
    required String phone,
    required String pin,
  }) async {
    final cleanPhone = normalizePhone(phone);
    final cleanPin = pin.trim();

    await loadRegisteredDealers();
    final registered = _registeredDealers[cleanPhone];
    if (registered == null || registered.pin.isEmpty) {
      return ServiceResponse<DealerProfileEntity>.error(
        message: 'This mobile number is not registered yet. '
            'Please register and set your 5-digit PIN first.',
      );
    }
    if (registered.pin != cleanPin) {
      return ServiceResponse<DealerProfileEntity>.error(
        message: 'Incorrect 5-digit PIN! '
            'Please enter the correct PIN for this mobile number.',
      );
    }

    return ServiceResponse<DealerProfileEntity>.success(
      data: registered.copyWith(isLoggedIn: true),
    );
  }

  void _loadStoredMappings() {
    final rawJson = LocalStorage.instance.readString(_storageKeyMappings);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((key, val) {
            if (val is String) {
              _barcodeToItemCode[key] = val;
            }
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _persistMappings() async {
    final raw = jsonEncode(_barcodeToItemCode);
    await LocalStorage.instance.writeString(_storageKeyMappings, raw);
  }

  Future<ServiceResponse<List<FootwearItemEntity>>> loadMasterItems() async {
    _loadStoredMappings();
    final cloudMappings = await RestApi.instance.fetchCloudBarcodeMappings();
    final cloudMapData = cloudMappings.data;
    if (cloudMapData != null) {
      _barcodeToItemCode.addAll(cloudMapData);
      await _persistMappings();
    }

    final itemCodeToBarcode = <String, String>{};
    for (final entry in _barcodeToItemCode.entries) {
      itemCodeToBarcode[entry.value] = entry.key;
    }

    final rawCsv = await CsvFileService.instance.loadAssetCsv(_itemMasterAsset);
    if (rawCsv.isEmpty) {
      _cachedItems = _fallbackItems(itemCodeToBarcode);
      return ServiceResponse<List<FootwearItemEntity>>.success(
        data: _cachedItems,
      );
    }

    final rows = CsvFileService.instance.parseCsvLines(rawCsv);
    final parsed = FootwearItemConverter.fromCsvRows(rows, itemCodeToBarcode);
    _cachedItems = parsed.isEmpty ? _fallbackItems(itemCodeToBarcode) : parsed;

    // Apply cloud dynamic rate & MRP overrides (Module A)
    final rateOverridesResp = await RestApi.instance.fetchCloudRateOverrides();
    final overridesMap = rateOverridesResp.data;
    if (overridesMap != null && overridesMap.isNotEmpty) {
      final updatedWithOverrides = <FootwearItemEntity>[];
      for (final item in _cachedItems) {
        final override = overridesMap[item.code];
        if (override != null) {
          final newRate = double.tryParse(override['wholesale_rate']?.toString() ?? '');
          final newMrp = double.tryParse(override['mrp']?.toString() ?? '');
          updatedWithOverrides.add(item.copyWithRates(newRateA: newRate, newMrp: newMrp));
        } else {
          updatedWithOverrides.add(item);
        }
      }
      _cachedItems = updatedWithOverrides;
    }

    final verResp = await RestApi.instance.fetchCloudCatalogVersion();
    final ver = verResp.data;
    if (ver != null && ver.isNotEmpty) {
      await LocalStorage.instance.writeString(StorageKeyConsts.catalogVersion, ver);
    }

    return ServiceResponse<List<FootwearItemEntity>>.success(
      data: _cachedItems,
    );
  }

  Future<ServiceResponse<List<BookingSchemeEntity>>> loadCloudSchemes() async {
    final schemesResp = await RestApi.instance.fetchCloudSchemes();
    final list = schemesResp.data;
    if (list != null && list.isNotEmpty) {
      final parsedSchemes = list.map((e) => BookingSchemeEntity.fromJson(e)).toList();
      await LocalStorage.instance.writeString(
        StorageKeyConsts.cachedSchemes,
        jsonEncode(list),
      );
      return ServiceResponse<List<BookingSchemeEntity>>.success(data: parsedSchemes);
    }

    final cachedRaw = LocalStorage.instance.readString(StorageKeyConsts.cachedSchemes);
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(cachedRaw);
        if (decoded is List<dynamic>) {
          final cachedSchemes = decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => BookingSchemeEntity.fromJson(e))
              .toList();
          if (cachedSchemes.isNotEmpty) {
            return ServiceResponse<List<BookingSchemeEntity>>.success(data: cachedSchemes);
          }
        }
      } catch (_) {}
    }

    return ServiceResponse<List<BookingSchemeEntity>>.success(
      data: _defaultFallbackSchemes(),
    );
  }

  static List<BookingSchemeEntity> _defaultFallbackSchemes() {
    return const <BookingSchemeEntity>[
      BookingSchemeEntity(
        id: 'scheme-bronze',
        schemeName: 'Bronze Scheme',
        minPairs: 100,
        rewardDescription: '2% Additional Cash Discount',
        rewardType: SchemeRewardTypeEnum.discountPercent,
        discountPercent: 2.0,
      ),
      BookingSchemeEntity(
        id: 'scheme-silver',
        schemeName: 'Silver Coin Scheme',
        minPairs: 250,
        rewardDescription: 'Free 10g Silver Coin + 3% Extra Trade Discount',
        rewardType: SchemeRewardTypeEnum.giftItem,
        discountPercent: 3.0,
      ),
      BookingSchemeEntity(
        id: 'scheme-gold',
        schemeName: 'Gold Scheme',
        minPairs: 500,
        rewardDescription: 'Free Microwave Oven / 5g Gold Coin',
        rewardType: SchemeRewardTypeEnum.giftItem,
        discountPercent: 4.0,
      ),
      BookingSchemeEntity(
        id: 'scheme-platinum',
        schemeName: 'Platinum VIP Scheme',
        minPairs: 1000,
        rewardDescription: 'Free LED TV / Goa Trip Voucher',
        rewardType: SchemeRewardTypeEnum.giftItem,
        discountPercent: 5.0,
      ),
    ];
  }

  Future<ServiceResponse<List<PartyLedgerEntity>>> loadPartyLedgers() async {
    final rawCsv = await CsvFileService.instance.loadAssetCsv(_partiesAsset);
    if (rawCsv.isEmpty) {
      _cachedParties = _fallbackParties();
      return ServiceResponse<List<PartyLedgerEntity>>.success(
        data: _cachedParties,
      );
    }

    final rows = CsvFileService.instance.parseCsvLines(rawCsv);
    final parsed = PartyLedgerConverter.fromCsvRows(rows);
    _cachedParties = parsed.isEmpty ? _fallbackParties() : parsed;

    return ServiceResponse<List<PartyLedgerEntity>>.success(
      data: _cachedParties,
    );
  }

  Future<ServiceResponse<FootwearItemEntity>> linkBarcodeToItem({
    required String barcode,
    required String itemCode,
  }) async {
    final cleanBarcode = barcode.trim();
    final cleanCode = itemCode.trim();
    _barcodeToItemCode[cleanBarcode] = cleanCode;
    await _persistMappings();
    await RestApi.instance.pushBarcodeMapping(
      barcode: cleanBarcode,
      itemCode: cleanCode,
    );

    FootwearItemEntity? matchedItem;
    final updatedList = <FootwearItemEntity>[];
    for (final item in _cachedItems) {
      if (item.code == cleanCode) {
        final updated = item.copyWithBarcode(cleanBarcode);
        matchedItem = updated;
        updatedList.add(updated);
      } else {
        updatedList.add(item);
      }
    }
    _cachedItems = updatedList;

    if (matchedItem != null) {
      return ServiceResponse<FootwearItemEntity>.success(data: matchedItem);
    }
    return ServiceResponse<FootwearItemEntity>.error(
      message: 'Item code $cleanCode not found in master list.',
    );
  }

  FootwearItemEntity? findItemByBarcodeOrCode(String rawInput) {
    final clean = rawInput.trim();
    final mappedCode = _barcodeToItemCode[clean];
    for (final item in _cachedItems) {
      if (item.barcode == clean ||
          item.code == clean ||
          (mappedCode != null && item.code == mappedCode)) {
        return item;
      }
    }
    return null;
  }

  Map<String, String> get barcodeMappings =>
      Map<String, String>.unmodifiable(_barcodeToItemCode);

  List<FootwearItemEntity> _fallbackItems(Map<String, String> codeToBarcode) {
    return <FootwearItemEntity>[
      FootwearItemEntity(
        code: '3046',
        barcode: codeToBarcode['3046'] ?? '8901234560012',
        product: '028 GRY 2X5 (NEW)',
        unit: 'PAIR',
        company: 'AJANTA',
        group: 'GREY',
        category: 'COLOUR HAWAI(AJANTA)',
        hsn: '6402',
        gst: 5.0,
        closingStock: 388,
        mrp: 129.0,
        rateA: 129.0,
      ),
      FootwearItemEntity(
        code: '3048',
        barcode: codeToBarcode['3048'] ?? '8901234560029',
        product: '028 GRY 6X9 (NEW)',
        unit: 'PAIR',
        company: 'AJANTA',
        group: 'GREY',
        category: 'COLOUR HAWAI(AJANTA)',
        hsn: '6402',
        gst: 5.0,
        closingStock: 426,
        mrp: 136.0,
        rateA: 136.0,
      ),
      FootwearItemEntity(
        code: '0329',
        barcode: codeToBarcode['0329'] ?? '8901234560036',
        product: '6220 VERTEX GENTS (P) TAN0610A',
        unit: 'PAIR',
        company: 'PARAGON',
        group: 'TAN',
        category: 'VERTEX GENTS',
        hsn: '6402',
        gst: 5.0,
        closingStock: 12,
        mrp: 409.0,
        rateA: 409.0,
      ),
      const FootwearItemEntity(
        code: '3019',
        barcode: '',
        product: '510-A-72 6X9 (NEW)',
        unit: 'PAIR',
        company: 'AGRA SHOE',
        group: 'GREEN',
        category: 'CASUAL',
        hsn: '6402',
        gst: 5.0,
        closingStock: 6,
        mrp: 120.0,
        rateA: 120.0,
      ),
    ];
  }

  List<PartyLedgerEntity> _fallbackParties() {
    final rows = <List<String>>[
      <String>['party_name', 'route_day', 'address', 'phone', 'bal', 'type'],
      <String>[
        'A.R.SHOE COLLECTION',
        'SATURDAY',
        'BHANDERHATI HOOGHLY.',
        '9163316261',
        '3750.0',
        'DR',
      ],
      <String>[
        'ABHIJIT SHOE',
        'TUESDAY',
        'KUNTIGHAT',
        '7044578874',
        '20726.0',
        'DR',
      ],
      <String>[
        'AHWONG SHOE',
        'SUNDAY',
        'SHRIRAMPUR HOOGHLY',
        '9007961308',
        '107676.0',
        'DR',
      ],
      <String>[
        'AJANTA SHOE',
        'SATURDAY',
        'SUGANDHA MORE',
        '9883433169',
        '1112.0',
        'DR',
      ],
      <String>[
        'ALPONA SHOE HOUSE',
        'FRIDAY',
        'PATHAR GHATA PURBA BARDHHAMAN.',
        '7063326901',
        '6638.0',
        'DR',
      ],
    ];
    return PartyLedgerConverter.fromCsvRows(rows);
  }
}
