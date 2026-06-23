import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/discovered_vault.dart';
import '../models/vault_status.dart';

/// BLE link to the ESP32 vault (design §3) with proximity discovery + pairing.
///
/// Flow:  startScan()  →  scanStream emits nearby vaults (with RSSI/proximity)
///        connectTo(id) →  pairs/bonds, subscribes to Status, enables commands
///        sendCommand() →  unlock / lock / changepw  (only once connected)
///
/// Ships with [useMock] = true so the whole flow demos with NO hardware: the
/// mock fakes a vault "walking closer" (RSSI climbs), then pairs.
class BleService {
  // Real Bluetooth on phones; mock on web (browsers have no BLE) so the
  // published web demo still works. Force false to test real BLE elsewhere.
  static bool useMock = kIsWeb;

  // TODO: replace with the real 128-bit UUIDs you generate (must match firmware).
  static const serviceUuid = 'c0de0001-feed-4a17-8b9a-0000c0de0001';
  static const cmdCharUuid = 'c0de0001-feed-4a17-8b9a-0000c0de0002';
  static const statusCharUuid = 'c0de0001-feed-4a17-8b9a-0000c0de0003';

  final _scanCtrl = StreamController<List<DiscoveredVault>>.broadcast();
  final _statusCtrl = StreamController<VaultStatus>.broadcast();
  final _connCtrl = StreamController<bool>.broadcast();
  Stream<List<DiscoveredVault>> get scanStream => _scanCtrl.stream;
  Stream<VaultStatus> get statusStream => _statusCtrl.stream;
  Stream<bool> get connectionStream => _connCtrl.stream;

  // real-mode handles
  BluetoothDevice? _device;
  BluetoothCharacteristic? _cmdChar;
  StreamSubscription? _scanSub;

  // mock state
  VaultStatus _mock = const VaultStatus(locked: true, battery: 87);
  Timer? _mockScanTimer, _mockBattTimer;
  int _mockRssi = -88;

  // ---------------------------------------------------------------- SCAN -----
  Future<void> startScan() async {
    if (useMock) {
      _mockRssi = -88;
      _mockScanTimer?.cancel();
      // vault appears far, then "walks closer" (RSSI climbs to ~-45).
      _mockScanTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
        if (_mockRssi < -45) _mockRssi += 6;
        _scanCtrl.add([
          DiscoveredVault(id: 'MOCK-VAULT-01', name: 'CurioLock-Vault', rssi: _mockRssi),
        ]);
      });
      return;
    }
    // REAL:
    await FlutterBluePlus.startScan(
      withServices: [Guid(serviceUuid)],
      continuousUpdates: true,
      timeout: const Duration(seconds: 30),
    );
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final vaults = results
          .map((r) => DiscoveredVault(
                id: r.device.remoteId.str,
                name: r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : 'CurioLock-Vault',
                rssi: r.rssi,
              ))
          .toList();
      _scanCtrl.add(vaults);
    });
  }

  Future<void> stopScan() async {
    _mockScanTimer?.cancel();
    if (!useMock) {
      await _scanSub?.cancel();
      await FlutterBluePlus.stopScan();
    }
  }

  // ------------------------------------------------------------- CONNECT -----
  Future<void> connectTo(String deviceId) async {
    await stopScan();
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 1200)); // simulate pairing
      _connCtrl.add(true);
      _statusCtrl.add(_mock);
      _mockBattTimer?.cancel();
      _mockBattTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        _mock = _mock.copyWith(battery: (_mock.battery - 1).clamp(0, 100));
        _statusCtrl.add(_mock);
      });
      return;
    }
    // REAL:
    _device = BluetoothDevice.fromId(deviceId);
    _device!.connectionState.listen((s) {
      _connCtrl.add(s == BluetoothConnectionState.connected);
    });
    await _device!.connect(timeout: const Duration(seconds: 15));
    try {
      await _device!.createBond(); // Android pairing prompt; no-op/throw on iOS
    } catch (_) {}
    final services = await _device!.discoverServices();
    for (final svc in services) {
      if (svc.uuid.str.toLowerCase() != serviceUuid.toLowerCase()) continue;
      for (final ch in svc.characteristics) {
        final u = ch.uuid.str.toLowerCase();
        if (u == cmdCharUuid.toLowerCase()) _cmdChar = ch;
        if (u == statusCharUuid.toLowerCase()) {
          await ch.setNotifyValue(true);
          ch.onValueReceived.listen((bytes) {
            try {
              _statusCtrl.add(VaultStatus.fromJson(jsonDecode(utf8.decode(bytes))));
            } catch (_) {}
          });
        }
      }
    }
  }

  // ------------------------------------------------------------- COMMAND -----
  Future<bool> sendCommand(Map<String, dynamic> cmd) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 350));
      switch (cmd['cmd']) {
        case 'unlock':
          final ok = cmd['pwd'] == '1234';
          _mock = _mock.copyWith(
            locked: ok ? false : _mock.locked,
            lastResult: ok ? 'success' : 'fail',
            lastAccess: ok ? DateTime.now() : _mock.lastAccess,
          );
          _statusCtrl.add(_mock);
          return ok;
        case 'lock':
        case 'emergency_lock':
          _mock = _mock.copyWith(locked: true, lastResult: 'idle');
          _statusCtrl.add(_mock);
          return true;
        case 'changepw':
          return cmd['old'] == '1234';
        default:
          return true;
      }
    }
    // REAL:
    if (_cmdChar == null) return false;
    await _cmdChar!.write(utf8.encode(jsonEncode(cmd)), withoutResponse: false);
    return true;
  }

  void dispose() {
    _mockScanTimer?.cancel();
    _mockBattTimer?.cancel();
    _scanSub?.cancel();
    _scanCtrl.close();
    _statusCtrl.close();
    _connCtrl.close();
  }
}
