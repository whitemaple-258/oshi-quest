import 'dart:io'; // ✅ 追加: Fileクラスを使うため
import 'package:flutter/material.dart'; // ✅ 追加: ImageProvider, AssetImage, FileImageを使うため
import 'database.dart'; // GachaItem, GachaItemType, TightsColorの定義

// UIで使用するアセットパスの定義
class TightsAssets {
  static const gray = 'assets/images/tights_gray.png';
  static const blue = 'assets/images/tights_blue.png';
  static const purple = 'assets/images/tights_purple.png';
  static const gold = 'assets/images/tights_gold.png';
  static const fallback = 'assets/images/tights_gray.png';
}

// Drift生成クラスへの拡張
extension GachaItemDisplay on GachaItem {
  /// UIで表示すべき画像プロバイダーを取得する
  /// (ローカルファイル画像 or アセット画像)
  ImageProvider get displayImageProvider {
    // ユーザー画像タイプ かつ パスが存在し、空文字でない場合
    if (type == GachaItemType.userImage && imagePath != null && imagePath!.isNotEmpty) {
      // ユーザー画像の場合: FileImage
      return FileImage(File(imagePath!));
    } else {
      // タイツ君の場合 (またはパス不正): AssetImage (色に応じて分岐)
      return AssetImage(_getTightsAssetPath());
    }
  }

  /// タイツ君のアセットパス解決ロジック
  String _getTightsAssetPath() {
    switch (tightsColor) {
      case TightsColor.gray:
        return TightsAssets.gray;
      case TightsColor.blue:
        return TightsAssets.blue;
      case TightsColor.purple:
        return TightsAssets.purple;
      case TightsColor.gold:
        return TightsAssets.gold;
      default:
        return TightsAssets.fallback; // noneの場合やデフォルト
    }
  }

  /// (オプション) 画像パス文字列そのものが欲しい場合
  String get displayPath {
    if (type == GachaItemType.userImage) {
      return imagePath ?? '';
    } else {
      return _getTightsAssetPath();
    }
  }
}
