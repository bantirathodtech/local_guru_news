// lib/core/cache/cache_manager.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  static const String _boxName = 'app_cache';
  static CacheManager? _instance;

  late Box _cacheBox;

  CacheManager._internal();

  factory CacheManager() {
    _instance ??= CacheManager._internal();
    return _instance!;
  }

  /// Initialize Hive and open the cache box
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      _cacheBox = await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('CacheManager initialization failed: $e');
      rethrow;
    }
  }

  /// Store a value with optional expiration duration
  Future<void> put(String key, dynamic value, {Duration? duration}) async {
    try {
      final expiry = duration != null
          ? DateTime.now().add(duration).millisecondsSinceEpoch
          : null;
      final cacheEntry = json.encode({
        'data': value,
        'expiry': expiry,
      });
      await _cacheBox.put(key, cacheEntry);
    } catch (e) {
      debugPrint('CacheManager put error for key $key: $e');
    }
  }

  /// Retrieve cached data if it exists and is not expired
  Future<T?> get<T>(String key) async {
    try {
      final entry = _cacheBox.get(key);
      if (entry == null) return null;

      final decoded = json.decode(entry);
      final expiry = decoded['expiry'] as int?;

      if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
        await _cacheBox.delete(key);
        return null;
      }

      return decoded['data'] as T?;
    } catch (e) {
      debugPrint('CacheManager get error for key $key: $e');
      return null;
    }
  }

  /// Remove a cached entry
  Future<void> remove(String key) async {
    await _cacheBox.delete(key);
  }

  /// Clear all cached data
  Future<void> clear() async {
    await _cacheBox.clear();
  }
}
