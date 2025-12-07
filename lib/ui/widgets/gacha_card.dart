import 'package:flutter/material.dart';
import '../../data/models/gacha_item.dart';

class GachaCard extends StatelessWidget {
  final GachaItem item;

  const GachaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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

