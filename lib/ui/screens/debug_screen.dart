import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/debug_controller.dart';
import '../../logic/gacha_config_controller.dart';
import '../../data/database/database.dart'; 
import '../../data/providers.dart' as app_providers; // myItemsProvider (アイテムリスト取得用)

class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugNotifier = ref.read(debugControllerProvider.notifier);
    final gachaConfig = ref.watch(gachaConfigControllerProvider);
    final gachaNotifier = ref.read(gachaConfigControllerProvider.notifier);

    // 所持アイテムのリストを監視
    final myItemsAsync = ref.watch(app_providers.myItemsProvider); 

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
          // --------------------------------------------------
          // 1. ガチャ確率操作 (Cheat)
          // --------------------------------------------------
          const _SectionHeader(title: 'ガチャ確率操作 (Cheat)', color: Colors.amber),
          
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
          // ... (他のSliderは省略) ...

          const Divider(height: 32),

          // --------------------------------------------------
          // 2. プレイヤーリソース/ステータス操作
          // --------------------------------------------------
          const _SectionHeader(title: 'プレイヤーリソース操作', color: Colors.blue),

          _DebugButton(
            label: 'ジェム +1000',
            icon: Icons.diamond,
            color: Colors.cyan,
            onPressed: () => debugNotifier.addGems(1000),
          ),
          _DebugButton(
            label: '経験値 +500 (Lv UP)',
            icon: Icons.keyboard_double_arrow_up,
            color: Colors.amber,
            onPressed: () => debugNotifier.addExp(500),
          ),
          _DebugButton(
            label: '全ステータス +100', 
            icon: Icons.fitness_center,
            color: Colors.lightGreen,
            onPressed: () => debugNotifier.addAllStats(100),
          ),
          
          const Divider(height: 16),

          // --------------------------------------------------
          // 3. アイテム/ガチャ操作
          // --------------------------------------------------
          const _SectionHeader(title: 'ガチャアイテム操作', color: Colors.purple),

          _AddGachaItemRow(debugNotifier: debugNotifier), 
          
          // エフェクト確定機能 (updateGachaItemEffectに対応)
          myItemsAsync.when(
            data: (items) {
              // アイテムがない場合はボタンを表示しない
              if (items.isEmpty) {
                return const Text('アイテムがありません。ガチャを引いてください。', style: TextStyle(color: Colors.white70));
              }
              return _EffectOverridePanel(
                items: items,
                debugNotifier: debugNotifier,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('エラー: $e', style: const TextStyle(color: Colors.red)),
          ),

          _DebugButton(
            label: '全装備解除 & ロック解除', 
            icon: Icons.lock_open,
            color: Colors.deepOrange,
            onPressed: () async {
              await debugNotifier.clearEquipmentsAndLocks();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('全装備解除とロックを解除しました')),
                );
              }
            },
          ),
          
          const Divider(height: 32),

          // --------------------------------------------------
          // 4. システム/状態リセット
          // --------------------------------------------------
          const _SectionHeader(title: 'システム/状態リセット', color: Colors.teal),
          
          _DebugButton(
            label: 'デバフを解除',
            icon: Icons.cleaning_services,
            color: Colors.green,
            onPressed: () => debugNotifier.clearDebuff(),
          ),
          _DebugButton(
            label: '強制デイリーリセット',
            icon: Icons.update,
            color: Colors.purpleAccent,
            onPressed: () async {
              await debugNotifier.forceDailyReset();
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

// ---------------------------------------------------------
// UIヘルパークラス
// ---------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        '▶ $title',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

// _SliderRow, _DebugButton は既存のまま
// ...

// ---------------------------------------------------------
// ガチャアイテム強制追加用ウィジェット
// ---------------------------------------------------------

class _AddGachaItemRow extends ConsumerStatefulWidget {
  final DebugController debugNotifier;
  const _AddGachaItemRow({required this.debugNotifier});

  @override
  ConsumerState<_AddGachaItemRow> createState() => _AddGachaItemRowState();
}

class _AddGachaItemRowState extends ConsumerState<_AddGachaItemRow> {
  Rarity _selectedRarity = Rarity.ssr;

  @override
  Widget build(BuildContext context) {
    // ... (既存の_AddGachaItemRowのbuildメソッドの内容を使用) ...
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<Rarity>(
              value: _selectedRarity,
              decoration: InputDecoration(
                labelText: '強制追加レアリティ',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: Rarity.values.map((Rarity rarity) {
                return DropdownMenuItem<Rarity>(
                  value: rarity,
                  child: Text(rarity.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (Rarity? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRarity = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              await widget.debugNotifier.addGachaItemsByRarity(_selectedRarity);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_selectedRarity.name.toUpperCase()}カードを10枚追加しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Icon(Icons.casino),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// エフェクト強制上書きパネル (新規)
// ---------------------------------------------------------

class _EffectOverridePanel extends ConsumerStatefulWidget {
  final List<GachaItem> items;
  final DebugController debugNotifier;
  
  const _EffectOverridePanel({
    required this.items,
    required this.debugNotifier,
  });

  @override
  ConsumerState<_EffectOverridePanel> createState() => _EffectOverridePanelState();
}

class _EffectOverridePanelState extends ConsumerState<_EffectOverridePanel> {
  late GachaItem _selectedItem;
  EffectType _selectedEffect = EffectType.lightning;

  @override
  void initState() {
    super.initState();
    // デフォルトでリストの最初のアイテムを選択
    _selectedItem = widget.items.first; 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('エフェクト強制上書き', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // 1. アイテム選択
          DropdownButtonFormField<GachaItem>(
            value: _selectedItem,
            decoration: const InputDecoration(labelText: '対象アイテム', labelStyle: TextStyle(color: Colors.white70)),
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            items: widget.items.map((GachaItem item) {
              return DropdownMenuItem<GachaItem>(
                value: item,
                child: Text('${item.title} (ID: ${item.id}) [${item.rarity.name.toUpperCase()}]'),
              );
            }).toList(),
            onChanged: (GachaItem? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedItem = newValue;
                });
              }
            },
          ),

          const SizedBox(height: 8),

          // 2. エフェクト選択
          DropdownButtonFormField<EffectType>(
            value: _selectedEffect,
            decoration: const InputDecoration(labelText: '適用するエフェクト', labelStyle: TextStyle(color: Colors.white70)),
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            items: EffectType.values.map((EffectType effect) {
              return DropdownMenuItem<EffectType>(
                value: effect,
                child: Text(effect.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (EffectType? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedEffect = newValue;
                });
              }
            },
          ),
          
          const SizedBox(height: 12),

          // 3. 確定ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.debugNotifier.updateGachaItemEffect(_selectedItem.id, _selectedEffect);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_selectedItem.title} に ${_selectedEffect.name} を適用しました')),
                  );
                }
              },
              icon: const Icon(Icons.flash_on),
              label: const Text('エフェクトを強制適用', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.withOpacity(0.8),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// _DebugButton クラスの再定義
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

// _SliderRow クラスの再定義
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
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min) ~/ 1, // 整数でのみ分割
          onChanged: onChanged,
          activeColor: Colors.amber,
        ),
      ],
    );
  }
}