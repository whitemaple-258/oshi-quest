import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/debug_controller.dart';
import '../../logic/gacha_config_controller.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gachaConfig = ref.watch(gachaConfigControllerProvider);
    final gachaNotifier = ref.read(gachaConfigControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('デバッグメニュー 🛠️'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'リセット',
            onPressed: () => gachaNotifier.reset(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ガチャ確率操作 (Cheat)',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
          ),

          _SliderRow(
            label: 'SSR倍率',
            value: gachaConfig.ssrWeightMult,
            min: 1.0,
            max: 100.0,
            onChanged: gachaNotifier.setSSRWeight,
          ),
          _SliderRow(
            label: 'SR倍率',
            value: gachaConfig.srWeightMult,
            min: 1.0,
            max: 100.0,
            onChanged: gachaNotifier.setSRWeight,
          ),
          _SliderRow(
            label: 'スキル付与率倍率',
            value: gachaConfig.skillProbMult,
            min: 1.0,
            max: 10.0,
            onChanged: gachaNotifier.setSkillProb,
          ),
          _SliderRow(
            label: 'ステータス底上げ',
            value: gachaConfig.statusBoost,
            min: 0.0,
            max: 200.0,
            onChanged: gachaNotifier.setStatusBoost,
          ),
          SwitchListTile(
            title: const Text('エフェクト確定', style: TextStyle(color: Colors.white)),
            value: gachaConfig.alwaysEffect,
            onChanged: gachaNotifier.toggleAlwaysEffect,
            activeThumbColor: Colors.amber,
          ),

          const Divider(height: 32),

          const Text(
            'リソース操作',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _DebugButton(
            label: 'ジェム +1000',
            icon: Icons.diamond,
            color: Colors.cyan,
            onPressed: () => ref.read(debugControllerProvider.notifier).addGems(1000),
          ),
          // ... (他のボタンは既存のまま)
          _DebugButton(
            label: '経験値 +500 (Lv UP)',
            icon: Icons.keyboard_double_arrow_up,
            color: Colors.amber,
            onPressed: () => ref.read(debugControllerProvider.notifier).addExp(500),
          ),
          _DebugButton(
            label: 'デバフを解除',
            icon: Icons.cleaning_services,
            color: Colors.green,
            onPressed: () => ref.read(debugControllerProvider.notifier).clearDebuff(),
          ),
          _DebugButton(
            label: '強制デイリーリセット',
            icon: Icons.update,
            color: Colors.purpleAccent,
            onPressed: () async {
              await ref.read(debugControllerProvider.notifier).forceDailyReset();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('日付変更判定を実行しました')));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              '${value.toStringAsFixed(1)}x',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(value: value, min: min, max: max, divisions: 100, onChanged: onChanged),
      ],
    );
  }
}

// _DebugButton クラスは既存のまま
class _DebugButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _DebugButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.8),
          foregroundColor: Colors.white,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
