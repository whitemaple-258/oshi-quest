import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() {
  runApp(const OshiGachaApp());
}

// ----------------------------------------------------------------------
// Models
// ----------------------------------------------------------------------

// ユーザーが登録した画像アイテム
class GachaItem {
  final String id;
  final String imageUrl; // 本来はローカルパス
  final String title;
  bool isUnlocked;
  final bool isSSR;

  GachaItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.isUnlocked = false,
    this.isSSR = false,
  });
}

// ----------------------------------------------------------------------
// Main App
// ----------------------------------------------------------------------

class OshiGachaApp extends StatelessWidget {
  const OshiGachaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OshiQuest Gacha Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        useMaterial3: true,
      ),
      home: const GachaHomeScreen(),
    );
  }
}

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
          _buildStudioHeader(),

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
                      return _buildGachaItemCard(item);
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

  Widget _buildStudioHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_special, color: Colors.amber),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Sealed Box", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("登録済み画像: 封印中...", style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              // 画像追加シミュレーション
              _addDemoItems();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('ダミー画像を追加しました')));
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text("画像追加"),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildGachaItemCard(GachaItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isUnlocked ? (item.isSSR ? Colors.amber : Colors.blueGrey) : Colors.white10,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 画像レイヤー
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              color: item.isUnlocked ? null : Colors.black, // ロック中は黒塗り
              colorBlendMode: item.isUnlocked ? null : BlendMode.srcATop,
            ),

            // ロック中のアイコンオーバーレイ
            if (!item.isUnlocked)
              Container(
                color: Colors.black54,
                child: const Center(child: Icon(Icons.lock, color: Colors.white54, size: 32)),
              ),

            // SSRバッジ
            if (item.isUnlocked && item.isSSR)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.amber)],
                  ),
                  child: const Text(
                    "SSR",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Gacha Animation Dialog
// ----------------------------------------------------------------------

class GachaAnimationDialog extends StatefulWidget {
  final GachaItem item;
  final VoidCallback onAnimationComplete;

  const GachaAnimationDialog({super.key, required this.item, required this.onAnimationComplete});

  @override
  State<GachaAnimationDialog> createState() => _GachaAnimationDialogState();
}

class _GachaAnimationDialogState extends State<GachaAnimationDialog> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  bool _showResult = false; // 結果表示フラグ

  @override
  void initState() {
    super.initState();

    // 魔法陣の回転
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    // 出現演出
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // アニメーションシーケンス
    _startSequence();
  }

  void _startSequence() async {
    // 1. 魔法陣が回る (2秒待機)
    await Future.delayed(const Duration(seconds: 2));

    // 2. 結果表示へ移行
    if (mounted) {
      setState(() {
        _showResult = true;
      });
      _rotationController.stop();
      _scaleController.forward(); // ぼよんと出現

      // 親ウィジェットの状態を更新（ここでジェム消費などを確定）
      widget.onAnimationComplete();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 500,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- 魔法陣 (Magic Circle) ---
            if (!_showResult)
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.item.isSSR ? Colors.amber : Colors.cyanAccent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.item.isSSR ? Colors.amber : Colors.cyanAccent)
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(child: Icon(Icons.star, color: Colors.white, size: 100)),
                    ),
                  );
                },
              ),

            // --- 結果カード (Result Card) ---
            if (_showResult)
              ScaleTransition(
                scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "UNSEALED!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [Shadow(blurRadius: 10, color: Colors.pink)],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // カード本体
                    Container(
                      width: 280,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.item.isSSR ? Colors.amber : Colors.grey,
                          width: 8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.item.isSSR
                                ? Colors.amber.withOpacity(0.6)
                                : Colors.blue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(widget.item.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("閉じる"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
