import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/activity_entry.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});
  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  int _filter = 0; // 0 all, 1 unlocks, 2 fails

  @override
  Widget build(BuildContext context) {
    final all = context.watch<VaultController>().activities;
    final items = switch (_filter) {
      1 => all.where((e) => e.isUnlock).toList(),
      2 => all.where((e) => e.isFail).toList(),
      _ => all,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Activity'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _chip('All', 0),
                _chip('Unlocks', 1),
                _chip('Fails', 2),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No activity yet', style: TextStyle(color: AppColors.textMuted)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _row(items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(ActivityEntry e) => CurioCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: e.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(e.icon, color: e.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${DateFormat('MMM d · HH:mm').format(e.time)} · ${e.source}',
                  style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ]),
      );

  Widget _chip(String label, int idx) {
    final sel = _filter == idx;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _filter = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sel ? AppColors.primary : AppColors.surfaceBorder),
          ),
          child: Text(label,
              style: TextStyle(
                  color: sel ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
