import 'dart:convert';
import 'dart:io';
import 'dart:math';

class LocalStorage {
  LocalStorage._();

  static final LocalStorage instance = LocalStorage._();

  final Map<String, Object> _memoryStore = <String, Object>{};
  String _cachedDeviceUuid = '';

  String? readString(String key) {
    final val = _memoryStore[key];
    return val is String ? val : null;
  }

  Future<void> writeString(String key, String value) async {
    _memoryStore[key] = value;
    await _saveToDisk();
  }

  bool? readBool(String key) {
    final val = _memoryStore[key];
    return val is bool ? val : null;
  }

  Future<void> writeBool(String key, bool value) async {
    _memoryStore[key] = value;
    await _saveToDisk();
  }

  List<String> readStringList(String key) {
    final val = _memoryStore[key];
    if (val is List<String>) {
      return List<String>.from(val);
    }
    return <String>[];
  }

  Future<void> writeStringList(String key, List<String> values) async {
    _memoryStore[key] = List<String>.from(values);
    await _saveToDisk();
  }

  String getOrCreateDeviceUuid() {
    if (_cachedDeviceUuid.isNotEmpty) {
      return _cachedDeviceUuid;
    }
    final existing = readString('marg_auto_device_uuid');
    if (existing != null && existing.isNotEmpty) {
      _cachedDeviceUuid = existing;
      return existing;
    }
    final rng = Random();
    const chars = 'ABCDEF0123456789';
    final buf = StringBuffer('ANDROID-HW-');
    for (var i = 0; i < 6; i++) {
      buf.write(chars[rng.nextInt(chars.length)]);
    }
    final generated = buf.toString();
    _cachedDeviceUuid = generated;
    _memoryStore['marg_auto_device_uuid'] = generated;
    _saveToDisk();
    return generated;
  }

  Future<void> initFromDisk() async {
    try {
      final file = _resolveStoreFile();
      if (file.existsSync()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          decoded.forEach((k, v) {
            if (v is String || v is bool) {
              _memoryStore[k] = v;
            } else if (v is List<dynamic>) {
              _memoryStore[k] = v.map((e) => e.toString()).toList();
            }
          });
        }
      }
      getOrCreateDeviceUuid();
    } catch (_) {
      getOrCreateDeviceUuid();
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final file = _resolveStoreFile();
      file.writeAsStringSync(jsonEncode(_memoryStore));
    } catch (_) {
      // Fallback to in-memory store when file write is restricted
    }
  }

  File _resolveStoreFile() {
    final dir = Directory.systemTemp;
    return File('${dir.path}/margsync_local_prefs.json');
  }
}
