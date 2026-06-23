/// A CurioLock vault found during a BLE scan, with proximity derived from RSSI.
class DiscoveredVault {
  final String id; // BLE remote id / MAC
  final String name;
  final int rssi; // signal strength, dBm (closer = higher, e.g. -45 near, -85 far)

  const DiscoveredVault({required this.id, required this.name, required this.rssi});

  /// Human proximity bucket from signal strength.
  String get proximity => rssi >= -55
      ? 'Right here'
      : rssi >= -70
          ? 'Nearby'
          : 'Far away';

  /// 1..4 signal bars.
  int get bars => rssi >= -55
      ? 4
      : rssi >= -65
          ? 3
          : rssi >= -78
              ? 2
              : 1;

  /// True once close enough to safely pair (avoids pairing a vault two rooms away).
  bool get inRange => rssi >= -70;

  DiscoveredVault copyWith({int? rssi}) =>
      DiscoveredVault(id: id, name: name, rssi: rssi ?? this.rssi);
}
