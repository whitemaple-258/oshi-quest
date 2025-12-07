import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../data/models/gacha_item.dart';
import '../widgets/gacha_card.dart';
import '../widgets/magic_circle_dialog.dart';
import 'gacha_studio_screen.dart';

class GachaHomeScreen extends StatefulWidget {
  const GachaHomeScreen({super.key});

  @override
  State<GachaHomeScreen> createState() => _GachaHomeScreenState();
}

class _GachaHomeScreenState extends State<GachaHomeScreen> {
  // 状態管理（簡易版）
  int _willGems = 500; // 初期ジェム
  final List<GachaItem> _boxItems = []; // ガチャBOXの中身

  @override
  void initState() {
    super.initState();
    // デモ用：初期データを少し入れておく
    _addDemoItems();
  }

  void _addDemoItems() {
    // 本来は画像ピッカーで追加する
    for (int i = 0; i < 5; i++) {
      _boxItems.add(
        GachaItem(
          id: DateTime.now().toString() + i.toString(),
          imageUrl: 'https://picsum.photos/seed/${math.Random().nextInt(1000)}/400/600',
          title: '推しの日常ショット #$i',
          isSSR: math.Random().nextBool(), // ランダムでSSR化
        ),
      );
    }
    setState(() {});
  }

  // ジェムを追加（習慣達成シミュレーション）
  void _earnGems() {
    setState(() {
      _willGems += 100;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('習慣達成！ +100 Will Gems')));
  }

  // ガチャを引く処理
  void _pullGacha() {
    if (_willGems < 100) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ジェムが足りません！習慣をこなして貯めましょう。')));
      return;
    }

    // 未獲得のアイテムを探す
    final lockedItems = _boxItems.where((item) => !item.isUnlocked).toList();

    if (lockedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('このBOXはコンプリート済みです！新しい画像を登録してください。')));
      return;
    }

    // 抽選（Boxガチャ形式なので、残っているものからランダム）
    final winner = lockedItems[math.Random().nextInt(lockedItems.length)];

    // 演出開始
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GachaAnimationDialog(
        item: winner,
        onAnimationComplete: () {
          setState(() {
            _willGems -= 100;
            // リスト内の該当アイテムをアンロック状態にする
            final index = _boxItems.indexWhere((i) => i.id == winner.id);
            if (index != -1) {
              _boxItems[index].isUnlocked = true;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 画面構成
    return Scaffold(
      appBar: AppBar(
        title: const Text('OshiQuest'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.pinkAccent),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                const SizedBox(width: 8),
                Text('$_willGems Gems', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 上部：スタジオへの誘い
          GachaStudioScreen(
            boxItems: _boxItems,
            onItemsUpdated: (items) {
              setState(() {
                _boxItems.clear();
                _boxItems.addAll(items);
              });
            },
          ),

          const Divider(height: 1, color: Colors.white10),

          // メイン：ガチャBOXの状態表示
          Expanded(
            child: _boxItems.isEmpty
                ? const Center(child: Text("まずは画像を登録してBOXを作ろう"))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _boxItems.length,
                    itemBuilder: (context, index) {
                      final item = _boxItems[index];
                      return GachaCard(item: item);
                    },
                  ),
          ),
        ],
      ),
      // 下部：アクションボタン
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF16213E),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _earnGems,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("習慣達成 (+100G)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pullGacha,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("推しを召喚 (100G)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 8,
                  shadowColor: Colors.pinkAccent.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

