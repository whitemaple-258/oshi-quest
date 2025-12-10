import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../data/providers.dart';
import '../../logic/habit_controller.dart';
import '../../logic/audio_controller.dart';
import '../../ui/widgets/level_up_dialog.dart';

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

  // --- ダイアログ表示（追加・編集兼用） ---
  Future<void> _showEditHabitDialog({Habit? habit}) async {
    // 初期値の設定（編集時は既存データをセット）
    _titleController.text = habit?.name ?? '';
    _selectedType = habit?.taskType ?? TaskType.strength;
    _selectedDifficulty = habit?.difficulty ?? TaskDifficulty.normal;

    final isEditing = habit != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'クエスト編集' : '新しいクエスト'),
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
              child: Text(isEditing ? '更新' : '追加'),
            ),
          ],
        ),
      ),
    );

    if (result == true && _titleController.text.trim().isNotEmpty) {
      if (isEditing) {
        // 更新処理
        await ref
            .read(habitControllerProvider.notifier)
            .updateHabit(
              habit: habit,
              title: _titleController.text.trim(),
              type: _selectedType,
              difficulty: _selectedDifficulty,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('クエストを更新しました！'), backgroundColor: Colors.green),
          );
        }
      } else {
        // 追加処理
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
  }

  // --- 完了処理 (修正版) ---
  Future<void> _completeHabit(Habit habit) async {
    // 1. まず完了処理を実行
    final rewards = await ref.read(habitControllerProvider.notifier).completeHabit(habit);

    // 2. 結果が返ってきたらUI更新
    if (mounted && rewards != null) {
      final gems = rewards['gems'];
      final xp = rewards['xp'];
      final strUp = rewards['strUp']! > 0 ? 'STR+1 ' : '';
      final intUp = rewards['intUp']! > 0 ? 'INT+1 ' : '';
      final luckUp = rewards['luckUp']! > 0 ? 'LUCK+1 ' : '';
      final chaUp = rewards['chaUp']! > 0 ? 'CHA+1 ' : '';

      final isLevelUp = rewards['levelUp'] == 1;

      if (isLevelUp) {
        // ✅ レベルアップ時の処理
        // 先に音を鳴らす
        ref.read(audioControllerProvider.notifier).playLevelUpSE();

        // データの反映待ち（アニメーション用）
        await Future.delayed(const Duration(milliseconds: 500));

        // 最新のプレイヤー情報を取得
        final player = await ref.read(playerProvider.future);

        if (mounted) {
          // ダイアログ表示
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => LevelUpDialog(newLevel: player.level, onClosed: () {}),
          );
        }
      } else {
        // ✅ 通常完了時の処理
        ref.read(audioControllerProvider.notifier).playCompleteSE();

        // スナックバー表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('達成！ +$gems Gems, +$xp XP  $strUp$intUp$luckUp$chaUp'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // --- 操作メニュー（編集/削除） ---
  void _showHabitActionMenu(Habit habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context); // シートを閉じる
                _showEditHabitDialog(habit: habit); // 編集ダイアログを開く
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // シートを閉じる
                await _confirmDelete(habit); // 削除確認
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Habit habit) async {
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
        onPressed: habitState.isLoading ? null : () => _showEditHabitDialog(),
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
                onPressed: isLoading ? null : () => _completeHabit(habit),
                tooltip: '完了',
              ),
        // ✅ 変更: 長押しでアクションメニューを表示
        onLongPress: () => _showHabitActionMenu(habit),
      ),
    );
  }

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
