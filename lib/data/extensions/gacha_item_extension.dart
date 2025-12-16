import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database.dart'; // GachaItem, GachaItemType, TightsColor の定義

// 必要なアセットパスの定義 (ご自身のプロジェクトのアセット構成に合わせてください)
class AssetPaths {
  static const tightsGray = 'assets/images/tights_gray.png';
  static const tightsBlue = 'assets/images/tights_blue.png';
  static const tightsPurple = 'assets/images/tights_purple.png';
  static const tightsGold = 'assets/images/tights_gold.png';
  // エラー時のフォールバック画像
  static const fallback = 'assets/images/tights_gray.png';
}

extension GachaItemDisplay on GachaItem {
  /// UIで表示するための ImageProvider を取得する
  /// 使い分け: Image(image: item.displayImageProvider)
  ImageProvider get displayImageProvider {
    // 1. ユーザー画像タイプ かつ パスが存在する場合
    if (type == GachaItemType.userImage && imagePath != null && imagePath!.isNotEmpty) {
      return FileImage(File(imagePath!));
    }

    // 2. それ以外（タイツ君、またはパス欠損）はアセットを返す
    return AssetImage(_getTightsAssetPath());
  }

  /// タイツ君の色に応じたアセットパスを返す
  String _getTightsAssetPath() {
    switch (tightsColor) {
      case TightsColor.gray:
        return AssetPaths.tightsGray;
      case TightsColor.blue:
        return AssetPaths.tightsBlue;
      case TightsColor.purple:
        return AssetPaths.tightsPurple;
      case TightsColor.gold:
        return AssetPaths.tightsGold;
      default:
        return AssetPaths.fallback;
    }
  }
}
