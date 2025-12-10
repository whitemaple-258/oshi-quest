import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../logic/habit_controller.dart';
import '../../data/providers.dart'; // habitsProviderのため
import 'habit_add_screen.dart';

class HabitListScreen extends ConsumerWidget {
  // constコンストラクタにより、MainScreenのリビルド時にこのインスタンスを再利用可能
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('クエストボード'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            // 遷移先の画面もconstで生成
            MaterialPageRoute(builder: (context) => const HabitAddScreen()),
          );
        },
        label: const Text('受注'),
        icon: const Icon(Icons.add),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            // 静的なエラー表示は完全にconst化
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('現在、受注できるクエストはありません。\n右下のボタンから追加してください！', textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: habits.length,
            // paddingなどもconst化
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final habit = habits[index];
              // 個別のカードWidgetにデータを渡す。
              // HabitCard自体はconstにできない（habitデータが動的）が、
              // 内部の静的パーツはconst化して軽量化を図る。
              return _HabitCard(habit: habit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラーが発生しました: $err')),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final Habit habit;

  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = habit.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isCompleted ? 0 : 2,
      color: isCompleted ? Colors.white10 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(habit.taskType).withOpacity(0.2),
          child: Icon(_getTypeIcon(habit.taskType), color: _getTypeColor(habit.taskType)),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '報酬: ${habit.rewardGems} Gems / ${habit.rewardXp} XP  [${habit.difficulty.name.toUpperCase()}]',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isCompleted
            // 完了済みアイコンは静的なのでconst
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () async {
                  await ref.read(habitControllerProvider.notifier).completeHabit(habit);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('クエスト達成！ ${habit.rewardGems} ジェムを獲得しました！'),
                        backgroundColor: Colors.pinkAccent,
                      ),
                    );
                  }
                },
              ),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('クエスト破棄'),
              content: const Text('このクエストを削除しますか？'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
                TextButton(
                  onPressed: () {
                    // 削除時はIDのみ渡す
                    ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('削除', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // これらのヘルパーメソッドは純粋関数なので、Widget外に出すかstaticにしても良いが、
  // 現状はクラス内に留めておく
  Color _getTypeColor(TaskType type) {
    switch (type) {
      case TaskType.strength:
        return Colors.redAccent;
      case TaskType.vitality:
        return Colors.amber;
      case TaskType.intelligence:
        return Colors.blueAccent;
      case TaskType.luck:
        return Colors.purple;
      case TaskType.charm:
        return Colors.pinkAccent;
    }
  }

  IconData _getTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.strength:
        return Icons.fitness_center;
      case TaskType.vitality:
        return Icons.directions_run;
      case TaskType.intelligence:
        return Icons.school;
      case TaskType.luck:
        return Icons.casino;
      case TaskType.charm:
        return Icons.favorite;
    }
  }
}
