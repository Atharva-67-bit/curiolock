import 'package:flutter/foundation.dart';
import '../models/activity_entry.dart';
import '../models/discovered_vault.dart';
import '../models/vault_status.dart';
import '../services/ble_service.dart';

/// Holds live vault state, discovery, connection, activity log and settings.
/// Exposed to screens via Provider.
class VaultController extends ChangeNotifier {
  final BleService _ble;
  VaultController(this._ble) {
    _seedLog();
    _ble.scanStream.listen((list) {
      list.sort((a, b) => b.rssi.compareTo(a.rssi)); // closest first
      nearby = list;
      notifyListeners();
    });
    _ble.statusStream.listen((s) {
      // Stamp last-access with the PHONE's real clock (the ESP32 has no RTC).
      if (s.lastResult == 'success' && !s.locked) lastAccessAt = DateTime.now();
      status = s;
      notifyListeners();
    });
    _ble.connectionStream.listen((c) {
      connected = c;
      notifyListeners();
    });
  }

  VaultStatus status = VaultStatus.unknown();
  bool connected = false;
  bool busy = false;
  DateTime? lastAccessAt; // real (phone-clock) time of the last unlock

  // discovery / pairing
  List<DiscoveredVault> nearby = [];
  bool scanning = false;
  String? pairingId; // id currently being paired

  Future<void> startScan() async {
    scanning = true;
    nearby = [];
    notifyListeners();
    await _ble.startScan();
  }

  Future<void> stopScan() async {
    scanning = false;
    notifyListeners();
    await _ble.stopScan();
  }

  Future<void> connectToVault(String id) async {
    pairingId = id;
    busy = true;
    notifyListeners();
    try {
      await _ble.connectTo(id);
    } finally {
      pairingId = null;
      busy = false;
      notifyListeners();
    }
  }

  // settings
  int autoLockSeconds = 30;
  bool wrongPasswordAlert = true;

  // activity log (newest first)
  final List<ActivityEntry> activities = [];

  Future<bool> unlock(String pin) async {
    final ok = await _ble.sendCommand({'cmd': 'unlock', 'pwd': pin, 'ts': _now()});
    _log(ok ? ActivityType.unlock : ActivityType.fail);
    return ok;
  }

  Future<bool> lock() async {
    final ok = await _ble.sendCommand({'cmd': 'lock'});
    if (ok) _log(ActivityType.lock);
    return ok;
  }

  Future<bool> emergencyLock() async {
    final ok = await _ble.sendCommand({'cmd': 'emergency_lock'});
    if (ok) _log(ActivityType.emergency);
    return ok;
  }

  Future<bool> changePassword(String oldPin, String newPin) =>
      _ble.sendCommand({'cmd': 'changepw', 'old': oldPin, 'new': newPin});

  /// VERIFY: ask the vault whether [pin] is the current password (never reveals it).
  Future<bool> verifyPassword(String pin) async {
    final ok = await _ble.sendCommand({'cmd': 'checkpw', 'pwd': pin});
    await Future.delayed(const Duration(milliseconds: 300)); // wait for the status notify
    if (status.lastResult == 'check_ok') return true;
    if (status.lastResult == 'check_fail') return false;
    return ok; // fallback (mock returns directly)
  }

  /// REVEAL: ask the vault to send back the current PIN once.
  Future<String?> revealPassword() async {
    await _ble.sendCommand({'cmd': 'getpw'});
    await Future.delayed(const Duration(milliseconds: 300));
    return status.pwd;
  }

  void setAutoLock(int seconds) {
    autoLockSeconds = seconds;
    notifyListeners();
  }

  void setWrongPasswordAlert(bool v) {
    wrongPasswordAlert = v;
    notifyListeners();
  }

  void _log(ActivityType type) {
    activities.insert(
      0,
      ActivityEntry(type: type, source: 'app', time: DateTime.now(), battery: status.battery),
    );
    notifyListeners();
  }

  void _seedLog() {
    final now = DateTime.now();
    activities.addAll([
      ActivityEntry(type: ActivityType.lock, source: 'app', time: now.subtract(const Duration(hours: 2))),
      ActivityEntry(type: ActivityType.fail, source: 'keypad', time: now.subtract(const Duration(hours: 5))),
      ActivityEntry(type: ActivityType.unlock, source: 'keypad', time: now.subtract(const Duration(hours: 9))),
    ]);
  }

  int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
}
