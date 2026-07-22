import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();

  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await sharedPreferences();
  }

  static Future<SharedPreferences> sharedPreferences() async =>
      await SharedPreferences.getInstance();

  static Future<T?> getData<T>(String key) async {
    final instance = _preferences ?? await sharedPreferences();
    final result = instance.get(key);
    if (result == null) return null;
    if (T == Map || T == Map<dynamic, dynamic>) {
      return json.decode(result.toString()) as T;
    } else if (T == Map<String, dynamic>) {
      return Map<String, dynamic>.from(json.decode(result.toString())) as T;
    } else if (T == List<Map<String, dynamic>>) {
      return List<Map<String, dynamic>>.from(json.decode(result.toString()))
          as T;
    } else {
      return result as T;
    }
  }

  static Future<bool> saveData(String key, dynamic value) async {
    final instance = _preferences ?? await sharedPreferences();
    if (value is String) return await instance.setString(key, value);
    if (value is bool) return await instance.setBool(key, value);
    if (value is int) return await instance.setInt(key, value);
    if (value is double) return await instance.setDouble(key, value);
    if (value is List<String>) return await instance.setStringList(key, value);
    if (value is Map) return await instance.setString(key, json.encode(value));
    if (value is List<Map>) {
      return await instance.setStringList(
        key,
        value.map((e) => json.encode(e)).toList(),
      );
    }
    return await instance.setString(key, value);
  }

  static Future<bool> remove(String key) async {
    final instance = _preferences ?? await sharedPreferences();
    return await instance.remove(key);
  }

  static Future<bool> clear() async {
    final instance = _preferences ?? await sharedPreferences();
    return await instance.clear();
  }
}

class AppCache {
  static bool isViewedOnboarding = false;

  static Future<void> setIsViewedOnboarding(bool value) async {
    isViewedOnboarding = value;
    await CacheService.saveData("onBoarding", value);
  }

  static Future<bool> getOnboardingStatus() async {
    return isViewedOnboarding =
        (await CacheService.getData("onBoarding")) ?? false;
  }

  static Future<String> getLanguage() async {
    final cached = await CacheService.getData("language");
    if (cached != null) return cached.toString();
    try {
      final localeName = Platform.localeName;
      if (localeName.isNotEmpty) {
        return localeName.split('_').first;
      }
    } catch (_) {}
    return 'en';
  }

  static Future<void> setLanguage(String value) async {
    await CacheService.saveData("language", value);
  }

  static Future<String?> get getCartId async =>
      await CacheService.getData('store_cart_id');

  static Future<bool> setCartId(String id) async =>
      await CacheService.saveData('store_cart_id', id);

  static Future<bool> removeCartId() async =>
      await CacheService.remove('store_cart_id');

  static Future<String?> get getRegionId async =>
      await CacheService.getData('store_region_id');

  static Future<bool> setRegionId(String id) async =>
      await CacheService.saveData('store_region_id', id);

  static Future<bool> removeRegionId() async =>
      await CacheService.remove('store_region_id');

  static Future<void> clearData() async {
    await Future.wait({removeCartId(), AppCache.removeRegionId()});
  }
}
