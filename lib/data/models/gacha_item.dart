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

