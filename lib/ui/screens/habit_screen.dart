import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/habit_controller.dart'; // ✅ 追加

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final TextEditingController _titleController = TextEditingController();
  TaskType _selectedType = TaskType.strength;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.normal;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // --- ダイアログ表示と追加処理 ---
  Future<void> _showAddHabitDialog() async {
    _titleController.clear();
    _selectedType = TaskType.strength;
    _selectedDifficulty = TaskDifficulty.normal;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('新しいクエストを追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'クエスト名',
                    hintText: '例: 朝のジョギング',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: false,
                ),
                const SizedBox(height: 16),
                const Text('タイプ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: TaskType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getTaskTypeIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(_getTaskTypeLabel(type)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('難易度', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<TaskDifficulty>(
                  segments: const [
                    ButtonSegment(value: TaskDifficulty.low, label: Text('低')),
                    ButtonSegment(value: TaskDifficulty.normal, label: Text('中')),
                    ButtonSegment(value: TaskDifficulty.high, label: Text('高')),
                  ],
                  selected: {_selectedDifficulty},
                  onSelectionChanged: (Set<TaskDifficulty> newSelection) {
                    setDialogState(() => _selectedDifficulty = newSelection.first);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );

    if (result == true && _titleController.text.trim().isNotEmpty) {
      // ✅ Controller経由で追加
      await ref
          .read(habitControllerProvider.notifier)
          .addHabit(
            title: _titleController.text.trim(),
            type: _selectedType,
            difficulty: _selectedDifficulty,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('クエストを追加しました！'), backgroundColor: Colors.green),
        );
      }
    }
  }

  // --- 完了処理 ---
  Future<void> _completeHabit(Habit habit) async {
    // ✅ Controller経由で完了処理を実行
    final rewards = await ref.read(habitControllerProvider.notifier).completeHabit(habit);

    if (mounted && rewards != null) {
      final gems = rewards['gems'];
      final xp = rewards['xp'];
      final strUp = rewards['strUp']! > 0 ? 'STR+1 ' : '';
      final intUp = rewards['intUp']! > 0 ? 'INT+1 ' : '';
      final luckUp = rewards['luckUp']! > 0 ? 'LUCK+1 ' : '';
      final chaUp = rewards['chaUp']! > 0 ? 'CHA+1 ' : '';
      final levelUp = rewards['levelUp']! > 0 ? 'LEVEL UP! ' : '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('達成！ +$gems Gems, +$xp XP  $strUp$intUp$luckUp$chaUp$levelUp'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // --- 削除処理 ---
  Future<void> _deleteHabit(Habit habit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クエスト削除'),
        content: Text('「${habit.name}」を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // ✅ Controller経由で削除
      await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('クエストを削除しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final playerAsync = ref.watch(playerProvider);
    // ✅ Controllerの状態を監視（ローディング制御などに利用可能）
    final habitState = ref.watch(habitControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('クエスト'),
        actions: [
          playerAsync.when(
            data: (player) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                    const SizedBox(width: 4),
                    Text('${player.willGems}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('クエストを追加して始めましょう！', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final incompleteHabits = habits.where((h) => !h.isCompleted).toList();
          final completedHabits = habits.where((h) => h.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (incompleteHabits.isNotEmpty) ...[
                const Text(
                  '進行中',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ...incompleteHabits.map(
                  (habit) => _buildHabitCard(habit, false, habitState.isLoading),
                ),
                const SizedBox(height: 24),
              ],
              if (completedHabits.isNotEmpty) ...[
                const Text(
                  '完了済み',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...completedHabits.map(
                  (habit) => _buildHabitCard(habit, true, habitState.isLoading),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: habitState.isLoading ? null : _showAddHabitDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('クエスト追加'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, bool isCompleted, bool isLoading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCompleted ? Colors.grey[900] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.3),
          child: Icon(_getTaskTypeIcon(habit.taskType), color: _getTaskTypeColor(habit.taskType)),
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.white,
          ),
        ),
        subtitle: Row(
          children: [
            Chip(
              label: Text(_getTaskTypeLabel(habit.taskType), style: const TextStyle(fontSize: 10)),
              backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.2),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Text(
              '${habit.rewardGems}G / ${habit.rewardXp}XP',
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                // 処理中はボタン無効化
                onPressed: isLoading ? null : () => _completeHabit(habit),
                tooltip: '完了',
              ),
        onLongPress: () => _deleteHabit(habit), // 長押しで削除
      ),
    );
  }

  // --- ヘルパーメソッド（アイコン・色・ラベル） ---
  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.strength:
        return Icons.fitness_center;
      case TaskType.intelligence:
        return Icons.school;
      case TaskType.luck:
        return Icons.casino;
      case TaskType.charm:
        return Icons.favorite;
    }
  }

  String _getTaskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.strength:
        return 'STR';
      case TaskType.intelligence:
        return 'INT';
      case TaskType.luck:
        return 'LUCK';
      case TaskType.charm:
        return 'CHA';
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.strength:
        return Colors.red;
      case TaskType.intelligence:
        return Colors.blue;
      case TaskType.luck:
        return Colors.amber;
      case TaskType.charm:
        return Colors.pink;
    }
  }
}
