import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/database/database.dart';

class GachaCard extends StatelessWidget {
  final GachaItem item;

  const GachaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isUnlocked
              ? _getRarityColor(item.rarity)
              : Colors.white10,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 画像レイヤー（ローカルファイルまたはネットワークURL）
            _buildImage(item),

            // ロック中のアイコンオーバーレイ
            if (!item.isUnlocked)
              Container(
                color: Colors.black54,
                child: const Center(child: Icon(Icons.lock, color: Colors.white54, size: 32)),
              ),

            // レアリティバッジ
            if (item.isUnlocked && item.rarity != Rarity.n)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRarityColor(item.rarity),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: _getRarityColor(item.rarity).withOpacity(0.8),
                      ),
                    ],
                  ),
                  child: Text(
                    item.rarity.name.toUpperCase(),
                    style: const TextStyle(
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

  Widget _buildImage(GachaItem item) {
    final file = File(item.imagePath);
    final isLocalFile = file.existsSync();
    
    final imageWidget = isLocalFile
        ? Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
          )
        : Image.network(
            item.imagePath,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.pinkAccent,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
          );

    // ロック中は黒塗り
    if (!item.isUnlocked) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcATop),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey,
          size: 48,
        ),
      ),
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.n:
        return Colors.grey;
      case Rarity.r:
        return Colors.blue;
      case Rarity.sr:
        return Colors.purple;
      case Rarity.ssr:
        return Colors.amber;
    }
  }
}


