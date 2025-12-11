import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/debug_controller.dart';

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('デバッグメニュー 🛠️'), backgroundColor: Colors.grey[900]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          _DebugButton(
            label: '経験値 +500 (Lv UP)',
            icon: Icons.keyboard_double_arrow_up,
            color: Colors.amber,
            onPressed: () => ref.read(debugControllerProvider.notifier).addExp(500),
          ),

          const Divider(height: 32),
          const Text(
            '状態異常・日付',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _DebugButton(
            label: 'デバフを解除 (禊クリア)',
            icon: Icons.cleaning_services,
            color: Colors.green,
            onPressed: () => ref.read(debugControllerProvider.notifier).clearDebuff(),
          ),
          _DebugButton(
            label: '強制デイリーリセット (サボり判定)',
            icon: Icons.update,
            color: Colors.purpleAccent,
            onPressed: () async {
              await ref.read(debugControllerProvider.notifier).forceDailyReset();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('日付変更判定を実行しました。ホームに戻って確認してください。')));
              }
            },
          ),
        ],
      ),
    );
  }
}

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
