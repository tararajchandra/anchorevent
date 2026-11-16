import 'dart:convert';
import 'dart:io';

import '../service_state/service_response.dart';

class RestApi {
  RestApi._();

  static final RestApi instance = RestApi._();

  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://obepjbdoicltdlqtbtlc.supabase.co',
  );
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String _defaultShopUuid = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

  String _activeShopUuid = _defaultShopUuid;

  final Map<String, String> _cloudBarcodeStore = <String, String>{
    '8901234560012': '3046',
    '8901234560029': '3048',
    '8901234560036': '0329',
  };

  final Map<String, Map<String, String>> _cloudDealerRegistrations =
      <String, Map<String, String>>{};

  bool get isCloudConfigured =>
      _supabaseUrl.trim().isNotEmpty &&
      _supabaseAnonKey.trim().isNotEmpty &&
      !_supabaseAnonKey.contains('paste-your');

  Future<ServiceResponse<Map<String, dynamic>>> verifyDeviceLicense({
    required String licenseKey,
    required String deviceUuid,
    required String salesmanName,
    required String salesmanPin,
  }) async {
    final trimmedKey = licenseKey.trim().toUpperCase();
    final trimmedName = salesmanName.trim();
    final trimmedPin = salesmanPin.trim();

    if (trimmedKey.isEmpty || trimmedKey.length < 6) {
      return ServiceResponse<Map<String, dynamic>>.error(
        message: 'Invalid Shop License Key.',
      );
    }
    if (trimmedName.isEmpty) {
      return ServiceResponse<Map<String, dynamic>>.error(
        message: 'Please enter Salesman Name.',
      );
    }
    if (trimmedPin.length < 4) {
      return ServiceResponse<Map<String, dynamic>>.error(
        message: 'Please enter a valid 4-digit Salesman PIN.',
      );
    }

    if (isCloudConfigured) {
      final directResult = await _verifyAndAutoRegisterDeviceDirect(
        licenseKey: trimmedKey,
        deviceUuid: deviceUuid,
        salesmanEmailOrName: trimmedName,
        salesmanPin: trimmedPin,
      );
      if (directResult != null) {
        return directResult;
      }

      final rpcResult = await _postSupabaseJson(
        path: '/rest/v1/rpc/activate_device',
        body: <String, dynamic>{
          'p_license_key': trimmedKey,
          'p_device_uuid': deviceUuid,
          'p_salesman': trimmedName,
          'p_salesman_pin': trimmedPin,
        },
      );
      if (rpcResult != null) {
        if (rpcResult['success'] == true) {
          final shopUuid = rpcResult['shopId'] as String?;
          if (shopUuid != null && shopUuid.isNotEmpty) {
            _activeShopUuid = shopUuid;
          }
          return ServiceResponse<Map<String, dynamic>>.success(data: rpcResult);
        }
        final errMsg = rpcResult['message'] as String?;
        return ServiceResponse<Map<String, dynamic>>.error(
          message: errMsg ?? 'Login failed on server.',
        );
      }
    }

    return ServiceResponse<Map<String, dynamic>>.success(
      data: <String, dynamic>{
        'shopId': _activeShopUuid,
        'shopName': 'ANCHAR SHOE HOUSE',
        'licenseKey': trimmedKey,
        'deviceUuid': deviceUuid,
        'salesmanName': trimmedName,
        'maxDevices': 3,
        'activeDevices': 1,
        'subscriptionEnd': '2027-10-31',
        'isActive': true,
      },
    );
  }

  Future<ServiceResponse<Map<String, String>>> fetchCloudBarcodeMappings() async {
    if (isCloudConfigured) {
      final list = await _getSupabaseList(
        path: '/rest/v1/barcode_mappings?shop_id=eq.$_activeShopUuid'
            '&select=barcode,item_code',
      );
      if (list != null) {
        for (final entry in list) {
          if (entry is Map<String, dynamic>) {
            final bCode = entry['barcode'] as String? ?? '';
            final iCode = entry['item_code'] as String? ?? '';
            if (bCode.isNotEmpty && iCode.isNotEmpty) {
              _cloudBarcodeStore[bCode] = iCode;
            }
          }
        }
      }
    }

    return ServiceResponse<Map<String, String>>.success(
      data: Map<String, String>.from(_cloudBarcodeStore),
    );
  }

  Future<ServiceResponse<bool>> pushBarcodeMapping({
    required String barcode,
    required String itemCode,
  }) async {
    _cloudBarcodeStore[barcode] = itemCode;

    if (isCloudConfigured) {
      await _postSupabaseJson(
        path: '/rest/v1/barcode_mappings?on_conflict=shop_id,barcode',
        preferHeader: 'resolution=merge-duplicates',
        body: <String, dynamic>{
          'shop_id': _activeShopUuid,
          'barcode': barcode,
          'item_code': itemCode,
        },
      );
    }

    return ServiceResponse<bool>.success(data: true);
  }

  Future<ServiceResponse<bool>> pushBillHeader({
    required String billNo,
    required String billDate,
    required String createdTime,
    required String partyName,
    required String deviceUuid,
    required String salesmanName,
    required int totalPairs,
    required double totalAmount,
  }) async {
    if (isCloudConfigured) {
      await _postSupabaseJson(
        path: '/rest/v1/bills?on_conflict=shop_id,bill_no',
        preferHeader: 'resolution=merge-duplicates',
        body: <String, dynamic>{
          'shop_id': _activeShopUuid,
          'bill_no': billNo,
          'bill_date': billDate,
          'created_time': createdTime,
          'party_name': partyName,
          'device_uuid': deviceUuid,
          'salesman_name': salesmanName,
          'total_pairs': totalPairs,
          'total_amount': totalAmount,
        },
      );
    }
    return ServiceResponse<bool>.success(data: true);
  }

  Future<ServiceResponse<Map<String, Map<String, String>>>>
      fetchCloudDealerRegistrations() async {
    if (isCloudConfigured) {
      final list = await _getSupabaseList(
        path: '/rest/v1/devices?shop_id=eq.$_activeShopUuid'
            '&select=device_uuid,salesman_name,salesman_pin,is_blocked',
      );
      if (list != null) {
        for (final entry in list) {
          if (entry is Map<String, dynamic>) {
            final dUuid = (entry['device_uuid'] as String? ?? '').trim();
            final pin = (entry['salesman_pin'] as String? ?? '').trim();
            final rawName = (entry['salesman_name'] as String? ?? '').trim();
            if (dUuid.startsWith('PHONE-') && pin.isNotEmpty) {
              final phone = dUuid.substring('PHONE-'.length).trim();
              final parts = rawName.split('|');
              final shopName = parts.isNotEmpty ? parts[0].trim() : '';
              final address = parts.length > 1 ? parts[1].trim() : '';
              if (phone.isNotEmpty) {
                _cloudDealerRegistrations[phone] = <String, String>{
                  'phone': phone,
                  'shop_name': shopName,
                  'address': address,
                  'pin': pin,
                };
              }
            }
          }
        }
      }
    }
    return ServiceResponse<Map<String, Map<String, String>>>.success(
      data: Map<String, Map<String, String>>.from(_cloudDealerRegistrations),
    );
  }

  Future<ServiceResponse<bool>> registerCloudDealerWithPin({
    required String phone,
    required String shopName,
    required String address,
    required String pin,
  }) async {
    final existing = _cloudDealerRegistrations[phone];
    if (existing != null && (existing['pin'] ?? '').isNotEmpty) {
      return ServiceResponse<bool>.error(
        message: 'This mobile number is already registered. '
            'Please login with your 5-digit PIN.',
      );
    }

    if (isCloudConfigured) {
      final deviceKey = 'PHONE-$phone';
      final checkList = await _getSupabaseList(
        path: '/rest/v1/devices?shop_id=eq.$_activeShopUuid'
            '&device_uuid=eq.$deviceKey&select=id,salesman_pin,salesman_name',
      );
      if (checkList != null && checkList.isNotEmpty) {
        final first = checkList.first;
        if (first is Map<String, dynamic>) {
          final existingPin =
              (first['salesman_pin'] as String? ?? '').trim();
          if (existingPin.isNotEmpty) {
            return ServiceResponse<bool>.error(
              message: 'This mobile number is already registered. '
                  'Please login with your 5-digit PIN.',
            );
          }
        }
      }

      await _postSupabaseJson(
        path: '/rest/v1/devices',
        preferHeader: 'return=representation',
        body: <String, dynamic>{
          'shop_id': _activeShopUuid,
          'device_uuid': deviceKey,
          'salesman_name': '$shopName|$address',
          'salesman_pin': pin,
          'is_blocked': false,
        },
      );
    }

    _cloudDealerRegistrations[phone] = <String, String>{
      'phone': phone,
      'shop_name': shopName,
      'address': address,
      'pin': pin,
    };
    return ServiceResponse<bool>.success(data: true);
  }

  Future<ServiceResponse<Map<String, dynamic>>?>
      _verifyAndAutoRegisterDeviceDirect({
    required String licenseKey,
    required String deviceUuid,
    required String salesmanEmailOrName,
    required String salesmanPin,
  }) async {
    final shopsList = await _getSupabaseList(
      path: '/rest/v1/shops?select=*',
    );
    if (shopsList == null) {
      return null;
    }

    Map<String, dynamic>? matchedShop;
    for (final row in shopsList) {
      if (row is Map<String, dynamic>) {
        final rowKey = (row['license_key'] as String? ?? '').trim().toUpperCase();
        if (rowKey == licenseKey) {
          matchedShop = row;
          break;
        }
      }
    }

    if (matchedShop == null) {
      return ServiceResponse<Map<String, dynamic>>.error(
        message: 'Invalid Shop License Key ($licenseKey)!',
      );
    }

    final isActive = matchedShop['is_active'] as bool? ?? true;
    if (!isActive) {
      return ServiceResponse<Map<String, dynamic>>.error(
        message: 'This Shop License is suspended by Super Admin!',
      );
    }

    final shopId = matchedShop['id'] as String? ?? _defaultShopUuid;
    final shopName = matchedShop['shop_name'] as String? ?? 'SHOP';
    final maxDevices = matchedShop['max_devices'] as int? ?? 3;
    final subEnd = matchedShop['subscription_end']?.toString() ?? '2027-11-02';

    final devicesList = await _getSupabaseList(
      path: '/rest/v1/devices?shop_id=eq.$shopId&select=*',
    );
    final existingDevices = devicesList ?? <dynamic>[];
    Map<String, dynamic>? thisDevice;
    var activeCount = 0;

    for (final d in existingDevices) {
      if (d is Map<String, dynamic>) {
        final blocked = d['is_blocked'] as bool? ?? false;
        if (!blocked) {
          activeCount++;
        }
        final dUuid = (d['device_uuid'] as String? ?? '').trim().toUpperCase();
        final sName = (d['salesman_name'] as String? ?? '').trim().toLowerCase();
        if (dUuid == deviceUuid.toUpperCase() ||
            sName == salesmanEmailOrName.toLowerCase()) {
          thisDevice = d;
        }
      }
    }

    if (thisDevice != null) {
      final isBlocked = thisDevice['is_blocked'] as bool? ?? false;
      if (isBlocked) {
        return ServiceResponse<Map<String, dynamic>>.error(
          message: 'This device has been blocked by Admin!',
        );
      }
      final savedPin = (thisDevice['salesman_pin'] as String? ?? '').trim();
      if (savedPin.isNotEmpty && savedPin != salesmanPin) {
        return ServiceResponse<Map<String, dynamic>>.error(
          message: 'Incorrect Password / PIN for $salesmanEmailOrName!',
        );
      }
      final rowId = thisDevice['id']?.toString() ?? '';
      final savedUuid = (thisDevice['device_uuid'] as String? ?? '').trim();
      if (rowId.isNotEmpty && savedUuid != deviceUuid) {
        await _patchSupabaseJson(
          path: '/rest/v1/devices?id=eq.$rowId',
          body: <String, dynamic>{
            'device_uuid': deviceUuid,
            'salesman_name': salesmanEmailOrName,
          },
        );
      }
    } else {
      if (activeCount >= maxDevices) {
        return ServiceResponse<Map<String, dynamic>>.error(
          message: 'Device limit ($activeCount/$maxDevices) reached for $shopName!',
        );
      }
      await _postSupabaseJson(
        path: '/rest/v1/devices',
        preferHeader: 'return=representation',
        body: <String, dynamic>{
          'shop_id': shopId,
          'device_uuid': deviceUuid,
          'salesman_name': salesmanEmailOrName,
          'salesman_pin': salesmanPin,
          'is_blocked': false,
        },
      );
      activeCount++;
    }

    _activeShopUuid = shopId;
    return ServiceResponse<Map<String, dynamic>>.success(
      data: <String, dynamic>{
        'shopId': shopId,
        'shopName': shopName,
        'licenseKey': licenseKey,
        'deviceUuid': deviceUuid,
        'salesmanName': salesmanEmailOrName,
        'maxDevices': maxDevices,
        'activeDevices': activeCount,
        'subscriptionEnd': subEnd,
        'isActive': true,
      },
    );
  }

  void _attachSupabaseHeaders(HttpClientRequest request, String? preferHeader) {
    final key = _supabaseAnonKey.trim();
    request.headers.set('apikey', key);
    if (key.startsWith('eyJ')) {
      request.headers.set('Authorization', 'Bearer $key');
    }
    request.headers.set('Content-Type', 'application/json');
    if (preferHeader != null) {
      request.headers.set('Prefer', preferHeader);
    }
  }

  Future<Map<String, dynamic>?> _postSupabaseJson({
    required String path,
    required Map<String, dynamic> body,
    String? preferHeader,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$_supabaseUrl$path');
      final request = await client.postUrl(uri);
      _attachSupabaseHeaders(request, preferHeader);
      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseBody.isNotEmpty) {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
    return null;
  }

  Future<void> _patchSupabaseJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$_supabaseUrl$path');
      final request = await client.patchUrl(uri);
      _attachSupabaseHeaders(request, null);
      request.write(jsonEncode(body));
      final response = await request.close();
      await response.drain<void>();
    } catch (_) {
      return;
    } finally {
      client.close();
    }
  }

  Future<List<dynamic>?> _getSupabaseList({required String path}) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$_supabaseUrl$path');
      final request = await client.getUrl(uri);
      _attachSupabaseHeaders(request, null);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseBody.isNotEmpty) {
        final decoded = jsonDecode(responseBody);
        if (decoded is List<dynamic>) {
          return decoded;
        }
      }
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
    return null;
  }
}
