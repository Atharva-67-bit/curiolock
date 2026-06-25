/// Parsed view of the ESP32 "Status" characteristic payload (see design §3.2).
class VaultStatus {
  final bool locked;
  final int battery; // 0..100
  final int rssi;
  final DateTime? lastAccess;
  final String lastResult; // success | fail | locked_out | idle | check_ok | check_fail | reveal
  final int failCount;
  final String fw;
  final String? pwd; // current PIN, only present right after a getpw (reveal) request

  const VaultStatus({
    required this.locked,
    required this.battery,
    this.rssi = 0,
    this.lastAccess,
    this.lastResult = 'idle',
    this.failCount = 0,
    this.fw = '1.0.0',
    this.pwd,
  });

  factory VaultStatus.unknown() => const VaultStatus(locked: true, battery: 0);

  factory VaultStatus.fromJson(Map<String, dynamic> j) => VaultStatus(
        locked: j['locked'] == true,
        battery: (j['battery'] ?? 0) as int,
        rssi: (j['rssi'] ?? 0) as int,
        lastAccess: j['lastAccess'] != null
            ? DateTime.fromMillisecondsSinceEpoch((j['lastAccess'] as int) * 1000)
            : null,
        lastResult: (j['lastResult'] ?? 'idle') as String,
        failCount: (j['failCount'] ?? 0) as int,
        fw: (j['fw'] ?? '1.0.0') as String,
        pwd: j['pwd'] as String?,
      );

  VaultStatus copyWith(
          {bool? locked, int? battery, String? lastResult, DateTime? lastAccess, String? pwd}) =>
      VaultStatus(
        locked: locked ?? this.locked,
        battery: battery ?? this.battery,
        rssi: rssi,
        lastAccess: lastAccess ?? this.lastAccess,
        lastResult: lastResult ?? this.lastResult,
        failCount: failCount,
        fw: fw,
        pwd: pwd ?? this.pwd,
      );
}
