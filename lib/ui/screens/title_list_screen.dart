import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart' as db;
import '../../data/providers.dart';

class TitleListScreen extends ConsumerWidget {
  const TitleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titlesAsync = ref.watch(titlesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('称号コレクション')),
      body: titlesAsync.when(
        data: (titles) {
          if (titles.isEmpty) {
            return const Center(child: Text('データがありません'));
          }

          // 獲得済みを上に表示
          final sortedTitles = [...titles];
          /* Repository側でソート済みだが念のため */

          // 獲得数計算
          final unlockedCount = titles.where((t) => t.isUnlocked).length;
          final progress = unlockedCount / titles.length;

          return Column(
            children: [
              // 進捗バー
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black26,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('収集率', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '$unlockedCount / ${titles.length} (${(progress * 100).toStringAsFixed(1)}%)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      color: Colors.amber,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // リスト
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedTitles.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final title = sortedTitles[index];
                    return _buildTitleTile(context, title);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildTitleTile(BuildContext context, db.Title title) {
    final isUnlocked = title.isUnlocked;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isUnlocked ? Colors.amber.withOpacity(0.2) : Colors.grey[800],
        child: Icon(
          isUnlocked ? Icons.emoji_events : Icons.lock,
          color: isUnlocked ? Colors.amber : Colors.grey,
        ),
      ),
      title: Text(
        isUnlocked ? title.name : '？？？？？',
        style: TextStyle(
          fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          color: isUnlocked ? null : Colors.grey,
        ),
      ),
      subtitle: isUnlocked
          ? Text(title.description ?? '', style: const TextStyle(fontSize: 12))
          : const Text('獲得条件: ？？？', style: TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: isUnlocked ? const Icon(Icons.check_circle, color: Colors.green, size: 16) : null,
      onTap: isUnlocked
          ? () {
              // 詳細ダイアログ (必要なら)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(title.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title.description ?? ''),
                      const SizedBox(height: 16),
                      Text(
                        '獲得日: ${title.unlockedAt.toString().split(' ')[0]}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      // パッシブスキル等の説明があればここに追加
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('閉じる')),
                  ],
                ),
              );
            }
          : null,
    );
  }
}
