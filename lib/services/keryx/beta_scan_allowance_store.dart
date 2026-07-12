import 'package:shared_preferences/shared_preferences.dart';

/// Contest beta UX/cost guard — local Boolean only, not secure rate limiting.
///
/// Key: [kHasUsedBetaKeryxScanKey] (`hasUsedBetaKeryxScan`).
/// Uninstall / clear app data (Android) or clear browser storage / new profile
/// (web) resets the limit.
const String kHasUsedBetaKeryxScanKey = 'hasUsedBetaKeryxScan';

abstract interface class BetaScanAllowanceStore {
  Future<bool> hasUsedBetaScan();
  Future<void> markBetaScanUsed();
}

class SharedPreferencesBetaScanStore implements BetaScanAllowanceStore {
  SharedPreferencesBetaScanStore([SharedPreferences? prefs]) : _prefs = prefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> hasUsedBetaScan() async {
    final prefs = await _ensure();
    return prefs.getBool(kHasUsedBetaKeryxScanKey) ?? false;
  }

  @override
  Future<void> markBetaScanUsed() async {
    final prefs = await _ensure();
    await prefs.setBool(kHasUsedBetaKeryxScanKey, true);
  }
}

/// In-memory store for tests.
class MemoryBetaScanStore implements BetaScanAllowanceStore {
  bool used = false;

  @override
  Future<bool> hasUsedBetaScan() async => used;

  @override
  Future<void> markBetaScanUsed() async {
    used = true;
  }
}
