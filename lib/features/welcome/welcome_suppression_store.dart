import 'package:shared_preferences/shared_preferences.dart';

/// Local-only preference controlling automatic Welcome display.
abstract class WelcomeSuppressionStore {
  Future<bool> isPermanentlyDismissed();

  Future<void> setPermanentlyDismissed(bool value);
}

extension WelcomeSuppressionStoreX on WelcomeSuppressionStore {
  /// Inverse of [isPermanentlyDismissed] for the About startup switch.
  Future<bool> isShowWelcomeOnStartup() async {
    return !(await isPermanentlyDismissed());
  }

  /// ON → dismissed=false; OFF → dismissed=true.
  Future<void> setShowWelcomeOnStartup(bool show) {
    return setPermanentlyDismissed(!show);
  }
}

/// Suggested logical name: `hasDismissedAgoraWelcomePermanently`.
class SharedPreferencesWelcomeStore implements WelcomeSuppressionStore {
  SharedPreferencesWelcomeStore([SharedPreferences? prefs]) : _prefs = prefs;

  static const String preferenceKey = 'hasDismissedAgoraWelcomePermanently';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> isPermanentlyDismissed() async {
    final prefs = await _ensurePrefs();
    return prefs.getBool(preferenceKey) ?? false;
  }

  @override
  Future<void> setPermanentlyDismissed(bool value) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(preferenceKey, value);
  }
}

/// In-memory store for tests.
class InMemoryWelcomeStore implements WelcomeSuppressionStore {
  InMemoryWelcomeStore({bool permanentlyDismissed = false})
    : _permanentlyDismissed = permanentlyDismissed;

  bool _permanentlyDismissed;

  @override
  Future<bool> isPermanentlyDismissed() async => _permanentlyDismissed;

  @override
  Future<void> setPermanentlyDismissed(bool value) async {
    _permanentlyDismissed = value;
  }
}
