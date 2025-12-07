import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../main.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final TextEditingController _titleController = TextEditingController();
  TaskType _selectedType = TaskType.strength;
  TaskDifficulty _selectedDifficulty = TaskDifficulty.normal;

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
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('タイプ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
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
                    if (value != null) {
                      setDialogState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('難易度', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<TaskDifficulty>(
                  segments: [
                    ButtonSegment(
                      value: TaskDifficulty.low,
                      label: const Text('低'),
                      icon: const Icon(Icons.arrow_downward, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskDifficulty.normal,
                      label: const Text('中'),
                      icon: const Icon(Icons.remove, size: 16),
                    ),
                    ButtonSegment(
                      value: TaskDifficulty.high,
                      label: const Text('高'),
                      icon: const Icon(Icons.arrow_upward, size: 16),
                    ),
                  ],
                  selected: {_selectedDifficulty},
                  onSelectionChanged: (Set<TaskDifficulty> newSelection) {
                    setDialogState(() {
                      _selectedDifficulty = newSelection.first;
                    });
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
      try {
        final repository = ref.read(habitRepositoryProvider);
        await repository.addHabit(
          _titleController.text.trim(),
          _selectedType,
          _selectedDifficulty,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('クエストを追加しました！'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラー: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _completeHabit(Habit habit) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      
      // 完了前のプレイヤー情報を取得（報酬表示用）
      final playerBefore = await ref.read(playerProvider.stream).first;
      
      await repository.completeHabit(habit);

      // 完了後のプレイヤー情報を取得（StreamProviderなので自動更新される）
      // 少し待機してから最新の値を取得
      await Future.delayed(const Duration(milliseconds: 200));
      final playerAfter = await ref.read(playerProvider.stream).first;

      // 報酬計算
      final gemsEarned = playerAfter.willGems - playerBefore.willGems;
      final xpEarned = playerAfter.experience - playerBefore.experience;
      
      // ステータス上昇を確認
      String statUp = '';
      switch (habit.taskType) {
        case TaskType.strength:
          if (playerAfter.str > playerBefore.str) {
            statUp = 'STR UP!';
          }
          break;
        case TaskType.intelligence:
          if (playerAfter.intellect > playerBefore.intellect) {
            statUp = 'INT UP!';
          }
          break;
        case TaskType.luck:
          if (playerAfter.luck > playerBefore.luck) {
            statUp = 'LUCK UP!';
          }
          break;
        case TaskType.charm:
          if (playerAfter.cha > playerBefore.cha) {
            statUp = 'CHA UP!';
          }
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$gemsEarned Gems, +$xpEarned XP $statUp'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('クエスト'),
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
                  Text(
                    'クエストを追加して始めましょう！',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ...incompleteHabits.map((habit) => _buildHabitCard(habit, false)),
                const SizedBox(height: 24),
              ],
              if (completedHabits.isNotEmpty) ...[
                const Text(
                  '完了済み',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ...completedHabits.map((habit) => _buildHabitCard(habit, true)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: TextStyle(color: Colors.red[300]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('クエスト追加'),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCompleted ? Colors.grey[900] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.3),
          child: Icon(
            _getTaskTypeIcon(habit.taskType),
            color: _getTaskTypeColor(habit.taskType),
          ),
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
              label: Text(
                _getTaskTypeLabel(habit.taskType),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getTaskTypeColor(habit.taskType).withOpacity(0.2),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Chip(
              label: Text(
                _getDifficultyLabel(habit.difficulty),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getDifficultyColor(habit.difficulty).withOpacity(0.2),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Text(
              '${habit.rewardGems}G / ${habit.rewardXp}XP',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        trailing: isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => _completeHabit(habit),
                tooltip: '完了',
              ),
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

  String _getDifficultyLabel(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.low:
        return '低';
      case TaskDifficulty.normal:
        return '中';
      case TaskDifficulty.high:
        return '高';
    }
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.low:
        return Colors.green;
      case TaskDifficulty.normal:
        return Colors.orange;
      case TaskDifficulty.high:
        return Colors.red;
    }
  }
}

