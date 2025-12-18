import 'package:flutter_riverpod/flutter_riverpod.dart';

// 仮のユーザーレベルプロバイダー（実際はUserテーブルなどから取得してください）
final userLevelProvider = Provider<int>((ref) => 1); // テスト用: ここを 1 -> 5 -> 10 と変えて確認

/// アプリの機能を定義するEnum
enum AppFeature {
  gacha(unlockLevel: 3, label: 'ガチャ', description: '仲間や装備を召喚します'),
  partyEdit(unlockLevel: 5, label: 'パーティ編成', description: '冒険に連れて行く仲間を編成します'),
  bossBattle(unlockLevel: 10, label: 'ボスバトル', description: '強大な敵に挑戦して報酬を獲得します');

  final int unlockLevel;
  final String label;
  final String description;

  const AppFeature({
    required this.unlockLevel,
    required this.label,
    required this.description,
  });
}

/// 指定した機能が解放されているかチェックするプロバイダー
final isFeatureUnlockedProvider = Provider.family<bool, AppFeature>((ref, feature) {
  final currentLevel = ref.watch(userLevelProvider);
  return currentLevel >= feature.unlockLevel;
});