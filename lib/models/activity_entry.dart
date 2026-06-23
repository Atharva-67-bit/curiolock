import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ActivityType { unlock, fail, lock, emergency }

/// One row in the Activity Log (design §6.5). In the real build these mirror
/// the Firestore `logs` collection (design §5.1).
class ActivityEntry {
  final ActivityType type;
  final String source; // app | keypad
  final DateTime time;
  final int battery;

  const ActivityEntry({
    required this.type,
    required this.source,
    required this.time,
    this.battery = 0,
  });

  String get label => switch (type) {
        ActivityType.unlock => 'Vault unlocked',
        ActivityType.fail => 'Failed attempt',
        ActivityType.lock => 'Vault locked',
        ActivityType.emergency => 'Emergency lock',
      };

  IconData get icon => switch (type) {
        ActivityType.unlock => Icons.lock_open_rounded,
        ActivityType.fail => Icons.gpp_bad_rounded,
        ActivityType.lock => Icons.lock_rounded,
        ActivityType.emergency => Icons.warning_amber_rounded,
      };

  Color get color => switch (type) {
        ActivityType.unlock => AppColors.success,
        ActivityType.fail => AppColors.danger,
        ActivityType.lock => AppColors.primary,
        ActivityType.emergency => AppColors.warning,
      };

  bool get isFail => type == ActivityType.fail;
  bool get isUnlock => type == ActivityType.unlock;
}
