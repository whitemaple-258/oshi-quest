import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';

class GachaCard extends StatelessWidget {
  final GachaItem item;

  const GachaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 枠線の設定を取得
    final border = _buildBorder(item.rarity);
    final shadows = _buildShadow(item.rarity);

    return Stack(
      children: [
        // 1. 影（発光）エフェクト用コンテナ
        // ClipRRectの外に置かないと影が切り取られてしまうため、ここに配置
        if (shadows != null)
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), boxShadow: shadows),
          ),

        // 2. 画像と枠線本体（角丸で切り抜く）
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // A. 画像 (一番下: 領域いっぱいに表示)
              _buildImage(item),

              // B. SSR/SR用のキラキラオーバーレイ
              if (item.isUnlocked && (item.rarity == Rarity.ssr || item.rarity == Rarity.sr))
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

              // C. ロック中の黒塗り
              if (!item.isUnlocked)
                Container(
                  color: Colors.black54,
                  child: const Center(child: Icon(Icons.lock, color: Colors.white54, size: 32)),
                ),

              // D. 枠線 (画像の上に重ねる)
              if (border != null)
                Container(
                  decoration: BoxDecoration(
                    border: border,
                    borderRadius: BorderRadius.circular(8), // 枠線も角丸に合わせる
                  ),
                ),
            ],
          ),
        ),

        // 3. レアリティバッジ (一番上)
        if (item.isUnlocked && item.rarity != Rarity.n)
          Positioned(top: 4, right: 4, child: _buildRarityBadge(item.rarity)),

        // 4. SSR専用：枠外にはみ出す輝き
        if (item.isUnlocked && item.rarity == Rarity.ssr)
          const Positioned(
            top: -4,
            right: -4,
            child: Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
          ),
      ],
    );
  }

  // レアリティに応じた枠線を生成
  BoxBorder? _buildBorder(Rarity rarity) {
    if (!item.isUnlocked) return Border.all(color: Colors.white10, width: 2);

    switch (rarity) {
      case Rarity.ssr:
        return Border.all(color: Colors.amber, width: 3); // 金枠
      case Rarity.sr:
        return Border.all(color: Colors.purpleAccent, width: 3); // 紫枠
      case Rarity.r:
        return Border.all(color: Colors.blueAccent, width: 2); // 青枠
      case Rarity.n:
      default:
        return Border.all(color: Colors.grey, width: 1); // 灰色枠
    }
  }

  // レアリティに応じた影（発光）を生成
  List<BoxShadow>? _buildShadow(Rarity rarity) {
    if (!item.isUnlocked) return null;

    switch (rarity) {
      case Rarity.ssr:
        return [BoxShadow(color: Colors.amber.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)];
      case Rarity.sr:
        return [BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 8, spreadRadius: 0)];
      default:
        return null;
    }
  }

  Widget _buildRarityBadge(Rarity rarity) {
    Color bgColor;
    switch (rarity) {
      case Rarity.ssr:
        bgColor = Colors.amber;
        break;
      case Rarity.sr:
        bgColor = Colors.purpleAccent;
        break;
      case Rarity.r:
        bgColor = Colors.blueAccent;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(blurRadius: 4, color: bgColor.withOpacity(0.8))],
      ),
      child: Text(
        rarity.name.toUpperCase(),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildImage(GachaItem item) {
    final file = File(item.imagePath);
    final isLocalFile = file.existsSync();

    // ロック中はColorFilteredを使わず、上のレイヤーで黒塗りコンテナを重ねる方式に変更したので
    // ここでは純粋な画像ウィジェットのみを返します
    if (isLocalFile) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      return Image.network(
        item.imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48)),
    );
  }
}
