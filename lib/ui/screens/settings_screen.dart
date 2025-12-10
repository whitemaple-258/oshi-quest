import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(currentThemeColorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // テーマカラー設定
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'テーマカラー設定',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ColorButton(color: Colors.red, name: 'red', selectedColor: themeColor),
                _ColorButton(color: Colors.orange, name: 'orange', selectedColor: themeColor),
                _ColorButton(color: Colors.amber, name: 'amber', selectedColor: themeColor),
                _ColorButton(color: Colors.green, name: 'green', selectedColor: themeColor),
                _ColorButton(color: Colors.teal, name: 'teal', selectedColor: themeColor),
                _ColorButton(color: Colors.blue, name: 'blue', selectedColor: themeColor),
                _ColorButton(color: Colors.indigo, name: 'indigo', selectedColor: themeColor),
                _ColorButton(color: Colors.purple, name: 'purple', selectedColor: themeColor),
                _ColorButton(color: Colors.pink, name: 'pink', selectedColor: themeColor),
                _ColorButton(color: Colors.blueGrey, name: 'grey', selectedColor: themeColor),
              ],
            ),
          ),

          const Divider(),

          // データ管理
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'データ管理',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('データを初期化する', style: TextStyle(color: Colors.red)),
            subtitle: const Text('全ての進行状況が削除されます。復元できません。'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('本当に初期化しますか？'),
                  content: const Text('この操作は取り消せません。\nアプリを再起動する必要があります。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        '初期化',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(settingsControllerProvider.notifier).resetGameData();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('データを初期化しました。')));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ColorButton extends ConsumerWidget {
  final MaterialColor color;
  final String name;
  final MaterialColor selectedColor;

  const _ColorButton({required this.color, required this.name, required this.selectedColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = color == selectedColor;

    return GestureDetector(
      onTap: () {
        ref.read(settingsControllerProvider.notifier).changeTheme(name);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)]
              : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
